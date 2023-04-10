; DeductionMatch and ImplicationDirectionIntroductionMatch

!(import! &self ImplicationDirectIntroductionMatch.metta)
!(import! &self DeductionMatch.metta)

; Use IDI rule to infer P->Q based on the following,
(≞ (P 42) (Bl True))
(≞ (Q 42) (Bl False))
(∉ 42 Empty)

; Q->R is already in the atomspace
(≞ (→ Q R) (PrCnt 1 0.5))

; Predicates
(≞ P (PrCnt 1 0.1))
(≞ Q (PrCnt 1 0.5))
(≞ R (PrCnt 1 0.1))

; Matching query to do IDI and deduction rules
!(let* (($prem1 (≞ $p $ptv))
        ($prem2 (≞ $q $qtv))
        ($prem3 (≞ $r $rtv))
        ($prem4 (≞ ($p $a) $patv))
        ($prem5 (≞ ($q $a) $qatv))
        ($prem6 (∉ $a $ev))
        ($prem7 (≞ (→ $q $r) $qrtv)))
    (match &self
     ;; Premises
     (, $prem1 $prem2 $prem3 $prem4 $prem5 $prem6 $prem7)
     ;; Conclusion 
     (deduction $prem1 $prem2 $prem3 (idi_induction $prem4 $prem5 (idi_axiom) $prem6) $prem7)))
