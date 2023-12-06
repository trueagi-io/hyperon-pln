;; Standaline iterative backward chaining experiments.
;;
;; The particularity of iterative backward chaining is that the
;; inference trees have to abstractions, in the lambda calculus sense
;; of the term.  I.e. we want the backward chaining part to produce
;; macro rules and use these macro rules iteratively.

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

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward DTL Curried ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Similar to the traditional backward chaining DTL but rules are
;; curried.  This allows to partially apply rule which is essential in
;; order to be able to infer abstractions.

;; Knowledge and rule base
!(bind! &kb (new-space))

;; Knowledge base
!(add-atom &kb (: ab (→ A B)))
!(add-atom &kb (: bc (→ B C)))
!(add-atom &kb (: a A))

;; Rule base
!(add-atom &kb (: ModusPonens (-> (→ $p $q)  ; Premise 1
                                  (-> $p     ; Premise 2
                                      $q)))) ; Conclusion
!(add-atom &kb (: Deduction (-> (→ $q $r)         ; Premise 1
                                (-> (→ $p $q)     ; Premise 2
                                    (→ $p $r))))) ; Conclusion
!(add-atom &kb (: . (-> (-> $q $r)         ; Premise 1
                        (-> (-> $p $q)     ; Premise 2
                            (-> $p $r))))) ; Conclusion

;; Backward chainer
;; Base case
(: bc (-> $a Nat $a))
(= (bc (: $prf $ccln) $_) (match &kb (: $prf $ccln) (: $prf $ccln)))
;; Recursive step
(= (bc (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) (bc (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) (bc (: $prfarg $prms) $k)))
     (: ($prfabs $prfarg) $ccln)))

;; Test backward chainer DTL curried
! "=== Test Backward Chainer DTL Curried ==="

;; Prove A (axiom)
!(assertEqual
  (bc (: a A) Z)
  (: a A))

;; Prove (-> (→ A B) (-> A B)) (axiom)
!(assertEqual
  (bc (: $prf (-> $prms (-> A B))) Z)
  (: ModusPonens (-> (→ A B) (-> A B))))

;; Prove (-> A B)
!(assertEqual
  (bc (: $prf (-> A B)) (fromNumber 1))
  (: (ModusPonens ab) (-> A B)))

;; Prove B (one modus ponens)
!(assertEqual
  (bc (: $prf B) (fromNumber 2))
  (: ((ModusPonens ab) a) B))

;; Prove C (two modus ponens)
!(assertEqual
  (bc (: $prf C) (fromNumber 3))
  (: ((ModusPonens bc) ((ModusPonens ab) a)) C))

;; Prove C (two modus ponens, or on modus ponens and on deduction)
!(assertEqualToResult
  (bc (: $prf C) (fromNumber 4))
  ((: ((((. ModusPonens) (Deduction bc)) ab) a) C)
   (: (((. (ModusPonens bc)) (ModusPonens ab)) a) C)
   (: ((ModusPonens ((Deduction bc) ab)) a) C)
   (: ((ModusPonens bc) ((ModusPonens ab) a)) C)))

;; Prove that (-> (→ $q $r) (-> (→ $p $q) (-> $p $r)))
!(assertEqualToResult
  (bc (: $prf (-> (→ $q $r) (-> (→ $p $q) (-> $p $r)))) (fromNumber 4))
  ((: ((((. .) .) ModusPonens) Deduction) (-> (→ $q $r) (-> (→ $p $q) (-> $p $r))))
   (: ((. (. ModusPonens)) Deduction) (-> (→ $q $r) (-> (→ $p $q) (-> $p $r))))))

;; Prove that (-> (→ $r $s) (-> (→ $q $r) (-> (→ $p $q) (→ $p $s))))
!(assertEqualToResult
  (bc (: $prf (-> (→ $r $s) (-> (→ $q $r) (-> (→ $p $q) (→ $p $s))))) (fromNumber 4))
  ((: ((((. .) .) Deduction) Deduction) (-> (→ $r $s) (-> (→ $q $r) (-> (→ $p $q) (→ $p $s)))))
   (: ((. (. Deduction)) Deduction) (-> (→ $r $s) (-> (→ $q $r) (-> (→ $p $q) (→ $p $s)))))))
