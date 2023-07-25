;; Collection of functions operating on numbers

;; Define max
(: max (-> $a $a $a))
(= (max $x $y) (if (> $x $y) $x $y))

;; Define min
(: min (-> $a $a $a))
(= (min $x $y) (if (< $x $y) $x $y))

;; Clamp an number to be within a certain range
(: clamp (-> $a $a $a $a))
(= (clamp $x $l $u) (max $l (min $u $x)))

;; Define abs
(: abs (-> $a $a))
(= (abs $x) (if (< $x 0) (* -1 $x) $x))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $x $y) (or (< $x $y) (== $x $y)))

;; Define >=
(: >= (-> $a $a Bool))
(= (>= $x $y) (or (> $x $y) (== $x $y)))

;; Define approximatively equal
(: approxEq (-> $a $a $a Bool))
(= (approxEq $x $y $epsilon) (<= (abs (- $x $y)) $epsilon))

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

;; Define a less than type.  Note that it is purposefully different
;; than < as it is a type, not an operator.  Inhabitants of (⋖ x y)
;; are proofs that x < y.
(: ⋖ (-> $t $t Type))

;; Zero is always less than the successor of something
(: (zero-lt-succ-axiom) (-> Atom))
(= (zero-lt-succ-axiom)
   (: ZeroLTSucc (⋖ Z (S $k))))

;; If x ⋖ y then (S x) ⋖ (S y)
(: (succ-monotonicity-rule) (-> Atom))
(= (succ-monotonicity-rule)
   (: SuccMonotonicity (-> (⋖ $x $y)
                           (⋖ (S $x) (S $y)))))
