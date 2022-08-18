;; MeTTa port of the Implication Direct Introduction PLN rule, encoded
;; as the entail relationship, ⊢
;;
;; (P a₁) ≞ p₁
;; ...
;; (P aₙ) ≞ pₙ
;; (Q a₁) ≞ q₁
;; ...
;; (Q aₙ) ≞ qₙ
;; ⊢
;; P→Q ≞ tv
;;
;; where pᵢ (resp. qᵢ) are of boolean type representing whether (P aᵢ)
;; (resp. (Q aᵢ)) has been observed as True or False, and tv
;; represents the resulting truth value of the conclusion.

;; Import modules
!(import! &self "TruthValue.metta")
!(import! &self "Set.metta")
!(import! &self "ImplicationDirectIntroductionFormula.metta")

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; To deal with an abritrary number of pieces of evidence the rule is
;; defined inductively.

;; Base case (axiomatic rule):
;;
;; ⊢ p→q ≞ (ETV Empty (PrCnt 1 0))
(⊢ (≞ (→ $p $q) (ETV Empty (PrCnt 1 0))))

;; Recursive case (inductive rule):
;;
;; (p a) ≞ patv
;; (q a) ≞ qatv
;; p→q ≞ (ETV ev pqtv)
;; a ∉ ev
;; ⊢
;; p→q ≞ (ETV (insert a ev) tv)
;;
;; where tv is calculated as defined further below.
(⊢ ;; Premises
   (≞ ($p $a) $patv)
   (≞ ($q $a) $qatv)
   (≞ (→ $p $q) (ETV $ev $pqtv))
   (∉ $a $ev)
   ;; Conclusion
   (≞ (→ $p $q) (ETV (insert $a $ev) (idi_formula $patv $qtv $pqtv))))

;; NEXT: add equality like
;;
;; (= (⊢ ....) ....)
;;
;; to relate inference tree and inference rules
