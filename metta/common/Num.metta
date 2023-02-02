;; Collection of functions operating on numbers

;; Define max
(= (max $a $b) (if (> $a $b) $a $b))

;; Define min
(= (min $a $b) (if (< $a $b) $a $b))

;; Clamp an number to be within a certain range
(= (clamp $x $l $u)
  (max $l (min $u $x)))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $a $b) (or (< $a $b) (== $a $b)))

;; Define >=
(: >= (-> $a $a Bool))
(= (>= $a $b) (or (> $a $b) (== $a $b)))
