;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of Nat and proofs ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Import synthesizer (Nat is already defined in it)
!(import! &self ../synthesis/Synthesize.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose
         (;; Equality is reflexive.  We use === instead of == to make sure it
          ;; ;; does not get reduced by the MeTTa interpreter.
          ;; (: EqRefl (=== $x $x))

          ;; Base case of append function definition
          (: Base_plus (=== (plus Z $y) $y))

          ;; ;; Recursive step of append function definition
          ;; (: Rec_plus (=== (plus (S $x) $y) (S (plus $x $y))))

          (: IndZRID_plus (-> (ZRID_plus $x) (ZRID_plus (S $x))))

          ;; Property expressing that for any natural, Z is the right
          ;; identity of plus.  Note that the property definition is
          ;; the axiom, not the property itself as it is what we
          ;; attempt to prove.
          (: PropZRID_plus (=== (ZRID_plus $x) (=== (plus $x Z) $x))))))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose
         (;; Equality is transitive
          ;; (: EqTrans (-> ;; Premises
          ;;                (=== $x $y)
          ;;                (=== $y $z)
          ;;                ;; Conclusion
          ;;                (=== $x $z)))

          ;; Equality is symmetric
          (: EqSym (-> ;; Premise
                       (=== $x $y)
                       ;; Conclusion
                       (=== $y $x)))

          ;; ;; Structural preservation of equality
          ;; (: EqStruct1 (-> ;; Premise
          ;;                  (=== $x $x')
          ;;                  ;; Conclusion
          ;;                  (=== ($op $x) ($op $x'))))
          ;; (: EqStruct2 (-> ;; Premises
          ;;                  (=== $x $x')
          ;;                  (=== $y $y')
          ;;                  ;; Conclusion
          ;;                  (=== ($op $x $y) ($op $x' $y'))))

          ;; Rule of replacement
          (: Repl0 (-> ;; Premise
                       (=== $x $x')
                       $x
                       ;; Conclusion
                       $x'))
          ;; (: Repl1 (-> ;; Premises
          ;;              (=== $x $x')
          ;;              ($op $x)
          ;;              ;; Conclusion
          ;;              ($op $x')))
          ;; (: Repl2 (-> ;; Premises
          ;;              (=== $x $x')
          ;;              (=== $y $y')
          ;;              ($op $x $y)
          ;;              ;; Conclusion
          ;;              ($op $x' $y')))

          ;; (: IndZRID_plus (-> (ZRID_plus $x) (ZRID_plus (S $x))))

          ;; Structural induction on Nat
          ;; (: IndNat (-> ;; Premises
          ;;               (: $p (-> Nat Type)) ; property
          ;;               ($p Z)               ; base case
          ;;               (-> (: $x Nat)
          ;;               ($p $x)
          ;;               ($p (S $x)))     ; inductive step
          ;;               ;; Conclusion
          ;;               (-> (: $x' Nat) ($p $x')))))))
          ;; Structural induction on Nat
          (: IndNat (-> ;; Premises
                        ($p Z)               ; base case
                        (-> ($p $x)
                            ($p (S $x)))     ; inductive step
                        ;; Conclusion
                        ($p $x'))))))

;; (: IndZRID_plus (-> (ZRID_plus $x) (ZRID_plus (S $x))))
;; (=== (IndZRID_plus $prf) $prf)

;; ;; Prove that Z is left identity of plus
;; !(synthesize (: $prf (=== (plus Z $y) $y)) kb rb Z)

;; ;; Prove that (=== (plus Z Z) Z)
;; !(synthesize (: $prf (=== (plus Z Z) Z)) kb rb Z)

;; ;; Prove that (=== (=== (plus Z Z) Z) (ZRID_plus Z)).
;; ;;
;; ;; The following proof tree is expected to prove that:
;; ;;
;; ;; -------------------------------------(PropZRID_plus)
;; ;; (=== (ZRID_plus Z) (=== (plus Z Z) Z))
;; ;; -------------------------------------(EqSym)
;; ;; (=== (=== (plus Z Z) Z) (ZRID_plus Z))
;; ;;
;; ;; on in MeTTa format:
;; ;;
;; ;; (EqSym PropZRID_plus)
;; !(synthesize (: $prf (=== (=== (plus Z Z) Z) (ZRID_plus Z))) kb rb (fromNumber 1))

;; ;; Prove that (ZRID_plus Z) holds.
;; ;;
;; ;; The following proof tree does that:
;; ;;
;; ;; -------------------------------------(PropZRID_plus)
;; ;; (=== (ZRID_plus Z) (=== (plus Z Z) Z))
;; ;; -------------------------------------(EqSym)  -----------------(Base_plus)
;; ;; (=== (=== (plus Z Z) Z) (ZRID_plus Z))        (=== (plus Z Z) Z)
;; ;; ---------------------------------------------------------------(Repl0)
;; ;;                        (ZRID_plus Z)
;; ;;
;; ;; or in MeTTa format:
;; ;;
;; ;; (Repl0 (EqSym PropZRID_plus) Base_plus)
;; !(synthesize (: $prf (ZRID_plus Z)) kb rb (fromNumber 2))

;; Prove that (-> (ZRID_plus $x) (ZRID_plus (S $x)))
;;
;; The following proof tree is expected to prove it:
;;
;;
;; (-> NEXT
;; -------------------------------------------------------------------------------------
;; (-> (=== (plus $x Z) $x) (=== (plus (S $x) Z) (S $x)))
;; ---------------------------------------------------------------------------------------------
;; (-> (ZRID_plus $x) (ZRID_plus (S $x)))

!(synthesize (: $prf (→ (ZRID_plus $x) (ZRID_plus (S $x)))) kb rb Z)

;; Prove that Z is the right identity of plus
;;
;; -------------------------------------(PropZRID_plus)
;; (=== (ZRID_plus Z) (=== (plus Z Z) Z))
;; -------------------------------------(EqSym)  -----------------(Base_plus)
;; (=== (=== (plus Z Z) Z) (ZRID_plus Z))        (=== (plus Z Z) Z)
;; ---------------------------------------------------------------(Repl0)         -------------------------------------(IndZRID_plus)
;;                        (ZRID_plus Z)                                           (-> (ZRID_plus $x) (ZRID_plus (S $x)))
;;                        ---------------------------------------------------------------------------------------------(StructuralInductionNat)
;;                                                               (ZRID_plus $x)
!(synthesize (: $prf (ZRID_plus $x)) kb rb (fromNumber 3))
