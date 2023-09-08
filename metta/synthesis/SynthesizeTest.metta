;; Setting up a simple knowledge base and rule base for demoing reasoning in MeTTa.

;; Import modules
!(import! &self Synthesize.metta)
!(import! &self ../common/Record.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose ((: f (-> Number String))
                    (: g (-> String Bool))
                    (: h (-> Bool Number))
                    (: i (-> String Number Bool)))))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose ((: . (-> (-> $b $c) (-> $a $b) (-> $a $c))) ; Function composition
                    (: .: (-> (-> $c $d) (-> $a $b $c) (-> $a $b $d)))))) ; Blackbird (generalized composition)

;; Test program synthesizer
; Query for any function composition of depth 0.
!(record synthesize ((: $term $type) Z kb rb))  ; (: f (-> Number String)), (: g (-> String Bool)), (: h (-> Bool Number)), (: i (-> String Number Bool))

; Query for functions from Number to String at depth 0.
!(record synthesize ((: $term (-> Number String)) Z kb rb)) ; (: f (-> Number String))

; Query for functions of depth 1, from String and Number to Number.
!(record synthesize ((: $term (-> String Number Number)) (S Z) kb rb))  ; (: (.: h i) (-> String Number Number)))

; Queries for ANY function from Number to Bool of at most depth 1.
!(record synthesize ((: $term (-> Number Bool)) (S Z) kb rb)) ; (: (. g f) (-> Number Bool))
; Queries for the specific `(.g f)` composition, checking if it goes from Number to Bool af depth 1.
!(record synthesize ((: (. g f) (-> Number Bool)) (S Z) kb rb)) ; (: (. g f) (-> Number Bool))

; Type inference for `(. g f)`
!(record synthesize ((: (. g f) $type) (S Z) kb rb))  ; (: (. g f) (-> Number Bool))

; Query for any function composition of at most depth 1.
!(record synthesize ((: $term $type) (S Z) kb rb))  ; (: f (-> Number String)), ..., (: (. f h) (-> Bool String)), ...

; Input type inference for `(. (. g f) h)`, at depth 2
!(record synthesize ((: (. (. g f) h) (-> $in Bool)) (fromNumber 2) kb rb)) ; (: (. (. g f) h) (-> Bool Bool))

; Query for any function which can be composed with `h`, with any type signature, at depth 3
!(record synthesize ((: (. $g h) $type) (fromNumber 3) kb rb)) ; Long list

; Query for any function which can be composed with `h`, taking a `Number` and returning any type, at depth 3
!(record synthesize ((: (. $g h) (-> Number $out)) (fromNumber 3) kb rb)) ; No answer, since `h` doesn't take Number

; Query for any function which can be composed with `g` and take any input type and return String, at depth 3
!(record synthesize ((: (. g $f) (-> $in String)) (fromNumber 3) kb rb)) ; No answer, since `g` doesn't return string

; Query for any function which can be composed with `g`, taking any input type and return Bool, at depth 3
!(record synthesize ((: (. g $f) (-> $in Bool)) (fromNumber 3) kb rb))  ; (: (. g f) (-> Number Bool)), (: (. g (. f h)) (-> Bool Bool)), (: (. g (. f (. h g))) (-> String Bool))

; Query for any function composition of at most depth 4
!(record synthesize ((: $term $type) (fromNumber 4) kb rb)) ; Too long to list

; Query for any function composition of at most depth 6
;; !(record synthesize ((: $term (-> Number Number)) (fromNumber 6) kb rb)) ; Too long to run
