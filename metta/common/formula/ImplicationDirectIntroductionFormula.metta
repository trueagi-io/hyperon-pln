;; Formula for the inductive Implication Direct Introduction rule.

;; Import modules
!(import! &self ../truthvalue/TruthValue.metta)

;; Alternate implication direct introduction formula assuming Boolean
;; evidence.  Base case, meaning there is only one piece of evidence.
(: direct-introduction-base-formula (-> Bool Bool TruthValue))
(= (direct-introduction-base-formula False $_) (STV 1 0))
(= (direct-introduction-base-formula True $qa)
   (STV (bool->number $qa) (count->confidence 1)))

;; Alternate implication direct introduction formula.  Inductive case,
;; meaning the piece of evidence gets aggregated to another truth
;; value.
(: direct-introduction-recursive-formula (-> Bool Bool TruthValue TruthValue))
(= (direct-introduction-recursive-formula False $_ (STV $PQs $PQc)) (STV $PQs $PQc))
(= (direct-introduction-recursive-formula True False (STV $PQs $PQc))
   (STV (inc-count-strength $PQs $PQc) (inc-confidence $PQc)))
(= (direct-introduction-recursive-formula True True (STV $PQs $PQc))
   (STV $PQs (inc-confidence $PQc)))
