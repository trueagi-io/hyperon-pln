;; Inference rules to operate on SUMO

;; Modus ponens with conjunction as implicant
(: MPCI (->
         ;; Premises
         (⟹ (∧ $x $y) $z)
         (∧ $x $y)
         ;; Conclusion
         $z))
