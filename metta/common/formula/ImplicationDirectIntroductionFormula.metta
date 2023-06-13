;; Formula for the inductive Implication Direct Introduction rule.

;; Import modules
!(import! &self ../truthvalue/TruthValue.metta)

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
         (STV (/ (+ (pos_count $pqtv) (* $pb $qb)) $cnt) (count->confidence $cnt))
         (STV 1 0))))

;; Alternate implication direct introduction formula
(: direct-introduction-formula (-> Bool Bool TruthValue TruthValue))
(= (direct-introduction-formula False $_ (STV $PQs $PQc)) (STV $PQs $PQc))
(= (direct-introduction-formula True False (STV $PQs $PQc))
   (STV (inc-count-strength $PQs $PQc) (inc-confidence $PQc)))
(= (direct-introduction-formula True True (STV $PQs $PQc))
   (STV $PQs (inc-confidence $PQc)))
