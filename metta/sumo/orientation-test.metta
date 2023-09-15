;; Test orientation.kif

;; Import orientation as a plain SUO-KIF file, MeTTa has no problem
;; with that.
!(import! &self orientation.kif)

;; Import synthesizer
!(import! &self ../synthesis/Synthesize.metta)

;; Knowledge base extracted from
;;
;; https://github.com/ontologyportal/sumo/blob/master/tests/SP01.kif.tq
;;
;; to test `orientation`.

(instance A Object)
(instance B Object)
(instance C Object)

(orientation A B Right)
(orientation C B Left)

;; (query (orientation A C Right))

;; We want to produce NEXT

!(get-atoms &self)
