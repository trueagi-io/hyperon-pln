;; Test Implication Direct Introduction DTL Rule

;; Import modules
!(import! &self ImplicationDirectIntroductionDTL.metta)
!(import! &self ../common/In.metta)  ; NEXT
!(import! &self ../synthesis/Synthesize.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose ((: P2 (⊷ P 2 True))
                    (: Q2 (⊷ Q 2 False))
                    (: P7 (⊷ P 7 True))
                    (: Q7 (⊷ Q 7 True)))))
;; Axioms are placed in the kb as well
(= (kb) (implication-direct-introduction-axiom))
(= (kb) (nothing-in-empty-axiom))

;; Rule base
(: rb (-> Atom))
(= (rb) (implication-direct-introduction-rule))

;; Test axiom
! "===== Test axiom ====="
(: axiom_prf (≞ (→ P Q) (ETV ∅ (STV 1 0))))
(= axiom_prf IDIAxiom)
!(axiom_prf)
!(get-type axiom_prf)

;; Test inductive rule
;;
;; Build the following inference tree
;;
;; --------(P2)  --------(Q2)  -----------------(IDIAxiom)  ----(NothingInEmpty)
;; (P 2) = ⊤      (Q 2) = ⊥    P → Q ≞ (∅, <1 0>)           2 ∉ ∅
;; -------------------------------------------------------------(IDIInduction)
;;                             P → Q ≞ ({2}, <0 0.5>)
;; --------(P7)  --------(Q7)        |                          NEXT
;; (P 7) = ⊤     (Q 7) = ⊤           |                         7 ∉ {2}
;; ------------------------------------------------------------------(IDIInduction)
;;                             P → Q ≞ $etv
! "===== Test inductive rule ====="
(: induction_prf (≞ (→ P Q) $etv))
(= induction_prf (IDIInduction P42m Q42m IDIAxiom NothingInEmpty))
!(induction_prf)
!(get-type induction_prf)

;; Test synthesizer
! "===== Test synthesizer on kb ====="
!(synthesize (: $proof (⊷ P 2 $p2)) Z kb rb)
!(synthesize (: $proof (⊷ Q 2 $q2)) Z kb rb)

! "===== Test synthesizer on axiom ====="
!(synthesize (: $proof (≞ (→ P Q) $etv)) Z kb rb)

! "===== Test synthesizer on induction rule ====="
!(synthesize (: $proof (≞ (→ P Q) $etv)) (S Z) kb rb)
