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
          (: Ind_plus (=== (plus (S $x) $y) (S (plus $x $y)))))))

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

          ;; Unary replacement
          (: UnaryReplacement (-> ;; Premises
                                  (=== $x $x')
                                  ($op $x)
                                  ;; Conclusion
                                  ($op $x')))

          ;; Binary replacement
          (: BinaryReplacement (-> ;; Premises
                                   (=== $x $x')
                                   (=== $y $y')
                                   ($op $x $y)
                                   ;; Conclusion
                                   ($op $x' $y')))

          ;; Unary structural preservation of equality
          (: UnaryStructuralPreservationEquality (-> ;; Premise
                                                     (=== $x $x')
                                                     ;; Conclusion
                                                     (=== ($op $x) ($op $x'))))

;; Prove that Z is left identity of plus
!(synthesize (: $proof (=== (plus Z $y) $y)) kb rb Z)

;; Prove that 1 + 0 = 1
;;
;; Proof tree should look like
;;
;; -----------------(Base_plus)  ----------------------------------(Ind_plus)
;; (=== (plus Z Z) Z)            (=== (plus (S Z) Z) (S (plus Z Z)))
;; ----------------------------------------------------------------(Replacement)
;;                     (=== (plus (S Z) Z) (S Z))
;;
!(synthesize (: $proof (=== (plus (S Z) Z) (S Z))) kb rb (fromNumber 2))

;; Replacement, always goes from left to right
(=== $x $x')
($op $x)
⊢
($op $x')

;; Structural Induction of Equality
(=== $x $x')
(=== $y $y')
⊢
(=== ($op $x $y) ($op $x' $y'))
