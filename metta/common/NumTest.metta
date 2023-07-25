;; Import modules
!(import! &self Num.metta)
!(import! &self ../synthesis/Synthesize.metta)

;; Test rudimentary functions
!(assertEqual
  (fromNumber 1)
  (S Z))

!(assertEqual
  (fromNat (S (S Z)))
  2)

!(assertEqual
  (ceil 2.4)
  3)

!(assertEqual
  (abs -10)
  10)

!(assertEqual
  (approxEq 10 10.0001 1e-3)
  True)

!(assertEqual
  (approxEq 10 10.0001 1e-9)
  False)

;; Test reasoning about comparison over Natural
(= (kb) (zero-lt-succ-axiom))
(= (rb) (succ-monotonicity-rule))
!(assertEqual
  (synthesize (: $proof (⋖ Z (S Z))) Z kb rb)
  (: ZeroLTSucc (⋖ Z (S Z))))
!(assertEqual
  (synthesize (: $proof (⋖ (fromNumber 1) (fromNumber 3))) (S Z) kb rb)
  (: (SuccMonotonicity ZeroLTSucc) (⋖ (fromNumber 1) (fromNumber 3))))
!(assertEqual
  (synthesize (: $proof (⋖ (fromNumber 2) (fromNumber 7))) (fromNumber 5) kb rb)
  (: (SuccMonotonicity (SuccMonotonicity ZeroLTSucc)) (⋖ (fromNumber 2) (fromNumber 7))))
