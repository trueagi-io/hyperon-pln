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

;; Return the ceiling of a non negative number.  If the number is
;; negative it returns 1.
(: ceil (-> Number Number))
(= (ceil $n) (fromNat (fromNumber $n)))
