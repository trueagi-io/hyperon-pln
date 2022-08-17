;;;;;;;;;;;;;;;;;;;;;;
;; Truth Value Type ;;
;;;;;;;;;;;;;;;;;;;;;;

;; TruthValue type
(: TruthValue Type)

;; Boolean TV constructor
(: Bl (-> Bool TruthValue))

;; First order probability TV constructor, i.e. mere probability.
(: Pr (-> Number TruthValue))

;; Second order probability TV constructor, i.e. probability and
;; count.  The second order probability is distributed according to a
;; beta distribution.  The first argument of the constructor
;; represents the mode of the second order distribution.
;; TODO: instead of PrCnt maybe we want positive and negative counts.
(: PrCnt (-> Number Number TruthValue))

;; Evidential truth value constructor.  Takes a set of pieces of
;; evidence ascribed to a truth value to form an evidential truth
;; value, itself of type TruthValue.
(: ETV (-> (Set $a) TruthValue TruthValue))

;; TODO: at that point it is unclear how granular types should be.
;; That is should we define Evidence as
;;
;; (: Evidence Type)
;;
;; or
;;
;; (: Evidence (-> (Set $a) Type))
;;
;; We chose the coarsest definitions for now as it is probably simpler
;; to begin with, but we should keep in mind that it might not be
;; enough.

;; For now the underlying beta distributions have a Jeffreys prior,
;; i.e. the prior alpha and beta are 0.5.
(: prior_alpha (-> Number))
(= (prior_alpha) 0.5)
(: prior_beta (-> Number))
(= (prior_beta) 0.5)

;; Return the first order probability mode of the second order
;; distribution associated to a truth value.
(: mode (-> TruthValue Number))
(= (mode (Bl True)) 1.0)
(= (mode (Bl False)) 0.0)
(= (mode (Pr $pr)) $pr)
(= (mode (PrCnt $pr $_)) $pr)
(= (mode (ETV $ev $tv)) (mode $tv))

;; Return the total count of a truth value.  For truth values not
;; capturing a notion of confidence, such as Bl or Pr then the count
;; is assumed to be a very large number (cause +inf does not seem to
;; be supported at the moment).  For truth values capturing a notion
;; of confidence, such as PrCnt, the total count is the count
;; component of the truth value.
(: count (-> TruthValue Number))
(= (count (Bl $_)) 10000000.0)
(= (count (Pr $_)) 10000000.0)
(= (count (PrCnt $_ $cnt)) $cnt)
(= (count (ETV $ev $tv)) (count $tv))

;; Return the positive count of a truth value.
(: pos_count (-> TruthValue Number))
(= (pos_count $tv) (* (mode $tv) (count $tv)))

;; Return the negative count of a truth value.
(: neg_count (-> TruthValue Number))
(= (neg_count $tv) (* (- 1 (mode $tv)) (count $tv)))

;; Return the posterior alpha of a truth value
(: post_alpha (-> TruthValue Number))
(= (post_alpha $tv) (+ (prior_alpha) (pos_count $tv)))

;; Return the posterior beta of a truth value
(: post_beta (-> TruthValue Number))
(= (post_beta $tv) (+ (prior_beta) (neg_count $tv)))

;; Return the first order probability mean of the second order
;; distribution associated to a truth value.  For truth values not
;; capturing a notion of confidence, such as Bl or Pr then the
;; confidence is assumed to be 1.0.  For truth values capturing a
;; notion of confidence, such as PrCnt, a beta distribution is
;; assumed.
(: mean (-> TruthValue Number))
(= (mean (Bl True)) 1.0)
(= (mean (Bl False)) 0.0)
(= (mean (Pr $pr)) $pr)
(= (mean (PrCnt $pr $cnt))
   (let* (($a (post_alpha (PrCnt $pr $cnt)))
          ($b (post_beta (PrCnt $pr $cnt))))
     (\ $a (+ $a $b))))
(= (mean (ETV $ev $tv)) (mean $tv))

;; Return the confidence of a truth value.  For truth values not
;; capturing a notion of confidence, such as Bl or Pr then the
;; confidence is assumed to be 1.0.  For truth values capturing a
;; notion of confidence, such as PrCnt, the formula to convert a count
;; into confidence is as follows
;;
;; confidence = count / (count + 1)
(: confidence (-> TruthValue Number))
(= (confidence (Bl $_)) 1.0)
(= (confidence (Pr $_)) 1.0)
(= (confidence (PrCnt $_ $cnt)) (/ $cnt (+ $cnt 1)))
(= (confidence (ETV $ev $tv)) (confidence $tv))
