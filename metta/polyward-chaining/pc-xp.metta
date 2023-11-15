;; Standalone polyward chaining experiments.

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

;;;;;;;;;;;;;;;;;;;;;;;
;; Forward Revertant ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Forward chainer that may go backward if necessary.

! "=== Forward Revertant ==="

;; Knowledge base
!(bind! &kb (new-space))
!(add-atom &kb (: ab (→ A B)))
!(add-atom &kb (: bc (→ B C)))
!(add-atom &kb (: a A))

;; Rule base
!(bind! &rb (new-space))
!(add-atom &rb (: ModusPonens (->
                               ;; Premises
                               (→ $p $q)
                               $p
                               ;; Conclusion
                               $q)))
!(add-atom &rb (: Deduction (->
                             ;; Premises
                             (→ $p $q)
                             (→ $q $r)
                             ;; Conclusion
                             (→ $p $r))))

;; Backward chainer, based on the DTL version of
;; `../backward-chaining/bc-xp.metta` but rules are in an atomspace
;; instead of being hardwired.  To be used by the forward revertant
;; chainer defined below.
(: bc (-> Atom Nat Atom))
;; Base case
(= (bc (: $prf $ccl) $depth)
   (match &kb (: $prf $ccl) (: $prf $ccl)))
;; Recursive cases
(= (bc (: $prf $ccl) (S $k))
   (match &rb (: $ctor (-> $prm1 $prm2 $ccl))
          (let* (((: $prf1 $prm1) (bc (: $prf1 $prm1) $k))
                 ((: $prf2 $prm2) (bc (: $prf2 $prm2) $k))
                 ((: ($ctor $prf1 $prf2) $prf)))
            (: $prf $ccl))))

;; Forward revertant chainer, based on the DTL version of
;; `../backward-chaining/bc-xp.metta` but matching premises is
;; replaced by calling the backward chainer defined above.
(: frc (-> Atom Nat Atom))
;; Base case
(= (frc (: $prf $prm) $depth) (: $prf $prm))
;; Recursive cases
(= (frc (: $prf1 $prm1) (S $k))
   (match &rb (: $ctor (-> $prm1 $prm2 $ccl))
          (let (: $prf2 $prm2) (bc (: $prf2 $prm2) $k)
               (frc (: ($ctor $prf1 $prf2) $ccl) $k))))
(= (frc (: $prf2 $prm2) (S $k))
   (match &rb (: $ctor (-> $prm1 $prm2 $ccl))
          (let (: $prf1 $prm1) (bc (: $prf1 $prm1) $k)
               (frc (: ($ctor $prf1 $prf2) $ccl) $k))))

;; Test backward chainer
;; NEXT

;; Test forward revertant chainer
!(assertEqual
  (frc (: a A) Z)
  (: a A))
!(assertEqualToResult
  (frc (: a A) (fromNumber 1))
  ((: a A)
   (: (ModusPonens ab a) B)))
!(assertEqualToResult
  (frc (: a A) (fromNumber 2))
  ((: a A)
   (: (ModusPonens ab a) B)
   (: (ModusPonens bc (ModusPonens ab a)) C)))
!(assertEqualToResult
  (frc (: a A) (fromNumber 3))
  ((: a A)
   (: (ModusPonens ab a) B)
   (: (ModusPonens bc (ModusPonens ab a)) C)
   (: (ModusPonens (Deduction ab bc) a) C)))
