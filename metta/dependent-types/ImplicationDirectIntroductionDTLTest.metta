;; Test Implication Direct Introduction DTL Rule

;; Import modules
!(import! &self ImplicationDirectIntroductionDTL.metta)
!(import! &self ../synthesis/Synthesize.metta)

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose ((: P2 (⊷ P (fromNumber 2) True))
                    (: Q2 (⊷ Q (fromNumber 2) False))
                    (: P7 (⊷ P (fromNumber 7) True))
                    (: Q7 (⊷ Q (fromNumber 7) True)))))
;; Axioms are placed in the kb as well
(= (kb) (zero-lt-succ-axiom))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose ((succ-monotonicity-rule)
                    (implication-direct-introduction-base-rule)
                    (implication-direct-introduction-recursive-rule))))

;; Test base rule (one piece of evidence)
;;
;; Build the following inference tree
;;
;; --------(P2)     --------(Q2)
;; (P 2) = ⊤        (Q 2) = ⊥
;; --------------------------(IDIBase)
;; P → Q ≞ ((:: 2 ∅), <0 0.5>)
! "===== Test base rule (built-in type checker) ====="
(: base_prf (≞ (→ P Q) (ETV (:: (fromNumber 2) ∅) (STV 0 (count->confidence 1)))))
(= base_prf IDIBase)
!(base_prf)
!(get-type base_prf)

;; Test recursive rule
;;
;; Build the following inference tree
;;
;;                 --------(P2)     --------(Q2)
;;                 (P 2) = ⊤        (Q 2) = ⊥
;;                 --------------------------(IDIBase)
;;                 P → Q ≞ ((:: 2 ∅), <0 0.5>)
;;                              |               -----(ZeroLTSucc)
;;                              |               0 ⍃ 5
;;                              |               -----(SuccMonotonicity)
;;                              |               1 ⍃ 6
;; --------(P7)  --------(Q7)   |               -----(SuccMonotonicity)
;; (P 7) = ⊤     (Q 7) = ⊤      |               2 ⍃ 7
;; --------------------------------------------------(IDIRecursive)
;;           P → Q ≞ ((:: 7 (:: 2 ∅)), <0.5 0.6667>)
! "===== Test recursive rule (built-in type checker) ====="
(: recursive_prf (≞ (→ P Q) $etv))
(= recursive_prf (IDIRecursive P7
                               Q7
                               (IDIBase P2 Q2)
                               (SuccMonotonicity (SuccMonotonicity ZeroLTSucc))))
!(recursive_prf)
!(get-type recursive_prf)

;; Test synthesizer
! "===== Prove that 2 < 7 (synthesizer) ====="
!(synthesize (: $proof (⍃ (fromNumber 2) (fromNumber 7))) (fromNumber 2) kb rb)

! "===== Prove P→Q using base rule (synthesizer) ====="
!(synthesize (: $proof (≞ (→ P Q) $etv)) (fromNumber 1) kb rb)

! "===== Prove P→Q using base, recursive and order rules (synthesizer) ====="
!(synthesize (: $proof (≞ (→ P Q) $etv)) (fromNumber 3) kb rb)
