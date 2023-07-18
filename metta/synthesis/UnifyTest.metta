!(import! &self Unify.metta)

;; Test unify.  Should output (Link A B)
!(unify (Link $x B) (Link A $y) (Link $x $y))

;; Test unify*.  Should output (Link A B C)
!(unify* (((Link $x B $z) (Link A $y $z)) ($z C)) (Link $x $y $z))

;; Test complex unify* query
!(unify* (((: $ructor (-> $premise1 $premise2 $conclusion)) (: . (-> (-> $b $c) (-> $a $b) (-> $a $c))))
          ((: ($ructor $proof1 $proof2) $conclusion) (: $term (-> Number Bool)))
          ((: $proof1 $premise1) (: g (-> String Bool)))
          ((: $proof2 $premise2) (: f (-> Number String))))
         (: $term (-> Number Bool)))
