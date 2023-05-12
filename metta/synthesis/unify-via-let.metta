;; Simple unification
!(let (Link A $y) (Link $x B) (Link $x $y))

;; Simple unification using type operator
!(let (-> A $y) (-> $x B) (-> $x $y))

;; Unify a term with the result of function (right-handside)
(= (f $x) (Link $x B))
!(let (Link A $y) (f $x) (Link $x $y))

;; Unify a term with the result of function (left-handside)
(= (g $y) (Link A $y))
!(let (g $y) (Link $x B) (Link $x $y))
!(let* ((g $y) (Link $x B)) (Link $x $y))

;; Simple multi-unification via superpose
!(let (Link A $y) (superpose ((Link $x B) (Node A) (Link $x C))) (Link $x $y))

;; Unify a term with the result of function (left-handside)
!(let* (($z (g $y)) ($z (f $x))) $z)

