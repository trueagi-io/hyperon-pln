;; Import ===
!(import! &self EqualityType.metta)

;; Define various subterms
(: TTrue True)
(: T42 42)

;; Define dummy functions to type check equality type
(: foo (-> (=== 42 42) Bool))
(= (foo $prf) True)
(: bar (-> (=== True True) Bool))
(= (bar $prf) True)
(: baz (-> (=== 42 True) Bool))
(= (baz $prf) False)

;; Test equality type
!(foo (Refl T42))
!(bar (Refl T42))
!(bar (Refl TTrue))
!(baz (Refl T42))
