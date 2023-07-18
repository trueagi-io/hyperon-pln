;; Import modules
!(import! &self ../common/Num.metta)
;; !(import! &self Unify.metta)

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
;;
;; TODO: recurse over curried rules instead of duplicating code over
;; tuples.
(: synthesize (-> Atom Nat (-> Atom) (-> Atom) Atom))
;; Nullary rule (axiom)
(= (synthesize $query $depth $axiom $rule)
   (let $query ($axiom) $query))
;; Unary rule
(= (synthesize $query (S $k) $axiom $rule)
   (let* (((: $ructor (-> $premise $conclusion)) ($rule))
            ((: ($ructor $proof) $conclusion) $query)
            ((: $proof $premise) (synthesize (: $proof $premise) $k $axiom $rule)))
           $query))
;; Binary rule
(= (synthesize $query (S $k) $axiom $rule)
   (let* (((: $ructor (-> $premise1 $premise2 $conclusion)) ($rule))
            ((: ($ructor $proof1 $proof2) $conclusion) $query)
            ((: $proof1 $premise1) (synthesize (: $proof1 $premise1) $k $axiom $rule))
            ((: $proof2 $premise2) (synthesize (: $proof2 $premise2) $k $axiom $rule)))
           $query))
;; Trinary rule
(= (synthesize $query (S $k) $axiom $rule)
   (let* (((: $ructor (-> $premise1 $premise2 $premise3 $conclusion)) ($rule))
            ((: ($ructor $proof1 $proof2 $proof3) $conclusion) $query)
            ((: $proof1 $premise1) (synthesize (: $proof1 $premise1) $k $axiom $rule))
            ((: $proof2 $premise2) (synthesize (: $proof2 $premise2) $k $axiom $rule))
            ((: $proof3 $premise3) (synthesize (: $proof3 $premise3) $k $axiom $rule)))
           $query))
;; Quaternary rule
(= (synthesize $query (S $k) $axiom $rule)
   (let* (((: $ructor (-> $premise1 $premise2 $premise3 $premise4 $conclusion)) ($rule))
            ((: ($ructor $proof1 $proof2 $proof3 $proof4) $conclusion) $query)
            ((: $proof1 $premise1) (synthesize (: $proof1 $premise1) $k $axiom $rule))
            ((: $proof2 $premise2) (synthesize (: $proof2 $premise2) $k $axiom $rule))
            ((: $proof3 $premise3) (synthesize (: $proof3 $premise3) $k $axiom $rule))
            ((: $proof4 $premise4) (synthesize (: $proof4 $premise4) $k $axiom $rule)))
           $query))
;; Quintenary rule
(= (synthesize $query (S $k) $axiom $rule)
   (let* (((: $ructor (-> $premise1 $premise2 $premise3 $premise4 $premise5 $conclusion)) ($rule))
            ((: ($ructor $proof1 $proof2 $proof3 $proof4 $proof5) $conclusion) $query)
            ((: $proof1 $premise1) (synthesize (: $proof1 $premise1) $k $axiom $rule))
            ((: $proof2 $premise2) (synthesize (: $proof2 $premise2) $k $axiom $rule))
            ((: $proof3 $premise3) (synthesize (: $proof3 $premise3) $k $axiom $rule))
            ((: $proof4 $premise4) (synthesize (: $proof4 $premise4) $k $axiom $rule))
            ((: $proof5 $premise5) (synthesize (: $proof5 $premise5) $k $axiom $rule)))
           $query))
