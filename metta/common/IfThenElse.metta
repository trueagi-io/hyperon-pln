;; No longer useful as it is a built-in

;; Define if then else conditional
(: if (-> Bool $a $a $a))
(= (if True $x $y) $x)
(= (if False $x $y) $y)
