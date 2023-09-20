;; Inference rules to operate on SUMO

;; Conjunction Introduction
(: ConjunctionIntroduction
   (->
    ;; Premises
    $x
    $y
    (∧ $x $y)))

;; Modus ponens
(: ModusPonens
   (->
    ;; Premises
    (⟹ $x $y)
    $x
    ;; Conclusion
    $y))
