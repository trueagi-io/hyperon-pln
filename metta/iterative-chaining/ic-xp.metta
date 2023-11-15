;; Standalone iterative chaining experiments.

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

;;;;;;;;;;;;;;;;;
;; Bare Entail ;;
;;;;;;;;;;;;;;;;;

;; Reuse the Bare Entail forward chainer of
;; `../forward-chaining/fc-xp.metta`.

;; Foward chainer
(: fc_bare (-> Atom (-> Atom) (-> Atom) Nat Atom))
;; Base case
(= (fc_bare $premise $kb $rb $depth) $premise)
;; Recursive cases
(= (fc_bare $premise1 $kb $rb (S $k))
   (let* (((⊢ $premise1 $premise2 $conclusion) ($rb))
          ($premise2 ($kb)))
     (fc_bare $conclusion $kb $rb $k)))
(= (fc_bare $premise2 $kb $rb (S $k))
   (let* (((⊢ $premise1 $premise2 $conclusion) ($rb))
          ($premise1 ($kb)))
     (fc_bare $conclusion $kb $rb $k)))

;; Knowledge base
(: kb_bare (-> Atom))
(= (kb_bare) (superpose ((→ A B)
                         (→ B C)
                         A)))

;; Rule base
(: rb_bare (-> Atom))
(= (rb_bare) (superpose ((⊢             ; Modus Ponens
                          ;; Premises
                          (→ $p $q)
                          $p
                          ;; Conclusion
                          $q)
                         (⊢             ; Deduction
                          ;; Premises
                          (→ $p $q)
                          (→ $q $r)
                          ;; Conclusion
                          (→ $p $r)))))

;; Test forward chainer
!(fc_bare A kb_bare rb_bare (fromNumber 2)) ; (A B C)
!(fc_bare (→ A B) kb_bare rb_bare (fromNumber 2)) ; ((→ A B) B C)
!(let (→ $x $y) (kb_bare)
      (fc_bare (→ $x $y) kb_bare rb_bare (fromNumber 2))) ; ((→ A B) B C (→ B C))
