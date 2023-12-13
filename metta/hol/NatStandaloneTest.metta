;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of an omnichainer, Nat, plus and some proofs.            ;;
;;                                                                     ;;
;; The main proof of interest is that Z is the right identity of plus. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The omnichainer is expected to have the following properties:
;;
;; - Rules are curried.
;;
;; - There is no distinction between axioms and rules.
;;
;; - Rule composition, using the traditional composition operator `.`
;;   is included in the chaining process (whether it is embedded in
;;   the chainer implementation or is an external rule remains to be
;;   determined).
;;
;; Given such omnichainer, the inductive property that x + 0 = x
;; implies (S x) + 0 = (S x) should then have the following proof:
;;
;; (. (EqTrans Rec_plus) EqStruct1)

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
;; curried.  This allows to partially apply rule which is useful for
;; inferring proof abstractions.

;; Base case
(: bc (-> $a Nat $a))
(= (bc (: $prf $ccln) $_) (match &kb (: $prf $ccln) (: $prf $ccln)))
;; Recursive step
(= (bc (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) (bc (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) (bc (: $prfarg $prms) $k)))
     (: ($prfabs $prfarg) $ccln)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and rule base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!(bind! &kb (new-space))

;; Knowledge base

;; TODO: curry everything

;; Equality is reflexive.  We use === instead of == to make sure it
;; does not get reduced by the MeTTa interpreter.
!(add-atom &kb (: EqRefl (=== $x $x)))

;; Equality is transitive
!(add-atom &kb (: EqTrans (-> (=== $x $y)         ; Premise 1
                              (-> (=== $y $z)     ; Premise 2
                                  (=== $x $z))))) ; Conclusion

;; Equality is symmetric
!(add-atom &kb (: EqSym (-> (=== $x $y)    ; Premise
                            (=== $y $x)))) ; Conclusion

;; Equality respects function application
!(add-atom &kb (: EqCong (-> (=== $x $x')                ; Premise
                             (=== ($op $x) ($op $x'))))) ; Conclusion

;; Rule of replacement (nullary operator)
;; TODO: could use Repl1 combine with identity function instead.
!(add-atom &kb (: Repl0 (-> (=== $x $x') ; Premise 1
                            (-> $x       ; Premise 2
                                $x')))   ; Conclusion

;; Rule of replacement (unary operator)
!(add-atom &kb (: Repl1 (-> (=== $x $x')      ; Premise 1
                            (-> ($op $x)      ; Premise 2
                                ($op $x'))))) ; Conclusion

;; Structural induction on Nat
!(add-atom &kb (: NatInd
                  (-> ($p Z)                       ; Premise 1 (base case)
                      (-> (-> ($p $x) ($p (S $x))) ; Premise 2 (inductive step)
                          ($p $x')))))             ; Conclusion

;; Definition of plus (base case)
!(add-atom &kb (: plusBase (=== (plus Z $y) $y)))

;; Definition of plus (recursive step)
!(add-atom &kb (: plusRec (=== (plus (S $x) $y) (S (plus $x $y)))))

;; NEXT: try to reproduce
;; https://idris2.readthedocs.io/en/latest/tutorial/theorems.html#proving-theorems
