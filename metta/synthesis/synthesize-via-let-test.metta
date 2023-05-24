;; Import modules
!(import! &self synthesize-via-let.metta)

;; Given a function call, (f x), produce record(s) of that function
;; call, (≘ f x (f x)).  ≘ is the MeTTa equivalent of ExecutionLink.
(= (record $f $args) (≘ $f $args (let ($arg1 $arg2) $args ($f $arg1 $arg2))))

;; Test program synthesizer
!(record syn ((: $term $type) Z))                  ; (: f (-> Number String)), (: g (-> String Bool)), (: h (-> Bool Number))
!(record syn ((: $term (-> Number String)) Z))     ; (: f (-> Number String))
!(record syn ((: $term (-> Number Bool)) (S Z)))   ; (: (. g f) (-> Number Bool))
!(record syn ((: (. g f) (-> Number Bool)) (S Z))) ; (: (. g f) (-> Number Bool))
!(record syn ((: (. g f) $type) (S Z)))            ; (: (. g f) (-> Number Bool))
!(record syn ((: $term $type) (S Z)))              ; (: f (-> Number String)), ..., (: (. f h) (-> Bool String)), ...
!(record syn ((: (. (. g f) h) (-> $in Bool)) (fromNumber 2))) ; (: (. (. g f) h) (-> Bool Bool)) (fromNumber 3))
!(record syn ((: (. $g h) (-> $in String)) (fromNumber 3))) ; (: (. f h) (-> Bool String))
!(record syn ((: (. $g h) (-> Number $out)) (fromNumber 3)))   ; No answer
!(record syn ((: (. g $f) (-> $in String)) (fromNumber 3))) ; No answer
!(record syn ((: (. g $f) (-> $in Bool)) (fromNumber 3)))   ; (: (. g f) (-> Number Bool)), (: (. g (. f h)) (-> Bool Bool)), (: (. g (. f (. h g))) (-> String Bool))
!(record syn ((: $term $type) (fromNumber 4)))     ; Too long to list
;; !(record syn ((: $term (-> Number Number)) (fromNumber 6))) ; Too long to run
