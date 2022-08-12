;;;;;;;;;;;;;;;;;;;;;;
;; Truth Value Type ;;
;;;;;;;;;;;;;;;;;;;;;;

;; TruthValue type
(: TruthValue Type)

;; Boolean TV constructor
(: Bl (-> Bool TruthValue))

;; First order probability TV constructor, i.e. mere probability.
(: Pr (-> Number TruthValue))

;; Second order probability TV constructor, i.e. probability and count.
(: PrCnt (-> Number Number TruthValue))

;; Evidence type
(: Evidence (-> (Set $a) Type))

;; Evidential TruthValue type
(: EvidentialTruthValue (-> TruthValue Evidence Type))
