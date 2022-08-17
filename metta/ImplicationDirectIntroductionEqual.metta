;; MeTTa port of the Implication Direct Introduction PLN rule, encoded
;; as a non-determinist equality, =
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

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; To deal with an abritrary number of pieces of evidence the rule is
;; defined inductively.

;; Base case (axiomatic rule):
;;
;; p→q ≞ (ETV Empty (PrCnt 1 0))
;;
;; Directly present in the atomspace.
(≞ (→ $p $q) (ETV Empty (PrCnt 1 0)))

;; NEXT

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
   (≞ (→ $p $q) (ETV (insert $a $ev) (formula $ptv $qtv $pqtv))))

;; Rule formula, where tv, the resulting truth value is calculated as
;; follows
;;
;; tv = (pos_cnt + pb*qb) / (cnt + pb)
;;
;; where pos_cnt is the positive count of pqtv
;;       cnt is the total count of pqtv
;;       pb is 1 if patv is (Bl True), 0 otherwise
;;       qb is 1 if qatv is (Bl True), 0 otherwise
;;
;; For now it is assumed that patv and qatv are boolean truth values.
(= (formula $ptv $qtv $pqtv)
   (let* (($pb (mode $ptv))
          ($qb (mode $qtv))
          ($cnt (+ (count $pqtv) $pb)))
     (if (< 0 $cnt)
         (PrCnt (/ (+ (pos_count $pqtv) (* $pb $qb)) $cnt) $cnt)
         (PrCnt 1 0))))



;; See MeTTa examples such as b2_backchain.metta, b3_direct.metta,
;; b4_nonterm.metta, c3_pln_stv.metta, d1_custom_types.metta and
;; d3_typed_pln.metta for inspiration.
