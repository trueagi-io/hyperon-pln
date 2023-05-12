;; Import modules
!(import! &self synthesize-via-let.metta)

;; Given a function call, (f x), produce record(s) of that function
;; call, (≘ f x (f x)).  ≘ is the MeTTa equivalent of ExecutionLink.
(= (record $f $args) (≘ $f $args (let ($arg1 $arg2) $args ($f $arg1 $arg2))))

;; Test program synthesizer
!(record syn ((: $term $type) Z))
!(record syn ((: $term (-> Number String)) Z))
!(record syn ((: $term (-> Number Bool)) (S Z)))
!(record syn ((: (. g f) (-> Number Bool)) (S Z)))
!(record syn ((: (. g f) $type) (S Z)))
!(record syn ((: $term $type) (S Z)))
!(record syn ((: (. $g h) (-> $in String)) (fromNumber 3)))
!(record syn ((: (. $g h) (-> $in Bool)) (fromNumber 3)))
!(record syn ((: (. g $f) (-> $in String)) (fromNumber 3)))
!(record syn ((: (. g $f) (-> $in Bool)) (fromNumber 3)))
!(record syn ((: (. (. g f) h) (-> $in Bool)) (fromNumber 3)))
!(record syn ((: $term $type) (fromNumber 4)))
!(record syn ((: $term (-> Number Number)) (fromNumber 6)))

;; [(≘ syn ((: $term $type) Z) (: f (-> Number String)))
;;  (≘ syn ((: $term $type) Z) (: g (-> String Bool)))
;;  (≘ syn ((: $term $type) Z) (: h (-> Bool Number)))]
;; [(≘ syn ((: $term (-> Number String)) Z) (: f (-> Number String)))]
;; [(≘ syn ((: $term (-> Number Bool)) (S Z)) (: (. g f) (-> Number Bool)))]
;; [(≘ syn ((: (. g f) (-> Number Bool)) (S Z)) (: (. g f) (-> Number Bool)))]
;; [(≘ syn ((: (. g f) $type) (S Z)) (: (. g f) (-> Number Bool)))]
;; [(≘ syn ((: $term $type) (S Z)) (: (. f h) (-> Bool String)))
;;  (≘ syn ((: $term $type) (S Z)) (: (. g f) (-> Number Bool)))
;;  (≘ syn ((: $term $type) (S Z)) (: (. h g) (-> String Number)))
;;  (≘ syn ((: $term $type) (S Z)) (: f (-> Number String)))
;;  (≘ syn ((: $term $type) (S Z)) (: g (-> String Bool)))
;;  (≘ syn ((: $term $type) (S Z)) (: h (-> Bool Number)))]
;; [(≘ syn ((: (. $g h) (-> $in String)) (S (S (S Z)))) (: (. f h) (-> Bool String)))]
;; [(≘ syn ((: (. $g h) (-> $in Bool)) (S (S (S Z)))) (let* (((: h (-> $in String)) (syn (: h (-> $in String)) (S (S Z)))) ((: (. g h) (-> $in Bool)) (: (. $prf1#2880 h) (-> $a#2882 Bool)))) (: (. $prf1#2880 h) (-> $a#2882 Bool))))]
;; [(≘ syn ((: (. g $f) (-> $in String)) (S (S (S Z)))) (let* (((: g (-> $b#3751 String)) (syn (: g (-> $b#3751 String)) (S (S Z)))) ((: $f (-> $in $b#3751)) (syn (: $f (-> $in $b#3751)) (S (S Z)))) ((: (. g $f) (-> $in String)) (: (. g $prf2#3783) (-> $a#3784 String)))) (: (. g $prf2#3783) (-> $a#3784 String))))]
;; [(≘ syn ((: (. g $f) (-> $in Bool)) (S (S (S Z)))) (: (. g (. f (. h g))) (-> String Bool)))
;;  (≘ syn ((: (. g $f) (-> $in Bool)) (S (S (S Z)))) (: (. g (. f h)) (-> Bool Bool)))
;;  (≘ syn ((: (. g $f) (-> $in Bool)) (S (S (S Z)))) (: (. g f) (-> Number Bool)))]
;; [(≘ syn ((: (. (. g f) h) (-> $in Bool)) (S (S (S Z)))) (let* (((: (. g f) (-> $b#5199 Bool)) (syn (: (. g f) (-> $b#5199 Bool)) (S (S Z)))) ((: h (-> $in $b#5199)) (syn (: h (-> $in $b#5199)) (S (S Z)))) ((: (. (. g f) h) (-> $in Bool)) (: (. (. g f) h) (-> $a#5236 Bool)))) (: (. (. g f) h) (-> $a#5236 Bool))))]
;; [(≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. f (. h (. g (. f h)))) (-> Bool String)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. f (. h (. g f))) (-> Number String)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. f (. h g)) (-> String String)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. f h) (-> Bool String)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. g (. f (. h (. g f)))) (-> Number Bool)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. g (. f (. h g))) (-> String Bool)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. g (. f h)) (-> Bool Bool)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. g f) (-> Number Bool)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. h (. g (. f (. h g)))) (-> String Number)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. h (. g (. f h))) (-> Bool Number)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. h (. g f)) (-> Number Number)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: (. h g) (-> String Number)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: f (-> Number String)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: g (-> String Bool)))
;;  (≘ syn ((: $term $type) (S (S (S (S Z))))) (: h (-> Bool Number)))]
;; [(≘ syn ((: $term (-> Number Number)) (S (S (S (S (S (S Z))))))) (: (. h (. g (. f (. h (. g f))))) (-> Number Number)))
;;  (≘ syn ((: $term (-> Number Number)) (S (S (S (S (S (S Z))))))) (: (. h (. g f)) (-> Number Number)))]
