;; Test Deduction equality Rule
!(import! &self DeductionEqual.metta)

;; Test 1:
!(, (≞ P (PrCnt 1 0.1))
    (≞ Q (PrCnt 1 0.1))
    (≞ R (PrCnt 1 0.1))
    (≞ (→ P Q) (PrCnt 1 0.5))
    (≞ (→ Q R) (PrCnt 1 0.5)))

;; Test 2: Apply deduction rule over the result
;; we get from test 1 as an input.
!(let $PR
    (,  (≞ P (PrCnt 1 0.1))
        (≞ Q (PrCnt 1 0.1))
        (≞ R (PrCnt 1 0.1))
        (≞ (→ P Q) (PrCnt 1 0.5))
        (≞ (→ Q R) (PrCnt 1 0.5)))
    (,
    (≞ P (PrCnt 1 0.1))
    (≞ R (PrCnt 1 0.1))
    (≞ S (PrCnt 1 0.1))
    $PR
    (≞ (→ R S) (PrCnt 1 0.5))))
