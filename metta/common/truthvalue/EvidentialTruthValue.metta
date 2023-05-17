;; Evidential truth value type. Represent a truth value alongside its
;; evidence.

!(import! &self TruthValue.metta)
!(import! &self ../Set.metta)

;;;;;;;;;;
;; Type ;;
;;;;;;;;;;

(: EvidentialTruthValue Type)

;;;;;;;;;;;;;;;;;;
;; Constructor ;;
;;;;;;;;;;;;;;;;;;

;; Takes a set of pieces of evidence ascribed to a truth value to form
;; an evidential truth value.
(: ETV (-> (Set $a) TruthValue EvidentialTruthValue))

;;;;;;;;;;;;;
;; Methods ;;
;;;;;;;;;;;;;

;; Access the truth value of an evidential truth value.
(: tv (-> EvidentialTruthValue TruthValue))
(= (tv (ETV $ev $tv)) $tv)

;; Return the first order probability mode of the second order
;; distribution associated to an evidential truth value.
(: etv_mode (-> EvidentialTruthValue Number))
(= (etv_mode (ETV $ev $tv)) (mode $tv))

;; Return the total count of an evidential truth value.
(: etv_count (-> EvidentialTruthValue Number))
(= (etv_count (ETV $ev $tv)) (count $tv))

;; Return the positive count of a truth value.
(: etv_pos_count (-> EvidentialTruthValue Number))
(= (etv_pos_count (ETV $ev $tv)) (* (mode $tv) (count $tv)))

;; Return the negative count of a truth value.
(: etv_neg_count (-> EvidentialTruthValue Number))
(= (etv_neg_count (ETV $ev $tv)) (* (- 1 (mode $tv)) (count $tv)))

;; Return the posterior alpha of a truth value
(: etv_post_alpha (-> EvidentialTruthValue Number))
(= (etv_post_alpha (ETV $ev $tv)) (+ (prior_alpha) (pos_count $tv)))

;; Return the posterior beta of a truth value
(: etv_post_beta (-> EvidentialTruthValue Number))
(= (etv_post_beta (ETV $ev $tv)) (+ (prior_beta) (neg_count $tv)))

;; Return the first order probability mean of the second order
;; distribution associated to an evidential truth value.
(: etv_mean (-> EvidentialTruthValue Number))
(= (etv_mean (ETV $ev $tv)) (mean $tv))

;; Return the confidence of an evidential truth value.
(: etv_confidence (-> EvidentialTruthValue Number))
(= (etv_confidence (ETV $ev $tv)) (confidence $tv))
