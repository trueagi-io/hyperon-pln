;; Test Deduction DTL

!(import! &self "DeductionDTL.metta")

(: pr_prf (-> (≞ (→ P R) $tv)))

;; kb
(= (P) (≞ P (PrCnt 1 0.1)))
(= (Q) (≞ Q (PrCnt 1 0.1)))
(= (R) (≞ R (PrCnt 1 0.1)))
(= (PQ) (≞ (→ P Q) (PrCnt 1 0.5)))
(= (QR) (≞ (→ Q R) (PrCnt 1 0.5)))

(= (pr_prf) (ImplicationDeduction (P) (Q) (R) (PQ) (QR)))

!(pr_prf)

;; more kb
(= (S) (≞ S (PrCnt 1 0.1)))
(= (RS) (≞ (→ R S) (PrCnt 1 0.5)))

(: ps_prf (-> (≞ (→ P S) $tv)))

(= (ps_prf) (ImplicationDeduction (P) (R) (S) (pr_prf) (RS)))

!(ps_prf)
