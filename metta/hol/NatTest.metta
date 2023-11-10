;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of Nat and proofs ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Import synthesizer (Nat is already defined in it)
!(import! &self ../synthesis/Synthesize.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose
         (;; Equality is reflexive.  We use === instead of == to make sure it
          ;; does not get reduced by the MeTTa interpreter.
          (: EqRefl (=== $x $x))

          ;; Base case of append function definition
          (: Base_plus (=== (plus Z $y) $y))

          ;; Inductive case of append function definition
          (: Ind_plus (=== (plus (S $x) $y) (S (plus $x $y))))

          ;; Property expressing that for any natural, Z is the right
          ;; identity of plus.  Note that the property definition is
          ;; the axiom, not the property itself as it is what we
          ;; attempt to prove.
          (: PropZRID_plus (=== (ZRID_plus $x) (=== (plus $x Z) $x))))))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose
         (;; Equality is transitive
          (: EqTrans (-> ;; Premises
                         (=== $x $y)
                         (=== $y $z)
                         ;; Conclusion
                         (=== $x $z)))

          ;; Equality is symmetric
          (: EqSym (-> ;; Premise
                       (=== $x $y)
                       ;; Conclusion
                       (=== $y $x)))

          ;; Induction on List
          (: NatInduction (-> ;; Premises
                              (: $p (-> Nat Type)) ; property
                              ($p Z)               ; base
                              (-> (: $x Nat)
                                  ($p $x)
                                  ($p (S $x)))     ; induction
                              ;; Conclusion
                              (-> (: $x' Nat) ($p $x')))))))

(: IndZRID_plus (-> (ZRID_plus $x) (ZRID_plus (S $x))))
(=== (IndZRID_plus $prf) NEXT)

;; Prove that Z is left identity of plus
!(synthesize (: $proof (=== (plus Z $y) $y)) kb rb Z)

;; Prove that 1 + 0 = 1
;;
;; Proof tree should look like
;;
;; ----------------------------------(Ind_plus)  -----------------(Base_plus)
;; (=== (plus (S Z) Z) (S (plus Z Z)))           (=== (plus Z Z) Z)
;; ---------------------------------------------------------------(Replacement)
;;                         (=== (plus (S Z) Z) (S Z))
!(synthesize (: $proof (=== (plus (S Z) Z) (S Z))) kb rb (fromNumber 3))

;; ;; Prove that 1 + 1 = 2
;; ;;
;; ;; Proof tree should look like
;; ;;

;; ------------------------------------------(Ind_plus)
;; (=== (plus (S Z) (S Z)) (S (plus Z (S Z))))
;; ----------------------------------------------------
;; (=== (plus (S Z) (S Z)) (S (S Z)))
;; !(synthesize (: $proof (=== (plus (S Z) (S Z)) (S (S Z)))) kb rb (fromNumber 2))

;; ;; Prove that Z is the right identity of plus
;; !(synthesize (: $proof (=== (plus $x Z) $x)) kb rb (fromNumber 3))
