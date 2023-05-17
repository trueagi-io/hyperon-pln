!(import! &self Num.metta)

!(fromNumber 1)                         ; (S Z)
!(fromNat (S (S Z)))                    ; 2
!(ceil 2.4)                             ; 3
!(abs -10)                              ; 10
!(approxEq 10 10.0001 1e-3)             ; True
!(approxEq 10 10.0001 1e-9)             ; False
