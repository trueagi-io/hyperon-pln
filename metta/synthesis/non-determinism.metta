;; Define foo
(: foo (-> Number Number))
(= (foo $x) (+ $x $x))
(= (foo $x) (* $x $x))

;; Test foo
!(foo 42)

