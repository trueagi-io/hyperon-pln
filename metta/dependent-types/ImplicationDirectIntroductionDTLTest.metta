;; Test Implication Direct Introduction DTL Rule
!(import! &self ImplicationDirectIntroductionDTL.metta)

;; Test axiom
!("========== Test axiom ==========")
(: axiom_prf (≞ (→ P Q) (ETV Empty (PrCnt 1 0))))
(= axiom_prf IDIAxiom)
!(axiom_prf)
!(get-type axiom_prf)

;; Background knowledge
(: P42m (≞ (P 42) (Bl True)))
(: Q42m (≞ (Q 42) (Bl False)))

;; Test inductive rule
;;
;; Build the following inference tree
;;
;; ----------(P42T)   ----------(Q42F)   ------------------(IDIAxiom)    ------(NotInEmpty)
;; (P 42) ≞ ⊤         (Q 42) ≞ ⊥         P → Q ≞ (∅, <1 0>)              42 ∉ ∅
;; -----------------------------------------------------------------------------------------(IDIInduction)
;;                                          P → Q ≞ $etv
!("========== Test inductive rule ==========")
(: induction_prf (≞ (→ P Q) $etv))
(= induction_prf (IDIInduction P42m Q42m IDIAxiom NotInEmpty))
!(induction_prf)
!(get-type induction_prf)
