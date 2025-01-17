;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --optimize-instructions -all -S -o - \
;; RUN:   | filecheck %s

(module
  ;; CHECK:      (type $array (array (mut i8)))
  (type $array (array (mut i8)))

  ;; CHECK:      (func $extern.convert_any (type $0) (param $x anyref) (param $y externref)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (extern.convert_any
  ;; CHECK-NEXT:    (local.get $x)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.as_non_null
  ;; CHECK-NEXT:    (extern.convert_any
  ;; CHECK-NEXT:     (local.get $x)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (any.convert_extern
  ;; CHECK-NEXT:    (local.get $y)
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.as_non_null
  ;; CHECK-NEXT:    (any.convert_extern
  ;; CHECK-NEXT:     (local.get $y)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $extern.convert_any (param $x (ref null any)) (param $y (ref null extern))
    ;; We should not change anything here, and also not hit an internal error.
    (drop
      (extern.convert_any
        (local.get $x)
      )
    )
    ;; We can reorder the externalize with the ref.as_non_null, which sometimes
    ;; helps later optimizations, see below.
    (drop
      (extern.convert_any
        (ref.as_non_null
          (local.get $x)
        )
      )
    )
    ;; As the above two cases, but for internalize.
    (drop
      (any.convert_extern
        (local.get $y)
      )
    )
    (drop
      (any.convert_extern
        (ref.as_non_null
          (local.get $y)
        )
      )
    )
  )

  ;; CHECK:      (func $convert.optimize.parent (type $1) (param $ext externref)
  ;; CHECK-NEXT:  (drop
  ;; CHECK-NEXT:   (ref.cast (ref $array)
  ;; CHECK-NEXT:    (any.convert_extern
  ;; CHECK-NEXT:     (local.get $ext)
  ;; CHECK-NEXT:    )
  ;; CHECK-NEXT:   )
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $convert.optimize.parent (param $ext externref)
    ;; The ref.cast can fold in the ref.as_non_null, after it is moved
    ;; outside of the any.convert_extern.
    (drop
      (ref.cast (ref null $array)
        (any.convert_extern
          (ref.as_non_null
            (local.get $ext)
          )
        )
      )
    )
  )
)
