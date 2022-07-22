;; Define homogeneous type equality
(: === (-> $a $a Type))
(: Refl (-> $x (=== $x $x)))

;; Test
!(: (Refl 42) (=== 42 42))
!(: (Refl True) (=== True True))
!(: (Refl "fourtytwo") (=== "fourtytwo" "fourtytwo"))

;; Anti-test
!(: (Refl True) (=== True False))
!(: (Refl "fourtytwo") (=== "fourtytwo" 42))
