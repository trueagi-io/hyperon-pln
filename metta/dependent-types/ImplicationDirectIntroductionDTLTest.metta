;; Test Implication Direct Introduction DTL Rule
!(import! &self ImplicationDirectIntroductionDTL.metta)

;; Test axiom
!("========== Test axiom ==========")
(: axiom_prf (≞ (→ P Q) (ETV Empty (PrCnt 1 0))))
(= axiom_prf IDIAxiom)
!(axiom_prf)

;; Background knowledge
(: P42T (≞ (P 42) (Bl True)))
(: Q42F (≞ (Q 42) (Bl False)))

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
(= induction_prf (IDIInduction P42 NQ42 IDIAxiom NotInEmpty))
!(induction_prf)
