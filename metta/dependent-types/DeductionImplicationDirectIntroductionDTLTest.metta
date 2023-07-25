; Test DeductionDTL and ImplicationDirectionIntroductionDTL rules

;; Improt the rules
!(import! &self ImplicationDirectIntroductionDTL.metta)
!(import! &self DeductionDTL.metta)
;; !(import! &self ../common/In.metta)  ; NEXT
!(import! &self ../synthesis/Synthesize.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose ((: Pm (≞ P (STV 0.2 0.3)))
                    (: Qm (≞ Q (STV 0.3 0.2)))
                    (: Rm (≞ R (STV 0.4 0.1)))
                    (: P42 (≘ P 42 True))
                    (: Q42 (≘ Q 42 True))
                    (: QRm (≞ (→ Q R) (STV 0.9 0.7))))))
;; All axioms are placed in the kb as well
(= (kb) (implication-direct-introduction-axiom))
(= (kb) (: NothingInEmpty (∉ $x ∅))) ; NEXT: replace by (nothing-in-empty-axiom))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose ((deduction-rule)
                    (implication-direct-introduction-rule)
                    (evidence-elimination-rule))))

;; Test a combination of deduction and implication direct introduction
;;
;; Build the following inference tree
;;
;;                                ---------(P42)  ---------(Q42)  -----------------(IDIAxiom) -----(NothingInEmpty)
;;                                (P 42) = ⊤      (Q 42) = ⊤      P → Q ≞ (∅, <1 0>)          42 ∉ ∅
;;                                ------------------------------------------------------------------(IDIInduction)
;;                                                    P → Q ≞ (ETV $evidence $pqtv)
;; ------------(Pm) ------------(Qm) ------------(Rm) ----------------------------(EvidenceElimination) ----------------(QRm)
;; P ≞ <0.2 0.3>    Q ≞ <0.3 0.2>    R ≞ <0.4 0.1>            P → Q ≞ $pqtv                             Q → R ≞ <0.9 0.7>
;; ---------------------------------------------------------------------------------------------------------------------(Deduction)
;;                                                            P → R ≞ $prtv
(: deduction_idi_prf (≞ (→ P Q) $tv))
(= deduction_idi_prf (Deduction Pm Qm Rm (IDIInduction P42m Q42m IDIAxiom NotInEmpty) QRm))
! deduction_idi_prf
!(get-type deduction_idi_prf)

! "===== Test synthesizer on axiom ====="
!(synthesize (: $proof (≞ (→ P R) $etv)) Z kb rb)

! "===== Test synthesizer on implication direct introduction rule ====="
!(synthesize (: $proof (≞ (→ P Q) $etv)) (S Z) kb rb)

! "===== Test synthesizer on evidence elimination rule ====="
!(synthesize (: (EvidenceElimination $proof) (≞ (→ P Q) $tv)) (S Z) kb rb)

! "===== Test synthesizer on deduction rule ====="
!(synthesize (: $proof (≞ (→ P R) $tv)) (fromNumber 2) kb rb)

;; ! "===== Test synthesizer on deduction and implication direct introduction rules ====="
!(synthesize (: (Deduction Pm Qm Rm $p4 $p5) (≞ (→ P R) $tv)) (fromNumber 3) kb rb)
