;; Import modules
!(import! &self Synthesize.metta)

;; Knowledge base
(= (kb) (superpose ((: f (-> Number String))
                    (: g (-> String Bool))
                    (: h (-> Bool Number))
                    (: i (-> String Number Bool)))))

;; Rule base
(= (rb) (superpose ((: . (-> (-> $b $c) (-> $a $b) (-> $a $c))) ; Function composition
                    (: .: (-> (-> $c $d) (-> $a $b $c) (-> $a $b $d)))))) ; Blackbird

;; Given a function call, (f x), produce record(s) of that function
;; call, (≘ f x (f x)).  ≘ is the MeTTa equivalent of ExecutionLink.
(= (record $f $args) (≘ $f $args (let ($arg1 $arg2 $arg3 $arg4) $args ($f $arg1 $arg2 $arg3 $arg4))))

;; Test program synthesizer
;; !(record synthesize ((: $term $type) Z kb rb))                  ; (: f (-> Number String)), (: g (-> String Bool)), (: h (-> Bool Number)), (: i (-> String Number Bool))
;; !(record synthesize ((: $term (-> Number String)) Z kb rb))     ; (: f (-> Number String))
;; !(record synthesize ((: $term (-> Number Bool)) (S Z) kb rb))   ; (: (. g f) (-> Number Bool))
;; !(record synthesize ((: (. g f) (-> Number Bool)) (S Z) kb rb)) ; (: (. g f) (-> Number Bool))
;; !(record synthesize ((: (. g f) $type) (S Z) kb rb))            ; (: (. g f) (-> Number Bool))
;; !(record synthesize ((: $term $type) (S Z) kb rb))              ; (: f (-> Number String)), ..., (: (. f h) (-> Bool String)), ...
;; !(record synthesize ((: (. (. g f) h) (-> $in Bool)) (fromNumber 2) kb rb)) ; (: (. (. g f) h) (-> Bool Bool)) (fromNumber 3))
;; !(record synthesize ((: (. $g h) (-> $in String)) (fromNumber 3) kb rb)) ; (: (. f h) (-> Bool String))
;; !(record synthesize ((: (. $g h) (-> Number $out)) (fromNumber 3) kb rb))   ; No answer
;; !(record synthesize ((: (. g $f) (-> $in String)) (fromNumber 3) kb rb)) ; No answer
;; !(record synthesize ((: (. g $f) (-> $in Bool)) (fromNumber 3) kb rb))   ; (: (. g f) (-> Number Bool)), (: (. g (. f h)) (-> Bool Bool)), (: (. g (. f (. h g))) (-> String Bool))
!(record synthesize ((: $term $type) (fromNumber 4) kb rb))     ; Too long to list
;; !(record syn ((: $term (-> Number Number)) (fromNumber 6))) ; Too long to run

;; [(≘ synthesize ((: $term $type) Z kb rb) (: f (-> Number String))),
;;  (≘ synthesize ((: $term $type) Z kb rb) (: g (-> String Bool))),
;;  (≘ synthesize ((: $term $type) Z kb rb) (: h (-> Bool Number))),
;;  (≘ synthesize ((: $term $type) Z kb rb) (: i (-> String Number Bool)))]
;; [(≘ synthesize ((: $term (-> Number String)) Z kb rb) (: f (-> Number String)))]
;; [(≘ synthesize ((: $term (-> Number Bool)) (S Z) kb rb) (: (. g f) (-> Number Bool)))]
;; [(≘ synthesize ((: (. g f) (-> Number Bool)) (S Z) kb rb) (: (. g f) (-> Number Bool)))]
;; [(≘ synthesize ((: (. g f) $type) (S Z) kb rb) (: (. g f) (-> Number Bool)))]
;; [(≘ synthesize ((: $term $type) (S Z) kb rb) (: f (-> Number String))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: g (-> String Bool))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: h (-> Bool Number))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: i (-> String Number Bool))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: (. f h) (-> Bool String))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: (. g f) (-> Number Bool))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: (. h g) (-> String Number))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (let* (((: $proof2#599 (-> $a#600 $b#601 Number)) (synthesize (: $proof2#599 (-> $a#600 $b#601 Number)) Z kb rb))) (: (.: f $proof2#599) (-> $a#600 $b#601 String)))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (let* (((: $proof2#599 (-> $a#600 $b#601 String)) (synthesize (: $proof2#599 (-> $a#600 $b#601 String)) Z kb rb))) (: (.: g $proof2#599) (-> $a#600 $b#601 Bool)))),
;;  (≘ synthesize ((: $term $type) (S Z) kb rb) (: (.: h i) (-> String Number Number)))]
;; [(≘ synthesize ((: (. (. g f) h) (-> $in Bool)) (S (S Z)) kb rb) (: (. (. g f) h) (-> Bool Bool)))]
;; [(≘ synthesize ((: (. $g h) (-> $in String)) (S (S (S Z))) kb rb) (: (. f h) (-> Bool String))),
;;  (≘ synthesize ((: (. $g h) (-> $in String)) (S (S (S Z))) kb rb) (let* (((: h (-> $in Bool)) (synthesize (: h (-> $in Bool)) (S (S Z)) kb rb))) (: (. (. f h) h) (-> $in String)))),
;;  (≘ synthesize ((: (. $g h) (-> $in String)) (S (S (S Z))) kb rb) (let* (((: h (-> $in String)) (synthesize (: h (-> $in String)) (S (S Z)) kb rb))) (: (. (. f (. h g)) h) (-> $in String)))),
;;  (≘ synthesize ((: (. $g h) (-> $in String)) (S (S (S Z))) kb rb) (let* (((: h (-> $in String)) (synthesize (: h (-> $in String)) (S (S Z)) kb rb))) (: (. (. (. f h) g) h) (-> $in String)))),
;;  (≘ synthesize ((: (. $g h) (-> $in String)) (S (S (S Z))) kb rb) (: (. (. (. f h) (. g f)) h) (-> Bool String)))]
;; [(≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Number)) (synthesize (: h (-> Number Number)) (S (S Z)) kb rb))) (: (. f h) (-> Number String)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number String)) (synthesize (: h (-> Number String)) (S (S Z)) kb rb))) (: (. g h) (-> Number Bool)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Bool)) (synthesize (: h (-> Number Bool)) (S (S Z)) kb rb))) (: (. h h) (-> Number Number)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Bool)) (synthesize (: h (-> Number Bool)) (S (S Z)) kb rb))) (: (. (. f h) h) (-> Number String)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number String)) (synthesize (: h (-> Number String)) (S (S Z)) kb rb))) (: (. (. f (. h g)) h) (-> Number String)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Number)) (synthesize (: h (-> Number Number)) (S (S Z)) kb rb))) (: (. (. g f) h) (-> Number Bool)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Bool)) (synthesize (: h (-> Number Bool)) (S (S Z)) kb rb))) (: (. (. g (. f h)) h) (-> Number Bool)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number String)) (synthesize (: h (-> Number String)) (S (S Z)) kb rb))) (: (. (. h g) h) (-> Number Number)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Number)) (synthesize (: h (-> Number Number)) (S (S Z)) kb rb))) (: (. (. h (. g f)) h) (-> Number Number)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number String)) (synthesize (: h (-> Number String)) (S (S Z)) kb rb))) (: (. (. (. f h) g) h) (-> Number String)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Number)) (synthesize (: h (-> Number Number)) (S (S Z)) kb rb))) (: (. (. (. f h) (. g f)) h) (-> Number String)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Bool)) (synthesize (: h (-> Number Bool)) (S (S Z)) kb rb))) (: (. (. (. g f) h) h) (-> Number Bool)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number String)) (synthesize (: h (-> Number String)) (S (S Z)) kb rb))) (: (. (. (. g f) (. h g)) h) (-> Number Bool)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Number)) (synthesize (: h (-> Number Number)) (S (S Z)) kb rb))) (: (. (. (. h g) f) h) (-> Number Number)))),
;;  (≘ synthesize ((: (. $g h) (-> Number $out)) (S (S (S Z))) kb rb) (let* (((: h (-> Number Bool)) (synthesize (: h (-> Number Bool)) (S (S Z)) kb rb))) (: (. (. (. h g) (. f h)) h) (-> Number Number))))]
;; [(≘ synthesize ((: (. g $f) (-> $in String)) (S (S (S Z))) kb rb) (let* (((: g (-> $b#583 String)) (synthesize (: g (-> $b#583 String)) (S (S Z)) kb rb)) ((: $f (-> $in $b#583)) (synthesize (: $f (-> $in $b#583)) (S (S Z)) kb rb))) (: (. g $f) (-> $in String))))]
;; [(≘ synthesize ((: (. g $f) (-> $in Bool)) (S (S (S Z))) kb rb) (: (. g f) (-> Number Bool))),
;;  (≘ synthesize ((: (. g $f) (-> $in Bool)) (S (S (S Z))) kb rb) (: (. g (. f h)) (-> Bool Bool))),
;;  (≘ synthesize ((: (. g $f) (-> $in Bool)) (S (S (S Z))) kb rb) (: (. g (. f (. h g))) (-> String Bool))),
;;  (≘ synthesize ((: (. g $f) (-> $in Bool)) (S (S (S Z))) kb rb) (: (. g (. (. f h) g)) (-> String Bool))),
;;  (≘ synthesize ((: (. g $f) (-> $in Bool)) (S (S (S Z))) kb rb) (: (. g (. (. f h) (. g f))) (-> Number Bool)))]
