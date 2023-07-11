;; Import modules
!(import! &self synthesize-via-unify.metta)
!(import! &self ../../common/Record.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose ((: f (-> Number String))
                    (: g (-> String Bool))
                    (: h (-> Bool Number))
                    (: i (-> String Number Bool)))))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose ((: . (-> (-> $b $c) (-> $a $b) (-> $a $c))) ; Function composition
                    (: .: (-> (-> $c $d) (-> $a $b $c) (-> $a $b $d)))))) ; Blackbird

;; Test program synthesizer
!(record synthesize ((: $term $type) Z kb rb))                  ; (: f (-> Number String)), (: g (-> String Bool)), (: h (-> Bool Number)), (: i (-> String Number Bool))
!(record synthesize ((: $term (-> Number String)) Z kb rb))     ; (: f (-> Number String))
!(record synthesize ((: $term (-> String Number Number)) (S Z) kb rb))     ; (: f (-> Number String))
!(record synthesize ((: $term (-> Number Bool)) (S Z) kb rb))   ; (: (. g f) (-> Number Bool))
!(record synthesize ((: (. g f) (-> Number Bool)) (S Z) kb rb)) ; (: (. g f) (-> Number Bool))
!(record synthesize ((: (. g f) $type) (S Z) kb rb))            ; (: (. g f) (-> Number Bool))
!(record synthesize ((: $term $type) (S Z) kb rb))              ; (: f (-> Number String)), ..., (: (. f h) (-> Bool String)), ...
!(record synthesize ((: (. (. g f) h) (-> $in Bool)) (fromNumber 2) kb rb)) ; (: (. (. g f) h) (-> Bool Bool)) (fromNumber 3))
!(record synthesize ((: (. $g h) $type) (fromNumber 3) kb rb)) ; (: (. f h) (-> Bool String))
!(record synthesize ((: (. $g h) (-> Number $out)) (fromNumber 3) kb rb))   ; No answer
!(record synthesize ((: (. g $f) (-> $in String)) (fromNumber 3) kb rb)) ; No answer
!(record synthesize ((: (. g $f) (-> $in Bool)) (fromNumber 3) kb rb))   ; (: (. g f) (-> Number Bool)), (: (. g (. f h)) (-> Bool Bool)), (: (. g (. f (. h g))) (-> String Bool))
!(record synthesize ((: $term $type) (fromNumber 4) kb rb))     ; Too long to list
;; !(record synthesize ((: $term (-> Number Number)) (fromNumber 6) kb rb)) ; Too long to run
