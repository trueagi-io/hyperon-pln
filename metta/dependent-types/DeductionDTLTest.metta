;; Type definitions checker
!(pragma! type-check auto)

;; Equality type definition
(: = (-> $t $t Type))

;; Import modules
!(import! &self DeductionDTL.metta)
!(import! &self ../synthesis/Synthesize.metta)
!(import! &self ../common/Record.metta)

;; Knowledge base
(: Predicate Type)
(: → (-> Predicate Predicate Type))
(: P Predicate)
(: Q Predicate)
(: R Predicate)
(: kb (-> Atom))
(= (kb) (superpose ((: Pm (≞ P (STV 1 0.1)))
                    (: Qm (≞ Q (STV 1 0.1)))
                    (: Rm (≞ R (STV 1 0.1)))
                    (: PQm (≞ (→ P Q) (STV 1 0.5)))
                    (: QRm (≞ (→ Q R) (STV 1 0.5))))))

;; Rule base
;; (: rb (-> Atom))
(= (rb)
   (: Deduction
    (-> (≞ $p $ptv)
        (≞ $q $qtv)
        (≞ $r $rtv)
        (≞ (→ $p $q) $pqtv)
        (≞ (→ $q $r) $qrtv)
        (≞ (→ $p $r) $tv)) (ded_formula $ptv $qtv $rtv $pqtv $qrtv)))))
;; (match &self (: Deduction $type) (: Deduction $type)))

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

;; Test chainer
!(record synthesize ((: $proof (≞ (→ P Q) $tv)) Z kb rb))
!(record synthesize ((: $proof (≞ (→ Q R) $tv)) Z kb rb))
!(record synthesize ((: $proof (≞ (→ P R) $tv)) (S Z) kb rb))
