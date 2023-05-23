;; Type definitions checker
!(pragma! type-check auto)

;; Equality type definition
(: = (-> $t $t Type))

;; Import the rule
!(import! &self DeductionDTL.metta)

;; Background knowledge
(: Predicate Type)
(: → (-> Predicate Predicate Type))
(: P Predicate)
(: Q Predicate)
(: R Predicate)
(: Pm (≞ P (STV 1 0.1)))
(: Qm (≞ Q (STV 1 0.1)))
(: Rm (≞ R (STV 1 0.1)))
(: PQm (≞ (→ P Q) (STV 1 0.5)))
(: QRm (≞ (→ Q R) (STV 1 0.5)))

;; Test deduction rule
;;
;; Build the following inference tree
;;
;; ----------(Pm)  ----------(Qm)  ----------(Rm)  --------------(PQm)  --------------(QRm)
;; P ≞ <1 0.1>     Q ≞ <1 0.1>     R ≞ <1 0.1>     P → Q ≞ <1 0.5>      Q → R ≞ <1 0.5>
;; -----------------------------------------------------------------------------------(Deduction)
;;                                         P → R ≞ $tv
(: deduction_prf (≞ (→ P R) $tv))
(= deduction_prf (Deduction Pm Qm Rm PQm QRm))
!(deduction_prf)
!(get-type deduction_prf)
