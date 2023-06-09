;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;; Given a function call, (f x), produce record(s) of that function
;; call, (≘ f x (f x)).  ≘ is the MeTTa equivalent of ExecutionLink.
(= (record $f ($arg1 $arg2 $arg3 $arg4))
   (≘ $f ($arg1 $arg2 $arg3 $arg4) ($f $arg1 $arg2 $arg3 $arg4)))

;; Enumerate all programs up to a given depth that are consistent with
;; the query, using the given axioms and rules.
;;
;; The arguments are:
;;
;; $query: an Atom under the form (: TERM TYPE).  The atom may contain
;;         free variables within TERM and TYPE to form various sort of
;;         queries, such as:
;;         1. Backward chaining: (: $term (Inheritance $x Mammal))
;;         2. Forward chaining: (: ($rule $premise AXIOM) $type)
;;         3. Mixed chaining: (: ($rule $premise AXIOM) (Inheritance $x Mammal))
;;         4. Type checking: (: TERM TYPE)
;;         5. Type inference: (: TERM $type)
;;
;; $depth: a Nat representing the maximum depth of the generated
;;         programs.
;;
;; $axiom: a nullary function to axiom, to non-deterministically pick
;;         up an axiom.  An axiom is an Atom of the form
;;         (: TERM TYPE).
;;
;; $rule: a nullary function to rule, to non-deterministically pick up
;;        a rule.  A rule is a function mapping premises to
;;        conclusion, where premises and conclusion have the form
;;        (: TERM TYPE).
;;
;; up to a given depth that are consistent with the query, using the
;; provided rule and axiom non-deterministic functions.  An axiom is
;; an Atom of the form
(: synthesize (-> Atom Nat (-> Atom) (-> Atom) Atom))
;; Nullary rule (axiom)
(= (synthesize $query $depth $axiom $rule) (let $query ($axiom) $query))
;; Binary rule
(= (synthesize $query (S $k) $axiom $rule)
   (let* (((: $ructor (-> $premise1 $premise2 $conclusion)) ($rule))
          ((: ($ructor $proof1 $proof2) $conclusion) $query)
          ((: $proof1 $premise1) (synthesize (: $proof1 $premise1) $k $axiom $rule))
          ((: $proof2 $premise2) (synthesize (: $proof2 $premise2) $k $axiom $rule)))
     $query))

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
;; !(record syn ((: $term (-> Number Number)) (fromNumber 6))) ; Too long to run
