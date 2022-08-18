;; Formula for the inductive Implication Direct Introduction rule.
;;
;; Given the following rule
;;
;; (p a) ≞ patv
;; (q a) ≞ qatv
;; p→q ≞ (ETV ev pqtv)
;; a ∉ ev
;; ⊢
;; p→q ≞ (ETV (insert a ev) tv)
;;
;; The resulting truth value is calculated as follows
;;
;; tv = (pos_cnt + pb*qb) / (cnt + pb)
;;
;; where pos_cnt is the positive count of pqtv
;;       cnt is the total count of pqtv
;;       pb is the mode of patv, i.e. 1 if patv is True, 0 otherwise
;;       qb is the mode of qatv, i.e. 1 if qatv is True, 0 otherwise
(= (idi_formula $patv $qatv $pqtv)
   (let* (($pb (mode $patv))
          ($qb (mode $qatv))
          ($cnt (+ (count $pqtv) $pb)))
     (if (< 0 $cnt)
         (PrCnt (/ (+ (pos_count $pqtv) (* $pb $qb)) $cnt) $cnt)
         (PrCnt 1 0))))
