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

;; Evidence type and constructor
(: Evidence Type)
(: MkEv (-> (Set $a) Evidence))

;; Evidential TruthValue type and constructor
(: EvidentialTruthValue Type)
(: MkETV (-> TruthValue Evidence EvidentialTruthValue))

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
