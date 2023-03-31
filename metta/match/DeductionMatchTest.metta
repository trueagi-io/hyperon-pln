;; Test Deduction match Rule
!(import! &self DeductionMatch.metta)

(≞ P (PrCnt 1 0.1))
(≞ Q (PrCnt 1 0.1))
(≞ R (PrCnt 1 0.1))
(≞ (→ P Q) (PrCnt 1 0.5))
(≞ (→ Q R) (PrCnt 1 0.5))

!(deduction_match &self)

