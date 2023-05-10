;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; NOTE: This test was ported using port_passes_tests_to_lit.py and could be cleaned up.

;; All optimizations require closed world to function. Some also require
;; traps-never-happen.

;; RUN: foreach %s %t wasm-opt --directize                     -all -S -o - | filecheck %s --check-prefix=CHECK
;; RUN: foreach %s %t wasm-opt --directize -tnh                -all -S -o - | filecheck %s --check-prefix=TNH__
;; RUN: foreach %s %t wasm-opt --directize      --closed-world -all -S -o - | filecheck %s --check-prefix=CLOSD
;; RUN: foreach %s %t wasm-opt --directize -tnh --closed-world -all -S -o - | filecheck %s --check-prefix=BOTH_

(module
  (rec
    ;; CHECK:      (rec
    ;; CHECK-NEXT:  (type $t1 (func))
    ;; TNH__:      (rec
    ;; TNH__-NEXT:  (type $t1 (func))
    ;; CLOSD:      (rec
    ;; CLOSD-NEXT:  (type $t1 (func))
    ;; BOTH_:      (rec
    ;; BOTH_-NEXT:  (type $t1 (func))
    (type $t1 (func))

    ;; CHECK:       (type $t2 (func))
    ;; TNH__:       (type $t2 (func))
    ;; CLOSD:       (type $t2 (func))
    ;; BOTH_:       (type $t2 (func))
    (type $t2 (func))

    ;; CHECK:       (type $t3 (func))
    ;; TNH__:       (type $t3 (func))
    ;; CLOSD:       (type $t3 (func))
    ;; BOTH_:       (type $t3 (func))
    (type $t3 (func))

    ;; CHECK:       (type $t4 (func))
    ;; TNH__:       (type $t4 (func))
    ;; CLOSD:       (type $t4 (func))
    ;; BOTH_:       (type $t4 (func))
    (type $t4 (func))
  )

  ;; CHECK:      (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none (func (param (ref $t1) (ref $t2) (ref $t3) (ref $t4))))

  ;; CHECK:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; CHECK:      (func $caller (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none) (param $t1 (ref $t1)) (param $t2 (ref $t2)) (param $t3 (ref $t3)) (param $t4 (ref $t4))
  ;; CHECK-NEXT:  (call_ref $t1
  ;; CHECK-NEXT:   (local.get $t1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $t2
  ;; CHECK-NEXT:   (local.get $t2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $t3
  ;; CHECK-NEXT:   (local.get $t3)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $t4
  ;; CHECK-NEXT:   (local.get $t4)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none (func (param (ref $t1) (ref $t2) (ref $t3) (ref $t4))))

  ;; TNH__:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; TNH__:      (func $caller (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none) (param $t1 (ref $t1)) (param $t2 (ref $t2)) (param $t3 (ref $t3)) (param $t4 (ref $t4))
  ;; TNH__-NEXT:  (call_ref $t1
  ;; TNH__-NEXT:   (local.get $t1)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT:  (call_ref $t2
  ;; TNH__-NEXT:   (local.get $t2)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT:  (call_ref $t3
  ;; TNH__-NEXT:   (local.get $t3)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT:  (call_ref $t4
  ;; TNH__-NEXT:   (local.get $t4)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none (func (param (ref $t1) (ref $t2) (ref $t3) (ref $t4))))

  ;; CLOSD:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; CLOSD:      (func $caller (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none) (param $t1 (ref $t1)) (param $t2 (ref $t2)) (param $t3 (ref $t3)) (param $t4 (ref $t4))
  ;; CLOSD-NEXT:  (call_ref $t1
  ;; CLOSD-NEXT:   (local.get $t1)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT:  (call $t2-0)
  ;; CLOSD-NEXT:  (call_ref $t3
  ;; CLOSD-NEXT:   (local.get $t3)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT:  (call_ref $t4
  ;; CLOSD-NEXT:   (local.get $t4)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none (func (param (ref $t1) (ref $t2) (ref $t3) (ref $t4))))

  ;; BOTH_:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; BOTH_:      (func $caller (type $ref|$t1|_ref|$t2|_ref|$t3|_ref|$t4|_=>_none) (param $t1 (ref $t1)) (param $t2 (ref $t2)) (param $t3 (ref $t3)) (param $t4 (ref $t4))
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT:  (call $t2-0)
  ;; BOTH_-NEXT:  (call_ref $t3
  ;; BOTH_-NEXT:   (local.get $t3)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT:  (call $t4-0)
  ;; BOTH_-NEXT: )
  (func $caller (param $t1 (ref $t1)) (param $t2 (ref $t2)) (param $t3 (ref $t3)) (param $t4 (ref $t4))
    ;; All targets will trap, so we can emit an unreachable in TNH mode (and in
    ;; closed world). TODO: we could also trap here without TNH, basically to
    ;; propagate the trap outwards
    (call_ref $t1
      (local.get $t1)
    )
    ;; This has a single possible target, so we can directize (in closed world).
    (call_ref $t2
      (local.get $t2)
    )
    ;; This has multiple targets, so we cannot optimize.
    (call_ref $t3
      (local.get $t3)
    )
    ;; This has multiple targets, but one will trap, so the other must be called
    ;; in TNH mode (and also when closed world).
    (call_ref $t4
      (local.get $t4)
    )
  )

  ;; CHECK:      (func $t1-0 (type $t1)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t1-0 (type $t1)
  ;; TNH__-NEXT:  (unreachable)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t1-0 (type $t1)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t1-0 (type $t1)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT: )
  (func $t1-0 (type $t1)
    (unreachable)
  )

  ;; CHECK:      (func $t1-1 (type $t1)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t1-1 (type $t1)
  ;; TNH__-NEXT:  (unreachable)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t1-1 (type $t1)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t1-1 (type $t1)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT: )
  (func $t1-1 (type $t1)
    (unreachable)
  )

  ;; CHECK:      (func $t2-0 (type $t2)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t2-0 (type $t2)
  ;; TNH__-NEXT:  (drop
  ;; TNH__-NEXT:   (i32.const 0)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t2-0 (type $t2)
  ;; CLOSD-NEXT:  (drop
  ;; CLOSD-NEXT:   (i32.const 0)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t2-0 (type $t2)
  ;; BOTH_-NEXT:  (drop
  ;; BOTH_-NEXT:   (i32.const 0)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT: )
  (func $t2-0 (type $t2)
    (drop
      (i32.const 0)
    )
  )

  ;; CHECK:      (func $t3-0 (type $t3)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t3-0 (type $t3)
  ;; TNH__-NEXT:  (drop
  ;; TNH__-NEXT:   (i32.const 0)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t3-0 (type $t3)
  ;; CLOSD-NEXT:  (drop
  ;; CLOSD-NEXT:   (i32.const 0)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t3-0 (type $t3)
  ;; BOTH_-NEXT:  (drop
  ;; BOTH_-NEXT:   (i32.const 0)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT: )
  (func $t3-0 (type $t3)
    (drop
      (i32.const 0)
    )
  )

  ;; CHECK:      (func $t3-1 (type $t3)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t3-1 (type $t3)
  ;; TNH__-NEXT:  (drop
  ;; TNH__-NEXT:   (i32.const 1)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t3-1 (type $t3)
  ;; CLOSD-NEXT:  (drop
  ;; CLOSD-NEXT:   (i32.const 1)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t3-1 (type $t3)
  ;; BOTH_-NEXT:  (drop
  ;; BOTH_-NEXT:   (i32.const 1)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT: )
  (func $t3-1 (type $t3)
    (drop
      (i32.const 1)
    )
  )

  ;; CHECK:      (func $t4-0 (type $t4)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t4-0 (type $t4)
  ;; TNH__-NEXT:  (drop
  ;; TNH__-NEXT:   (i32.const 0)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t4-0 (type $t4)
  ;; CLOSD-NEXT:  (drop
  ;; CLOSD-NEXT:   (i32.const 0)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t4-0 (type $t4)
  ;; BOTH_-NEXT:  (drop
  ;; BOTH_-NEXT:   (i32.const 0)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT: )
  (func $t4-0 (type $t4)
    (drop
      (i32.const 0)
    )
  )

  ;; CHECK:      (func $t4-1 (type $t4)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t4-1 (type $t4)
  ;; TNH__-NEXT:  (unreachable)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t4-1 (type $t4)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t4-1 (type $t4)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT: )
  (func $t4-1 (type $t4)
    (unreachable)
  )

  ;; CHECK:      (func $ignore (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; CHECK-NEXT:  (block ;; (replaces something unreachable we can't emit)
  ;; CHECK-NEXT:   (drop
  ;; CHECK-NEXT:    (unreachable)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $ignore (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; TNH__-NEXT:  (block ;; (replaces something unreachable we can't emit)
  ;; TNH__-NEXT:   (drop
  ;; TNH__-NEXT:    (unreachable)
  ;; TNH__-NEXT:   )
  ;; TNH__-NEXT:   (unreachable)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $ignore (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; CLOSD-NEXT:  (block ;; (replaces something unreachable we can't emit)
  ;; CLOSD-NEXT:   (drop
  ;; CLOSD-NEXT:    (unreachable)
  ;; CLOSD-NEXT:   )
  ;; CLOSD-NEXT:   (unreachable)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $ignore (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; BOTH_-NEXT:  (block ;; (replaces something unreachable we can't emit)
  ;; BOTH_-NEXT:   (drop
  ;; BOTH_-NEXT:    (unreachable)
  ;; BOTH_-NEXT:   )
  ;; BOTH_-NEXT:   (unreachable)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT: )
  (func $ignore (param $t1 (ref $t1))
    ;; We should ignore this and not error.
    (call_ref $t2
      (unreachable)
    )
  )
)

(module
  ;; CHECK:      (type $t1 (func))
  ;; TNH__:      (type $t1 (func))
  ;; CLOSD:      (type $t1 (func))
  ;; BOTH_:      (type $t1 (func))
  (type $t1 (func))

  ;; CHECK:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; CHECK:      (import "a" "b" (func $t1-0))
  ;; TNH__:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; TNH__:      (import "a" "b" (func $t1-0))
  ;; CLOSD:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; CLOSD:      (import "a" "b" (func $t1-0))
  ;; BOTH_:      (type $ref|$t1|_=>_none (func (param (ref $t1))))

  ;; BOTH_:      (import "a" "b" (func $t1-0))
  (import "a" "b" (func $t1-0 (type $t1)))

  ;; CHECK:      (func $t1-1 (type $t1)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t1-1 (type $t1)
  ;; TNH__-NEXT:  (unreachable)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t1-1 (type $t1)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t1-1 (type $t1)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT: )
  (func $t1-1 (type $t1)
    (unreachable)
  )

  ;; CHECK:      (func $caller (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; CHECK-NEXT:  (call_ref $t1
  ;; CHECK-NEXT:   (local.get $t1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $caller (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; TNH__-NEXT:  (call_ref $t1
  ;; TNH__-NEXT:   (local.get $t1)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $caller (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; CLOSD-NEXT:  (call_ref $t1
  ;; CLOSD-NEXT:   (local.get $t1)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $caller (type $ref|$t1|_=>_none) (param $t1 (ref $t1))
  ;; BOTH_-NEXT:  (call $t1-0)
  ;; BOTH_-NEXT: )
  (func $caller (param $t1 (ref $t1))
    ;; One of the targets is unreachable, and one is an import. In TNH mode
    ;; (with closed-world) we can infer that the import must be called.
    (call_ref $t1
      (local.get $t1)
    )
  )
)

(module
  ;; As above, but with call_indirect rather than call_ref. With an imported
  ;; table as we have here, we optimize_call_indirect like call_ref basically
  ;; since all we have is the type, but that is enough to optimize exactly like
  ;; the last module above us.

  ;; CHECK:      (type $t1 (func))
  ;; TNH__:      (type $t1 (func))
  ;; CLOSD:      (type $t1 (func))
  ;; BOTH_:      (type $t1 (func))
  (type $t1 (func))

  ;; CHECK:      (type $i32_=>_none (func (param i32)))

  ;; CHECK:      (import "a" "b" (table $table 0 funcref))
  ;; TNH__:      (type $i32_=>_none (func (param i32)))

  ;; TNH__:      (import "a" "b" (table $table 0 funcref))
  ;; CLOSD:      (type $i32_=>_none (func (param i32)))

  ;; CLOSD:      (import "a" "b" (table $table 0 funcref))
  ;; BOTH_:      (type $i32_=>_none (func (param i32)))

  ;; BOTH_:      (import "a" "b" (table $table 0 funcref))
  (import "a" "b" (table $table 1))

  ;; CHECK:      (import "a" "b" (func $t1-0))
  ;; TNH__:      (import "a" "b" (func $t1-0))
  ;; CLOSD:      (import "a" "b" (func $t1-0))
  ;; BOTH_:      (import "a" "b" (func $t1-0))
  (import "a" "b" (func $t1-0 (type $t1)))

  ;; CHECK:      (func $t1-1 (type $t1)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t1-1 (type $t1)
  ;; TNH__-NEXT:  (unreachable)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t1-1 (type $t1)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t1-1 (type $t1)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT: )
  (func $t1-1 (type $t1)
    (unreachable)
  )

  ;; CHECK:      (func $caller (type $i32_=>_none) (param $x i32)
  ;; CHECK-NEXT:  (call_indirect $table (type $t1)
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $caller (type $i32_=>_none) (param $x i32)
  ;; TNH__-NEXT:  (call_indirect $table (type $t1)
  ;; TNH__-NEXT:   (local.get $x)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $caller (type $i32_=>_none) (param $x i32)
  ;; CLOSD-NEXT:  (call_indirect $table (type $t1)
  ;; CLOSD-NEXT:   (local.get $x)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $caller (type $i32_=>_none) (param $x i32)
  ;; BOTH_-NEXT:  (call $t1-0)
  ;; BOTH_-NEXT: )
  (func $caller (param $x i32)
    (call_indirect $table (type $t1)
      (local.get $x)
    )
  )
)

(module
  ;; As above, but with call_indirect on a non-imported and non-modified table,
  ;; that lets us optimize using the table's contents. Now we can do better than
  ;; call_ref: there are three functions of type $t1, and even in TNH mode we
  ;; can just eliminate one of them, but based on which are in the table being
  ;; called we can optimize.

  ;; CHECK:      (type $t1 (func))
  ;; TNH__:      (type $t1 (func))
  ;; CLOSD:      (type $t1 (func))
  ;; BOTH_:      (type $t1 (func))
  (type $t1 (func))

  ;; CHECK:      (type $i32_ref|$t1|_=>_none (func (param i32 (ref $t1))))

  ;; CHECK:      (import "a" "b" (func $t1-0))

  ;; CHECK:      (table $one 0 funcref)
  ;; TNH__:      (type $i32_ref|$t1|_=>_none (func (param i32 (ref $t1))))

  ;; TNH__:      (import "a" "b" (func $t1-0))

  ;; TNH__:      (table $one 0 funcref)
  ;; CLOSD:      (type $i32_ref|$t1|_=>_none (func (param i32 (ref $t1))))

  ;; CLOSD:      (import "a" "b" (func $t1-0))

  ;; CLOSD:      (table $one 0 funcref)
  ;; BOTH_:      (type $i32_ref|$t1|_=>_none (func (param i32 (ref $t1))))

  ;; BOTH_:      (import "a" "b" (func $t1-0))

  ;; BOTH_:      (table $one 0 funcref)
  (table $one funcref 10)
  ;; CHECK:      (table $two 0 funcref)

  ;; CHECK:      (table $three 0 funcref)

  ;; CHECK:      (elem $one (table $one) (i32.const 1) func $t1-0)
  ;; TNH__:      (table $two 0 funcref)

  ;; TNH__:      (table $three 0 funcref)

  ;; TNH__:      (elem $one (table $one) (i32.const 1) func $t1-0)
  ;; CLOSD:      (table $two 0 funcref)

  ;; CLOSD:      (table $three 0 funcref)

  ;; CLOSD:      (elem $one (table $one) (i32.const 1) func $t1-0)
  ;; BOTH_:      (table $two 0 funcref)

  ;; BOTH_:      (table $three 0 funcref)

  ;; BOTH_:      (elem $one (table $one) (i32.const 1) func $t1-0)
  (elem $one (i32.const 1) $t1-0)

  (table $two funcref 20)
  ;; CHECK:      (elem $two (table $one) (i32.const 2) func $t1-0 $t1-1)
  ;; TNH__:      (elem $two (table $one) (i32.const 2) func $t1-0 $t1-1)
  ;; CLOSD:      (elem $two (table $one) (i32.const 2) func $t1-0 $t1-1)
  ;; BOTH_:      (elem $two (table $one) (i32.const 2) func $t1-0 $t1-1)
  (elem $two (i32.const 2) $t1-0 $t1-1)

  (table $three funcref 30)
  ;; CHECK:      (elem $three (table $one) (i32.const 3) func $t1-0 $t1-1 $t1-2)
  ;; TNH__:      (elem $three (table $one) (i32.const 3) func $t1-0 $t1-1 $t1-2)
  ;; CLOSD:      (elem $three (table $one) (i32.const 3) func $t1-0 $t1-1 $t1-2)
  ;; BOTH_:      (elem $three (table $one) (i32.const 3) func $t1-0 $t1-1 $t1-2)
  (elem $three (i32.const 3) $t1-0 $t1-1 $t1-2)

  (import "a" "b" (func $t1-0 (type $t1)))

  ;; CHECK:      (func $t1-1 (type $t1)
  ;; CHECK-NEXT:  (unreachable)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t1-1 (type $t1)
  ;; TNH__-NEXT:  (unreachable)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t1-1 (type $t1)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t1-1 (type $t1)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT: )
  (func $t1-1 (type $t1)
    (unreachable)
  )

  ;; CHECK:      (func $t1-2 (type $t1)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $t1-2 (type $t1)
  ;; TNH__-NEXT:  (nop)
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $t1-2 (type $t1)
  ;; CLOSD-NEXT:  (nop)
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $t1-2 (type $t1)
  ;; BOTH_-NEXT:  (nop)
  ;; BOTH_-NEXT: )
  (func $t1-2 (type $t1)
    (nop)
  )

  ;; CHECK:      (func $caller (type $i32_ref|$t1|_=>_none) (param $x i32) (param $t1 (ref $t1))
  ;; CHECK-NEXT:  (call_indirect $one (type $t1)
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_indirect $two (type $t1)
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_indirect $two (type $t1)
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call_ref $t1
  ;; CHECK-NEXT:   (local.get $t1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  ;; TNH__:      (func $caller (type $i32_ref|$t1|_=>_none) (param $x i32) (param $t1 (ref $t1))
  ;; TNH__-NEXT:  (call_indirect $one (type $t1)
  ;; TNH__-NEXT:   (local.get $x)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT:  (call_indirect $two (type $t1)
  ;; TNH__-NEXT:   (local.get $x)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT:  (call_indirect $two (type $t1)
  ;; TNH__-NEXT:   (local.get $x)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT:  (call_ref $t1
  ;; TNH__-NEXT:   (local.get $t1)
  ;; TNH__-NEXT:  )
  ;; TNH__-NEXT: )
  ;; CLOSD:      (func $caller (type $i32_ref|$t1|_=>_none) (param $x i32) (param $t1 (ref $t1))
  ;; CLOSD-NEXT:  (call_indirect $one (type $t1)
  ;; CLOSD-NEXT:   (local.get $x)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT:  (unreachable)
  ;; CLOSD-NEXT:  (call_ref $t1
  ;; CLOSD-NEXT:   (local.get $t1)
  ;; CLOSD-NEXT:  )
  ;; CLOSD-NEXT: )
  ;; BOTH_:      (func $caller (type $i32_ref|$t1|_=>_none) (param $x i32) (param $t1 (ref $t1))
  ;; BOTH_-NEXT:  (call_indirect $one (type $t1)
  ;; BOTH_-NEXT:   (local.get $x)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT:  (unreachable)
  ;; BOTH_-NEXT:  (call_ref $t1
  ;; BOTH_-NEXT:   (local.get $t1)
  ;; BOTH_-NEXT:  )
  ;; BOTH_-NEXT: )
  (func $caller (param $x i32) (param $t1 (ref $t1))
    ;; Only one function is in that table, so we can call it directly.
    (call_indirect $one (type $t1)
      (local.get $x)
    )
    ;; Two functions, but with TNH we can rule out the second and optimize.
    (call_indirect $two (type $t1)
      (local.get $x)
    )
    ;; Three functions, and two of them are possible, so we cannot optimize.
    (call_indirect $two (type $t1)
      (local.get $x)
    )
    ;; For comparison, call_ref only has the type, and cannot optimize.
    (call_ref $t1
      (local.get $t1)
    )
  )
)
