;; Temporal [evidential] truth value.  It generally represents a
;; temporal random variable.  For now is implemented as a map f from
;; time to truth value such that ∫ₜf(t)dt = 1.

!(import! &self "EvidentialTruthValue.metta")

;;;;;;;;;;;
;; Types ;;
;;;;;;;;;;;

(: TemporalTruthValue Type)
(: TemporalEvidentialTruthValue Type)

;;;;;;;;;;;;;;;;;;
;; Constructors ;;
;;;;;;;;;;;;;;;;;;

;; Temporal truth value constructor.  For now time is discrete.
(: TTV (-> (-> Number TruthValue) TemporalTruthValue))

;; Temporal evidential truth value constructor.  For now time is
;; discrete.
(: TETV (-> (-> Number EvidentialTruthValue) TemporalEvidentialTruthValue))

;;;;;;;;;;;;;
;; Methods ;;
;;;;;;;;;;;;;

;; Calculate the convolution of two temporal truth values.  This is
;; used to obtain a temporal random variable defined as the sum of two
;; temporal random variables.  The function is named `conv` as in
;; MatLab.
(: conv (-> TemporalTruthValue
            TemporalTruthValue
            TemporalTruthValue))
;; (= (conv $ttv1 $ttv2) TODO)

;; Calculate the convolution of two temporal evidential truth values.
(: tetv_conv (-> TemporalEvidentialTruthValue
                 TemporalEvidentialTruthValue
                 TemporalEvidentialTruthValue))
;; (= (tetv_conv $tetv1 $tetv2) TODO)
