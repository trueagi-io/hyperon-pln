;; Define foo, a mixture of double and power of 2.
(: foo (-> Number Number))
(= (foo $x) (+ $x $x))
(= (foo $x) (* $x $x))
;; (= (foo $x) (superpose ((+ $x $x) (* $x $x))))

;; Test foo
!(foo 21)

;; Define bar, a mixture of increment by 1 and factorial.
(: bar (-> Number Number))
(= (bar $x) (+ $x 1))
(= (bar $x) (if (== $x 0)
                1
                (* $x (bar (- $x 1)))))

!(bar 2)
