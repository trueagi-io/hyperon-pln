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
(: p (≞ P (STV 1 0.1)))
(: q (≞ Q (STV 1 0.1)))
(: r (≞ R (STV 1 0.1)))
(: pq (≞ (→ P Q) (STV 1 0.5)))
(: qr (≞ (→ Q R) (STV 1 0.5)))

;; Test deduction rule
;;
;; Build the following inference tree
;;
;; ----------(p)  ----------(q)  ----------(r)  --------------(pq)  --------------(qr)
;; P ≞ <1 0.1>    Q ≞ <1 0.1>    R ≞ <1 0.1>    P → Q ≞ <1 0.5>     Q → R ≞ <1 0.5>
;; ---------------------------------------------------------------------- ---------(Deduction)
;;                                     P → R ≞ $tv
(: pr (≞ (→ P R) $tv))
(= pr (Deduction p q r pq qr))
!(pr)
!(get-type pr)
