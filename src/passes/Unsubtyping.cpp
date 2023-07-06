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

//
//

#include "ir/lubs.h"
#include "ir/possible-contents.h"
#include "pass.h"
#include "wasm-type.h"
#include "wasm.h"

namespace wasm {

namespace {

struct Unsubtyping : public Pass {
  // Only modifies types.
  bool requiresNonNullableLocalFixups() override { return false; }

  // Maps each heap type to the LUB of the subtypes of the places it is written
  // to.
  std::unordered_map<HeapType, HeapLUBFinder> typeLUBs;

  void run(Module* module) override {
    if (!module->features.hasGC()) {
      return;
    }

    // Build the graph of all places where content can flow. Using this graph we
    // can optimize according to the simple rule of modifying the parent of a
    // type to be the least-refined type that the type can be written to. That
    // is, if we have A :> B :> C and
    //
    //  B* bloc1 = new B(); // a B is written to a place of type B
    //  A* aloc1 = new C(); // A C is written to a place of type A
    //
    // If we have no other uses of these types, then B does not need any
    // (non-basic) supertype, as it is not written to any location of type A.
    // C, on the other hand, is written to a location of type A, so's supertype
    // can be A and not C, giving us A :> C, skipping B in the middle. If we
    // also had
    //
    //  B* bloc2 = new C(); // A C is written to a place of type B
    //
    // when we'd need to have A :> B :> C, that is, we need to keep using the
    // entire original subtyping tree, including the connection between B and A,
    // simply for C's benefit, since C is written to locations of both types A
    // and B.
    PossibleContentsGraph graph(*module);

    for (Index index = 0; index < graph.locations.size(); index++) {
      // Get the location for this index, and the targets it sends data to.
      auto& sourceInfo = graph.locations[index];
      auto& source = sourceInfo.location;

      auto sourceType = getLocationType(source);
      if (!sourceType.isRef()) {
        continue;
      }

      auto& targets = sourceInfo.targets;

      for (auto targetIndex : targets) {
        auto target = graph.getLocation(targetIndex);
        auto targetType = getLocationType(target);
        if (!targetType.isRef()) {
          continue;
        }

        // We have a connection where data goes from source => target, which
        // means we are writing something of type sourceType into a slot of
        // type targetType.
        noteWrite(sourceType.getHeapType(), targetType.getHeapType());
      }

      // TODO: childParent stuff
    }

    for (auto& [k, v] : typeLUBs) {
      std::cout << k << " has lub " << v.getLUB() << '\n';
    }
  }

  // Note that we write something of sourceType into a slot of type targetType. 
  void noteWrite(HeapType sourceType, HeapType targetType) {
    if (sourceType == targetType) {
      // Writing the same type has no effect.
      return;
    }

    typeLUBs[sourceType].note(targetType);
  }

  // Get the type of a location. This is the type of the location itself, and
  // not the content that might be present there (which could be more precise,
  // or could be nonexistent).
  // TODO: move to possible-contents.h?
  Type getLocationType(Location location) {
    if (auto* loc = std::get_if<ExpressionLocation>(&location)) {
      return *loc->expr->type;
    } else if (auto* loc = std::get_if<DataLocation>(&location)) {
      std::cout << "  dataloc ";
      if (wasm.typeNames.count(loc->type)) {
        std::cout << '$' << wasm.typeNames[loc->type].name;
      } else {
        std::cout << loc->type << '\n';
      }
      std::cout << " : " << loc->index << '\n';
    } else if (auto* loc = std::get_if<TagLocation>(&location)) {
      std::cout << "  tagloc " << loc->tag << '\n';
    } else if (auto* loc = std::get_if<ParamLocation>(&location)) {
      std::cout << "  paramloc " << loc->func->name << " : " << loc->index
                << '\n';
    } else if (auto* loc = std::get_if<ResultLocation>(&location)) {
      std::cout << "  resultloc $" << loc->func->name << " : " << loc->index
                << '\n';
    } else if (auto* loc = std::get_if<GlobalLocation>(&location)) {
      std::cout << "  globalloc " << loc->name << '\n';
    } else if (auto* loc = std::get_if<BreakTargetLocation>(&location)) {
      std::cout << "  branchloc " << loc->func->name << " : " << loc->target
                << " tupleIndex " << loc->tupleIndex << '\n';
    } else if (std::get_if<SignatureParamLocation>(&location)) {
      std::cout << "  sigparamloc " << '\n';
    } else if (std::get_if<SignatureResultLocation>(&location)) {
      std::cout << "  sigresultloc " << '\n';
    } else if (auto* loc = std::get_if<NullLocation>(&location)) {
      std::cout << "  Nullloc " << loc->type << '\n';
    } else {
      std::cout << "  (other)\n";
    }
  }
};

} // anonymous namespace

Pass* createUnsubtypingPass() { return new Unsubtyping(); }

} // namespace wasm