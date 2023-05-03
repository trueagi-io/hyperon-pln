;; Import modules
!(import! &self ../common/Num.metta)

;; Define set of rules
(= (rules) (: . (-> (-> $b $c) (-> $a $b) (-> $a $c))))

;; Define set of facts
(= (facts) (superpose ((: f (-> Number String)) (: f' (-> Number String)) (: g (-> String Bool)))))

;; Define backward chaining target
(= (target) (-> Number Bool))

;; Single-step backward chainer, using rules, facts and target
!(let* (((: $rule (-> $premise1 $premise2 $conclusion)) (rules))
        ((: $fact1 $premise1) (facts))
        ((: $fact2 $premise2) (facts))
        ($target (target))
        ($conclusion $target))
  (: ($rule $fact1 $fact2) $target))

;; Multi-step backward chainer, using rules and facts
(: bc (-> Atom Nat Atom))
(= (bc $query Z) (let $query (facts) $query))
(= (bc $query (S $k)) (let* (((: $rule-term (-> $premise1 $premise2 $conclusion)) (rules))
                             ((: $query-term $query-type) $query)
                             ;; NEXT
                             ($query (: ($rule-term (bc (: $blabla1 $premise1) $k) (bc (: $blabla2 $premise2) $k)))))
                        $query))

;; Test multi-step backward chainer
!(bc (: $term $type) Z)
!(bc (: $term (-> Number String)) Z)
!(bc (: $term (-> Number Bool)) Z)
!(bc (: $term (-> Number Bool)) (S Z))
