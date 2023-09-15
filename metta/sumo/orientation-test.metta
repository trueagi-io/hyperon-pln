;; Test reasoning on the content of orientation.kif.  We attempt to
;; import the SUO-KIF file directly, then preprocess it to make it
;; more MeTTa compliant, renaming SUO-KIF variables, like ?X, into
;; MeTTa variables, like $X.

;; Import orientation as a plain SUO-KIF file
!(import! &self orientation.kif)

;; Import synthesizer
!(import! &self ../synthesis/Synthesize.metta)

;; Add knowledge base extracted from
;;
;; https://github.com/ontologyportal/sumo/blob/master/tests/SP01.kif.tq
;;
;; to test `orientation`.

(instance A Object)
(instance B Object)
(instance C Object)

(orientation A B Right)
(orientation C B Left)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MeTTa code to convert SUO-KIF into MeTTa ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Space containing the result of the SUO-KIF to MeTTa translation
!(bind! &metta (new-space))

!(match &self $x $x)

;; (query (orientation A C Right))

;; We want to produce NEXT
