;; Temporal [evidential] truth value.  A truth value indexed by time.
;; Implemeted as a map from time to truth value.  Time is discrete for
;; now.

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
