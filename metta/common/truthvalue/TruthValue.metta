;; Truth value type definition

;; Import modules
!(import! &self ../Num.metta)

;;;;;;;;;;
;; Type ;;
;;;;;;;;;;

(: TruthValue Type)

;;;;;;;;;;;;;;;;;;
;; Constructors ;;
;;;;;;;;;;;;;;;;;;

;; Boolean TV constructor
;; TODO: alternatively we could have (: ⊤ TruthValue) and (: ⊥ TruthValue)
(: Bl (-> Bool TruthValue))

;; First order probability TV constructor, i.e. mere probability.
(: Pr (-> Number TruthValue))

;; Second order probability TV constructor, i.e. probability and
;; count.  The second order probability is distributed according to a
;; beta distribution.  The first argument of the constructor
;; represents the mode of the second order distribution.
(: PrCnt (-> Number Number TruthValue))

;; Simple Truth Value.  A Second order probability TV constructor,
;; i.e. probability and confidence.  The probability is in fact the
;; mode of the corresponding beta distribution.
(: STV (-> Number Number TruthValue))

;;;;;;;;;;;;;;;
;; Constants ;;
;;;;;;;;;;;;;;;

;; For now the underlying beta distributions have a Jeffreys prior,
;; i.e. the prior alpha and beta are 0.5.
(: prior_alpha (-> Number))
(= (prior_alpha) 0.5)
(: prior_beta (-> Number))
(= (prior_beta) 0.5)

;; Lookahead
(: lookahead (-> Number))
(= (lookahead) 1.0)

;; Maximum supported count (till +inf is supported, possibly).
(: max-count (-> Number))
(= (max-count) 1e9)

;;;;;;;;;;;;;
;; Methods ;;
;;;;;;;;;;;;;

;; Convert count to confidence using the formula
;;
;; confidence = count / (count + lookahead)
(: count->confidence (-> Number Number))
(= (count->confidence $cnt) (/ $cnt (+ $cnt (lookahead))))

;; Convert confidence to count using the formula
;;
;; count = (confidence * lookahead) / (1 - confidence)
(: confidence->count (-> Number Number))
(= (confidence->count $conf) (if (approxEq 1.0 $conf 1e-9)
                                 (max-count)
                                 (/ (* $conf (lookahead)) (- 1.0 $conf))))

;; Increment the given count by 1
(: inc-count (-> Number Number))
(= (inc-count $cnt) (+ 1 $cnt))

;; Increment the corresponding count of the given confidence by 1 and
;; return the confidence of that corresponding incremented count.
(: inc-confidence (-> Number Number))
(= (inc-confidence $conf) (count->confidence (inc-count (confidence->count $conf))))

;; Return the strength of a truth value, given that its count has been
;; incremented by one but its positive count has not.
;;
;; The formula is derived from new_s = s*cnt / (cnt + 1), where cnt is
;; the count of the original truth value, that is cnt = c*k / (1-c).
;; Thus
;;
;; new_s = (s*c*k / (1-c)) / (c*k / (1-c) + 1)
;;       = (s*c*k / (1-c)) / ((c*k + 1-c) / (1-c))
;;       = (s*c*k) / (c*k + 1-c)
(: inc-count-strength (-> Number Number Number))
(= (inc-count-strength $s $c)
   (/ (* $s (* $c (lookahead))) (- (+ (* $c (lookahead)) 1) $c)))

;; Return the first order probability mode of the second order
;; distribution associated to a truth value.
(: mode (-> TruthValue Number))
(= (mode (Bl True)) 1.0)
(= (mode (Bl False)) 0.0)
(= (mode (Pr $pr)) $pr)
(= (mode (PrCnt $pr $_)) $pr)
(= (mode (STV $pr $_)) $pr)

;; Return the total count of a truth value.  For truth values not
;; capturing a notion of confidence, such as Bl or Pr then the count
;; is assumed to be a very large number (cause +inf does not seem to
;; be supported at the moment).  For truth values capturing a notion
;; of confidence, such as PrCnt, the total count is the count
;; component of the truth value.
(: count (-> TruthValue Number))
(= (count (Bl $_)) (max-count))
(= (count (Pr $_)) (max-count))
(= (count (PrCnt $_ $cnt)) $cnt)
(= (count (STV $_ $conf)) (confidence->count $conf))

;; Return the confidence of a truth value.  For truth values not
;; capturing a notion of confidence, such as Bl or Pr then the
;; confidence is assumed to be 1.0.  For truth values capturing a
;; notion of confidence, such as PrCnt, the formula to convert a count
;; into confidence is as follows
;;
;; confidence = count / (count + lookahead)
(: confidence (-> TruthValue Number))
(= (confidence (Bl $_)) 1.0)
(= (confidence (Pr $_)) 1.0)
(= (confidence (PrCnt $_ $cnt)) (count->confidence $cnt))
(= (confidence (STV $_ $conf)) $conf)

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
     (/ $a (+ $a $b))))
(= (mean (STV $pr $conf))
   (let* (($a (post_alpha (STV $pr $conf)))
          ($b (post_beta (STV $pr $conf))))
     (/ $a (+ $a $b))))
