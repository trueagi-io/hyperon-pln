
!(import! &self "DeductionFormula.metta")

(: ImplicationDeduction
    (-> (≞ $p $ptv)
        (≞ $q $qtv)
        (≞ $r $rtv)
        (≞ (→ $p $q) $pqtv)
        (≞ (→ $q $r) $qrtv)
        (≞ (→ $p $r) (ded_formula ($ptv $qtv $rtv $pqtv $qrtv)))))

;; Test 
(: implicationDeduction_pfr (≞ (→ P R) $tv))

;; kb
(= (P) (≞ P (PrCnt 1 0.1)))
(= (Q) (≞ Q (PrCnt 1 0.1)))
(= (R) (≞ R (PrCnt 1 0.1)))
(= (PQ) (≞ (→ P Q) (PrCnt 1 0.5)))
(= (QR) (≞ (→ Q R) (PrCnt 1 0.5)))

(= implicationDeduction_pfr (ImplicationDeduction (P) (Q) (R) (PQ) (QR)))

!(implicationDeduction_pfr)
