;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: foreach %s %t wasm-opt -all --dae -S -o - | filecheck %s
;; RUN: foreach %s %t wasm-opt -all --dae --nominal -S -o - | filecheck %s --check-prefix=NOMNL

(module
 ;; CHECK:      (type ${} (struct ))
 ;; NOMNL:      (type ${} (struct_subtype  data))
 (type ${} (struct))

 ;; CHECK:      (func $foo
 ;; CHECK-NEXT:  (call $bar)
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $foo (type $none_=>_none)
 ;; NOMNL-NEXT:  (call $bar)
 ;; NOMNL-NEXT: )
 (func $foo
  (call $bar
   (i31.new
    (i32.const 1)
   )
  )
 )
 ;; CHECK:      (func $bar
 ;; CHECK-NEXT:  (local $0 (ref null i31))
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (ref.as_non_null
 ;; CHECK-NEXT:    (local.tee $0
 ;; CHECK-NEXT:     (i31.new
 ;; CHECK-NEXT:      (i32.const 2)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (local.tee $0
 ;; CHECK-NEXT:   (unreachable)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $bar (type $none_=>_none)
 ;; NOMNL-NEXT:  (local $0 (ref null i31))
 ;; NOMNL-NEXT:  (drop
 ;; NOMNL-NEXT:   (ref.as_non_null
 ;; NOMNL-NEXT:    (local.tee $0
 ;; NOMNL-NEXT:     (i31.new
 ;; NOMNL-NEXT:      (i32.const 2)
 ;; NOMNL-NEXT:     )
 ;; NOMNL-NEXT:    )
 ;; NOMNL-NEXT:   )
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT:  (local.tee $0
 ;; NOMNL-NEXT:   (unreachable)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT: )
 (func $bar (param $0 i31ref)
  (drop
   ;; after the parameter is removed, we create a nullable local to replace it,
   ;; and must update the tee's type accordingly to avoid a validation error,
   ;; and also add a ref.as_non_null so that the outside still receives the
   ;; same type as before
   (local.tee $0
    (i31.new
     (i32.const 2)
    )
   )
  )
  ;; test for an unreachable tee, whose type must be unreachable even after
  ;; the change (the tee would need to be dropped if it were not unreachable,
  ;; so the correctness in this case is visible in the output)
  (local.tee $0
   (unreachable)
  )
 )
 ;; a function that gets an rtt that is never used. we cannot create a local for
 ;; that parameter, as it is not defaultable, so do not remove the parameter.
 ;; CHECK:      (func $get-rtt (param $0 (rtt ${}))
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $get-rtt (type $rtt_${}_=>_none) (param $0 (rtt ${}))
 ;; NOMNL-NEXT:  (nop)
 ;; NOMNL-NEXT: )
 (func $get-rtt (param $0 (rtt ${}))
  (nop)
 )
 ;; CHECK:      (func $send-rtt
 ;; CHECK-NEXT:  (call $get-rtt
 ;; CHECK-NEXT:   (rtt.canon ${})
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $send-rtt (type $none_=>_none)
 ;; NOMNL-NEXT:  (call $get-rtt
 ;; NOMNL-NEXT:   (rtt.canon ${})
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT: )
 (func $send-rtt
  (call $get-rtt
   (rtt.canon ${})
  )
 )
)

;; Test ref.func and ref.null optimization of constant parameter values.
(module
 ;; CHECK:      (func $foo (param $0 (ref $none_=>_none))
 ;; CHECK-NEXT:  (local $1 (ref null $none_=>_none))
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (ref.func $a)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (ref.as_non_null
 ;; CHECK-NEXT:     (local.get $1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $foo (type $ref|none_->_none|_=>_none) (param $0 (ref $none_=>_none))
 ;; NOMNL-NEXT:  (local $1 (ref null $none_=>_none))
 ;; NOMNL-NEXT:  (local.set $1
 ;; NOMNL-NEXT:   (ref.func $a)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT:  (block
 ;; NOMNL-NEXT:   (drop
 ;; NOMNL-NEXT:    (ref.as_non_null
 ;; NOMNL-NEXT:     (local.get $1)
 ;; NOMNL-NEXT:    )
 ;; NOMNL-NEXT:   )
 ;; NOMNL-NEXT:   (drop
 ;; NOMNL-NEXT:    (local.get $0)
 ;; NOMNL-NEXT:   )
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT: )
 (func $foo (param $x (ref func)) (param $y (ref func))
  ;; "Use" the params to avoid other optimizations kicking in.
  (drop (local.get $x))
  (drop (local.get $y))
 )

 ;; CHECK:      (func $call-foo
 ;; CHECK-NEXT:  (call $foo
 ;; CHECK-NEXT:   (ref.func $b)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (call $foo
 ;; CHECK-NEXT:   (ref.func $c)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $call-foo (type $none_=>_none)
 ;; NOMNL-NEXT:  (call $foo
 ;; NOMNL-NEXT:   (ref.func $b)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT:  (call $foo
 ;; NOMNL-NEXT:   (ref.func $c)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT: )
 (func $call-foo
  ;; Call $foo with a constant function in the first param, which we
  ;; can optimize, but different ones in the second.
  (call $foo
   (ref.func $a)
   (ref.func $b)
  )
  (call $foo
   (ref.func $a)
   (ref.func $c)
  )
 )

 ;; CHECK:      (func $bar (param $0 (ref null $none_=>_none))
 ;; CHECK-NEXT:  (local $1 anyref)
 ;; CHECK-NEXT:  (local.set $1
 ;; CHECK-NEXT:   (ref.null any)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (drop
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $bar (type $ref?|none_->_none|_=>_none) (param $0 (ref null $none_=>_none))
 ;; NOMNL-NEXT:  (local $1 anyref)
 ;; NOMNL-NEXT:  (local.set $1
 ;; NOMNL-NEXT:   (ref.null any)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT:  (block
 ;; NOMNL-NEXT:   (drop
 ;; NOMNL-NEXT:    (local.get $1)
 ;; NOMNL-NEXT:   )
 ;; NOMNL-NEXT:   (drop
 ;; NOMNL-NEXT:    (local.get $0)
 ;; NOMNL-NEXT:   )
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT: )
 (func $bar (param $x (ref null any)) (param $y (ref null any))
  ;; "Use" the params to avoid other optimizations kicking in.
  (drop (local.get $x))
  (drop (local.get $y))
 )

 ;; CHECK:      (func $call-bar
 ;; CHECK-NEXT:  (call $bar
 ;; CHECK-NEXT:   (ref.null $none_=>_none)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (call $bar
 ;; CHECK-NEXT:   (ref.func $a)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $call-bar (type $none_=>_none)
 ;; NOMNL-NEXT:  (call $bar
 ;; NOMNL-NEXT:   (ref.null $none_=>_none)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT:  (call $bar
 ;; NOMNL-NEXT:   (ref.func $a)
 ;; NOMNL-NEXT:  )
 ;; NOMNL-NEXT: )
 (func $call-bar
  ;; Call with nulls. Mixing nulls is fine as they all have the same value, and
  ;; we can optimize (to the LUB of the nulls). However, mixing a null with a
  ;; reference stops us in the second param.
  (call $bar
   (ref.null func)
   (ref.null func)
  )
  (call $bar
   (ref.null any)
   (ref.func $a)
  )
 )

 ;; Helper functions so we have something to take the reference of.
 ;; CHECK:      (func $a
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $a (type $none_=>_none)
 ;; NOMNL-NEXT:  (nop)
 ;; NOMNL-NEXT: )
 (func $a)
 ;; CHECK:      (func $b
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $b (type $none_=>_none)
 ;; NOMNL-NEXT:  (nop)
 ;; NOMNL-NEXT: )
 (func $b)
 ;; CHECK:      (func $c
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 ;; NOMNL:      (func $c (type $none_=>_none)
 ;; NOMNL-NEXT:  (nop)
 ;; NOMNL-NEXT: )
 (func $c)
)
