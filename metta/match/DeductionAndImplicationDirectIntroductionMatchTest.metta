; DeductionMatch and ImplicationDirectionIntroductionMatch

!(import! &self ImplicationDirectIntroductionMatch.metta)
!(import! &self DeductionFormula.metta)

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

(let* (($pq (idi_induction)))
       (match &self
            ;; Premises
            (, (≞ $p $ptv)
               (≞ $q $qtv)
               (≞ $r $rtv)
               $pq
               (≞ (→ $q $r) $qrtv))
            ;; Conclusion
            (≞ (→ $p $r) (ded_formula $ptv $qtv $rtv $pqtv $qrtv))))
