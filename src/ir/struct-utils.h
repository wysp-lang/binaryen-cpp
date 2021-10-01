/*
 * Copyright 2021 WebAssembly Community Group participants
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef wasm_ir_struct_utils_h
#define wasm_ir_struct_utils_h

#include "ir/subtypes.h"
#include "wasm.h"

namespace wasm {

// A vector of a template type values. One such vector will be used per struct
// type, where each element in the vector represents a field. We always assume
// that the vectors are pre-initialized to the right length before accessing any
// data, which this class enforces using assertions, and which is implemented in
// StructValuesMap.
template<typename T> struct StructValues : public std::vector<T> {
  T& operator[](size_t index) {
    assert(index < this->size());
    return std::vector<T>::operator[](index);
  }

  const T& operator[](size_t index) const {
    assert(index < this->size());
    return std::vector<T>::operator[](index);
  }
};

// Map of types to information about the values their fields can take.
// Concretely, this maps a type to a StructValues which has one element per
// field.
template<typename T>
struct StructValuesMap : public std::unordered_map<HeapType, StructValues<T>> {
  // When we access an item, if it does not already exist, create it with a
  // vector of the right length for that type.
  StructValues<T>& operator[](HeapType type) {
    auto inserted = this->insert({type, {}});
    auto& values = inserted.first->second;
    if (inserted.second) {
      values.resize(type.getStruct().fields.size());
    }
    return values;
  }

  void combineInto(StructValuesMap<T>& combinedInfos) const {
    for (auto& kv : *this) {
      auto type = kv.first;
      auto& info = kv.second;
      for (Index i = 0; i < info.size(); i++) {
        combinedInfos[type][i].combine(info[i]);
      }
    }
  }

  void dump(std::ostream& o) {
    o << "dump " << this << '\n';
    for (auto& kv : (*this)) {
      auto type = kv.first;
      auto& vec = kv.second;
      o << "dump " << type << " " << &vec << ' ';
      for (auto x : vec) {
        x.dump(o);
        o << " ";
      };
      o << '\n';
    }
  }
};

// Map of functions to their field value infos. We compute those in parallel,
// then later we will merge them all.
template<typename T>
struct FunctionStructValuesMap
  : public std::unordered_map<Function*, StructValuesMap<T>> {
  FunctionStructValuesMap(Module& wasm) {
    // Initialize the data for each function in preparation for parallel
    // computation.
    for (auto& func : wasm.functions) {
      (*this)[func.get()];
    }
  }

  // Combine information across functions.
  void combineInto(StructValuesMap<T>& combinedInfos) const {
    for (auto& kv : *this) {
      const StructValuesMap<T>& infos = kv.second;
      infos.combineInto(combinedInfos);
    }
  }
};

// Scan each function to note all its writes to struct fields.
//
// We track information from struct.new and struct.set separately, because in
// struct.new we know more about the type - we know the actual exact type being
// written to, and not just that it is of a subtype of the instruction's type,
// which helps later.
template<typename T>
struct Scanner : public WalkerPass<PostWalker<Scanner<T>>> {
  bool isFunctionParallel() override { return true; }

  Scanner(FunctionStructValuesMap<T>& functionNewInfos,
          FunctionStructValuesMap<T>& functionSetInfos)
    : functionNewInfos(functionNewInfos), functionSetInfos(functionSetInfos) {}

  void visitStructNew(StructNew* curr) {
    auto type = curr->type;
    if (type == Type::unreachable) {
      return;
    }

    // Note writes to all the fields of the struct.
    auto heapType = type.getHeapType();
    auto& values = functionNewInfos[this->getFunction()][heapType];
    auto& fields = heapType.getStruct().fields;
    for (Index i = 0; i < fields.size(); i++) {
      if (curr->isWithDefault()) {
        values[i].note(Literal::makeZero(fields[i].type));
      } else {
        noteExpression(curr->operands[i], heapType, i, functionNewInfos);
      }
    }
  }

  void visitStructSet(StructSet* curr) {
    auto type = curr->ref->type;
    if (type == Type::unreachable) {
      return;
    }

    // Note a write to this field of the struct.
    noteExpression(
      curr->value, type.getHeapType(), curr->index, functionSetInfos);
  }

  FunctionStructValuesMap<T>& functionNewInfos;
  FunctionStructValuesMap<T>& functionSetInfos;

  // Note a value, checking whether it is a constant or not.
  virtual void noteExpression(Expression* expr,
                              HeapType type,
                              Index index,
                              FunctionStructValuesMap<T>& valuesMap) = 0;
};

template<typename T> class StructValuePropagator {
public:
  StructValuePropagator(Module& wasm) : subTypes(wasm) {}

  void propagateToSuperTypes(StructValuesMap<T>& infos) {
    propagate(infos, false);
  }

  void propagateToSuperAndSubTypes(StructValuesMap<T>& infos) {
    propagate(infos, true);
  }

private:
  void propagate(StructValuesMap<T>& combinedInfos, bool toSubTypes) {
    UniqueDeferredQueue<HeapType> work;
    for (auto& kv : combinedInfos) {
      auto type = kv.first;
      work.push(type);
    }
    while (!work.empty()) {
      auto type = work.pop();
      auto& infos = combinedInfos[type];

      // Propagate shared fields to the supertype.
      HeapType superType;
      if (type.getSuperType(superType)) {
        auto& superInfos = combinedInfos[superType];
        auto& superFields = superType.getStruct().fields;
        for (Index i = 0; i < superFields.size(); i++) {
          if (superInfos[i].combine(infos[i])) {
            work.push(superType);
          }
        }
      }

      if (toSubTypes) {
        // Propagate shared fields to the subtypes.
        auto numFields = type.getStruct().fields.size();
        for (auto subType : subTypes.getSubTypes(type)) {
          auto& subInfos = combinedInfos[subType];
          for (Index i = 0; i < numFields; i++) {
            if (subInfos[i].combine(infos[i])) {
              work.push(subType);
            }
          }
        }
      }
    }
  };

  SubTypes subTypes;
};

} // namespace wasm

#endif // wasm_ir_struct_utils_h
