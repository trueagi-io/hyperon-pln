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

!(bind! &kb (new-space))

!(add-atom &kb (: a A))
!(add-atom &kb (: ab (→ A B)))
!(add-atom &kb (: ModusPonens
                (-> (→ $p $q)
                    (-> $p 
                        $q))))

;; Backward chaining Curried
;; Base case
(: bc (-> $a Nat $a))
(= (bc (: $prf $ccln) $_) (match &kb (: $prf $ccln) (: $prf $ccln)))
;; Recursive step
(= (bc (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) (bc (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) (bc (: $prfarg $prms) $k)))
     (: ($prfabs $prfarg) $ccln)))

;; Forward chaining Curried
;; Base case
;; The source is assumed to be true
(: fc (-> $a Nat $a))
(= (fc (: $proof $premise) $_) (: $proof $premise))
;; Recursive step
(= (fc (: $prfarg $premise) (S $k))
   (let (: $prfabs (-> $premise $ccln)) (bc (: $prfabs (-> $premise $ccln)) $k)
     (fc (: ($prfabs $prfarg) $ccln) $k)))
(= (fc (: $prfabs (-> $prms $ccln)) (S $k))
    (let (: $prfarg $prms) (bc (: $prfarg $prms) $k)
     (fc (: ($prfabs $prfarg) $ccln) $k)))

;; Test curried forward chaining
!(assertEqualToResult
     (fc (: ab (→ A B)) (fromNumber 1))
     ((: ab (→ A B)) (: (ModusPonens ab) (-> A B))))
!(assertEqualToResult 
     (fc (: ab (→ A B)) (fromNumber 2))
     ((: ab (→ A B)) (: (ModusPonens ab) (-> A B)) (: ((ModusPonens ab) a) B)))
!(assertEqualToResult
     (fc (: a A) (fromNumber 3))
     ((: a A) (: ((ModusPonens ab) a) B)))
