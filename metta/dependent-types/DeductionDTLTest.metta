;; type definitions checker
!(pragma! type-check auto)

;; equality type definition
(: = (-> $t $t Type))

;; Import the rule
!(import! &self DeductionDTL.metta)
!(import! &self ../common/MeasEq.metta)

(: Predicate Type)
(: → (-> Predicate Predicate Type))
(: P Predicate)
(: R Predicate)
(: Q Predicate)
(: p (≞ P (PrCnt 1 0.1)))
(: r (≞ R (PrCnt 1 0.1)))
(: q (≞ Q (PrCnt 1 0.1)))
(: pq (≞ (→ P Q) (PrCnt 1 0.5)))
(: qr (≞ (→ Q R) (PrCnt 1 0.5)))

;; P→R prf
(: pr_prf (-> (≞ (→ P R) $tv)))
(= (pr_prf) (ImplicationDeduction p q r pq qr))
!(pr_prf)
!(get-type pr_prf)
