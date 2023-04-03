; DeductionMatch and ImplicationDirectionIntroductionMatch

!(import! &self ImplicationDirectIntroductionMatch.metta)
!(import! &self ../common/DeductionFormula.metta)

; P->Q is obtained with ImplicationDirectIntroduction
(≞ (P 42) (Bl True))
(≞ (Q 42) (Bl False))
(≞ (→ P Q) (ETV Empty (PrCnt 1 0)))
(∉ 42 Empty)

; Q->R is already in the atomspace
; Deduction can take the output of 1. using let*

(≞ P (PrCnt 1 0.1))
(≞ Q (PrCnt 1 0.5))
(≞ R (PrCnt 1 0.1))
(≞ (→ Q R) (PrCnt 1 0.5))

;; TODO: implement it in evidentialTV file.
(= (TV (≞ $e (ETV $s $tv))) $tv)

!(case (idi_induction &self) (
   ($x (match &self
      ;; Premises
      (, (≞ $p $ptv)
         (≞ $q $qtv)
         (≞ $r $rtv)
         (≞ (→ $p $q) $pqtv)
         (≞ (→ $q $r) $qrtv))
      ;; Conclusion
      (≞ (→ $p $r) (ded_formula $ptv $qtv $rtv (TV $x) $qrtv))))
   (%void% None)
))
