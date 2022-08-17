!(import! &self "formula.metta")

;; Test
!(assertEqualToResult (max 3 4) (4))
!(assertEqualToResult (min 3 4) (3))
!(assertEqualToResult (and True True) (True))
!(assertEqualToResult (or True False) (True))
!(assertEqualToResult (<= 5 4) (False))

!(limit 2 0 1)
!(smallest-intersection-probability 0.9 0.6)
!(conditional-probability-consistency 0.9 0.6 0.5)
!(simple-deduction-strength-formula 0.9 0.6 0.5 0.3 0.4)
