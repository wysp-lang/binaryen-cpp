;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.
;; RUN: foreach %s %t wasm-opt --once-reduction -S -o - | filecheck %s

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once (mut i32) (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $once
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $once
    ;; A minimal "once" function.
    (if
      (global.get $once)
      (return)
    )
    (global.set $once (i32.const 1))
  )

  ;; CHECK:      (func $caller
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $caller
    ;; Call a once function more than once, in a way that we can optimize: the
    ;; first dominates the second.
    (call $once)
    (call $once)
  )
)

(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (global $once (mut i32) (i32.const 0))
  (global $once (mut i32) (i32.const 0))

  ;; CHECK:      (func $once
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $once
    (if
      (global.get $once)
      (return)
    )
    (global.set $once (i32.const 1))
    ;; Add some more content in the function.
  )

  ;; CHECK:      (func $caller-if-1
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:   (block $block
  ;; CHECK-NEXT:    (call $once)
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $caller-if-1
    ;; Add more calls, and ones that are conditional.
    (if
      (i32.const 1)
      (block
        (call $once)
        (call $once)
        (call $once)
        (call $once)
      )
    )
    (call $once)
    (call $once)
  )

  ;; CHECK:      (func $caller-if-2
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:   (call $once)
  ;; CHECK-NEXT:   (block $block
  ;; CHECK-NEXT:    (call $once)
  ;; CHECK-NEXT:    (nop)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $caller-if-2
    ;; Call in both arms. As we only handle dominance, and not merges, the first
    ;; call after the if is *not* optimized.
    (if
      (i32.const 1)
      (call $once)
      (block
        (call $once)
        (call $once)
      )
    )
    (call $once)
    (call $once)
  )

  ;; CHECK:      (func $caller-loop-1
  ;; CHECK-NEXT:  (loop $loop
  ;; CHECK-NEXT:   (if
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:    (call $once)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (call $once)
  ;; CHECK-NEXT:   (nop)
  ;; CHECK-NEXT:   (br_if $loop
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $caller-loop-1
    ;; Add calls in a loop.
    (loop $loop
      (if
        (i32.const 1)
        (call $once)
      )
      (call $once)
      (call $once)
      (br_if $loop (i32.const 1))
    )
    (call $once)
    (call $once)
  )

  ;; CHECK:      (func $caller-loop-2
  ;; CHECK-NEXT:  (loop $loop
  ;; CHECK-NEXT:   (if
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:    (call $once)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:   (br_if $loop
  ;; CHECK-NEXT:    (i32.const 1)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $caller-loop-2
    ;; Add a single conditional call in a loop.
    (loop $loop
      (if
        (i32.const 1)
        (call $once)
      )
      (br_if $loop (i32.const 1))
    )
    (call $once)
    (call $once)
  )
)

;; Corner case: Initial value is not zero. We can still optimize this here,
;; though in fact the function will never execute the payload call of foo(),
;; which in theory we could further optimize.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (import "env" "foo" (func $foo))
  (import "env" "foo" (func $foo))

  ;; CHECK:      (global $once (mut i32) (i32.const 42))
  (global $once (mut i32) (i32.const 42))

  ;; CHECK:      (func $once
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $foo)
  ;; CHECK-NEXT: )
  (func $once
    (if
      (global.get $once)
      (return)
    )
    (global.set $once (i32.const 1))
    (call $foo)
  )

  ;; CHECK:      (func $caller
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $caller
    (call $once)
    (call $once)
  )
)

;; Corner case: function is not quite once, there is code before the if.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (import "env" "foo" (func $foo))
  (import "env" "foo" (func $foo))

  ;; CHECK:      (global $once (mut i32) (i32.const 42))
  (global $once (mut i32) (i32.const 42))

  ;; CHECK:      (func $once
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $foo)
  ;; CHECK-NEXT: )
  (func $once
    (nop)
    (if
      (global.get $once)
      (return)
    )
    (global.set $once (i32.const 1))
    (call $foo)
  )

  ;; CHECK:      (func $caller
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT: )
  (func $caller
    (call $once)
    (call $once)
  )
)

;; Corner case: a nop after the if.
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (import "env" "foo" (func $foo))
  (import "env" "foo" (func $foo))

  ;; CHECK:      (global $once (mut i32) (i32.const 42))
  (global $once (mut i32) (i32.const 42))

  ;; CHECK:      (func $once
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $foo)
  ;; CHECK-NEXT: )
  (func $once
    (if
      (global.get $once)
      (return)
    )
    (nop)
    (global.set $once (i32.const 1))
    (call $foo)
  )

  ;; CHECK:      (func $caller
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT: )
  (func $caller
    (call $once)
    (call $once)
  )
)

;; Corner case: the if has an else
(module
  ;; CHECK:      (type $none_=>_none (func))

  ;; CHECK:      (import "env" "foo" (func $foo))
  (import "env" "foo" (func $foo))

  ;; CHECK:      (global $once (mut i32) (i32.const 42))
  (global $once (mut i32) (i32.const 42))

  ;; CHECK:      (func $once
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (global.get $once)
  ;; CHECK-NEXT:   (return)
  ;; CHECK-NEXT:   (call $foo)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (global.set $once
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (call $foo)
  ;; CHECK-NEXT: )
  (func $once
    (if
      (global.get $once)
      (return)
      (call $foo)
    )
    (global.set $once (i32.const 1))
    (call $foo)
  )

  ;; CHECK:      (func $caller
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT:  (call $once)
  ;; CHECK-NEXT: )
  (func $caller
    (call $once)
    (call $once)
  )
)

