;; Test Implication Direct Introduction DTL Rule
!(import! &self "ImplicationDirectIntroductionDTL.metta")

;; Test axiom
!("========== Test axiom ==========")
(: test_axiom (-> (≞ (→ P Q) (ETV Empty (PrCnt 1 0)))))
(= (test_axiom) IDIAxiom)
!(test_axiom)

;; NEXT: find out why the following also works
;; (: test_axiom (≞ (→ P Q) (ETV Empty (PrCnt 0 0))))
;; (= (test_axiom) IDIAxiom)
;; !(test_axiom)

;; Test inductive rule
!("========== Test inductive rule ==========")
(: test_induction (-> (≞ (→ P Q) $tv)))
(= (test_induction) ;; NEXT
;; !(let* (($pa (≞ (P 42) (Bl True)))
;;         ($qa (≞ (Q 42) (Bl False)))
;;         ($pq (≞ (→ P Q) (ETV Empty (PrCnt 1 0))))
;;         ($an (∉ 42 Empty)))
;;    (match &self (⊢ $pa $qa $pq $an $conclusion) $conclusion))
