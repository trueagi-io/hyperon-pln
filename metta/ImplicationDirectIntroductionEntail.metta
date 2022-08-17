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

;; Import TruthValue
!(import! &self "TruthValue.metta")

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
;; where tv is calculated as follows
;;
;; tv = (pos_cnt + pb*qb) / (cnt + pb)
;;
;; where pos_cnt is the positive count of pqtv
;;       cnt is the total count of pqtv
;;       pb is 1 if patv is (Bl True), 0 otherwise
;;       qb is 1 if qatv is (Bl True), 0 otherwise
;;
;; For now it is assumed that patv and qatv are boolean truth values.
(⊢ ;; Premises
   (≞ ($p $a) $patv)
   (≞ ($q $a) $qatv)
   (≞ (→ $p $q) (ETV $ev $pqtv))
   (∉ $a $ev)
   ;; Conclusion
   (≞ (→ $p $q) (ETV (insert $a $ev) (formula $ptv $qtv $pqtv))))

;; Define rule formula (see comment above)
(= (formula $ptv $qtv $pqtv)
   (let $pb (mode $ptv)
     (let $qb (mode $qtv)
       (/ (+ (pos_count $pqtv) (* $pb $qb))
          (+ (count $pqtv) $pb)))))

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; KB
(= (PA) (≞ (P A) (Bl True)))
(= (QA) (≞ (Q A) (Bl False)))

;; Formula
!(formula True False)

;; Forward inference step
!(let $pa (PA)
   (let $qa (QA)
     (match &self (⊢ $pa $qa $conclusion) $conclusion)))

;; Backward inference step
!(match &self (⊢ $p1 $p2 (≞ (→ P Q) $tv)) (S $p1 $p2 $tv))
