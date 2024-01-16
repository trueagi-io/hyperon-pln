;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of a chainer, Nat, plus and some proofs about the
;; existance of the parity properties of Nat such as Even and Odd.
;;
;; Implement a sigma type, take example from
;;
;; https://idris2.readthedocs.io/en/latest/tutorial/typesfuns.html#dependent-pairs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; Nat ;;
;;;;;;;;;

;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $x $y) (or (< $x $y) (== $x $y)))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and rule base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(bind! &kb (new-space))

;; Define Σ type (called DPair in Idris)
(: Σ (-> (: $a Type) (-> $a Type) Type))

;; Define DPair constructor
(: MkΣ (-> (: $p (-> $a Type)) (: $x $a) ($p $x) (Σ $a $p)))

;; Define the even property
(: Even (-> Nat Type))
(: MkEvenZ (Even Z))
(: MkEvenSS (-> (Even $k) (Even (S (S $k)))))

;; Define examples of even numbers (0 and 2)
(: (MkΣ Even Z MkEvenZ) (Σ Nat Even))
(: (MkΣ Even (S (S Z)) (MkEvenSS MkEvenZ)) (Σ Nat Even))
(: $prf (Σ Nat Even))

;; Define double function
(: double (-> Nat Nat))
(= (double Z) Z)
(= (double (S $k)) (S (S (double $k))))

(= (fst (MkΣ $p $x $prf)) $x)
(= (snd (MkΣ $p $x $prf)) $prf)

;; Define double function, with the guaranty that the output is even
(: doubleΣ (-> Nat (Σ Nat Even)))
(= (doubleΣ Z) (MkΣ Even Z MkEvenZ))
(= (doubleΣ (S $k)) (MkΣ Even
                         (S (S (fst (doubleΣ $k))))
                         (MkEvenSS (snd (doubleΣ $k)))))

;; For all x, (double x) is even
;; ∀x (Even (double x))
(: double-even-prf (-> ($x : Nat) (Even (double $x))))

;; Independent product type
(: × (-> Type Type Type))

;; Equality
(: === (-> $a $a Type))

;; NEXT

;; For all x, there exists k such that k = (double x) and k is even
;; ∀x ∃k k=(double x) ∧ (Even k)
(: double-Σ-even-prf (-> ($x : Nat)
                         (Σ Nat (λ $k (× (=== $k (double $x)) (Even $k))))))

(: double-Σ-even-prf (-> ($x : Nat) (Σ Nat (EqualDoubleAndEven $x))))
(: EqualDoubleAndEven (-> Nat (-> Nat Type)))
(= ((EqualDoubleAndEven $x) $k) (× (=== $k (double $x)) (Even $k)))
;; Or, alternatively
;; (= (EqualDoubleAndEven $x) (λ $k (× (=== $k (double $x)) (Even $k))))
