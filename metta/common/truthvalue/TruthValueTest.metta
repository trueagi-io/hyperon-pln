;; Import TruthValue
!(import! &self TruthValue.metta)

!(count->confidence 10)                 ; 0.9090909090909091
!(confidence->count 0.9)                ; 9.000000000000002
!(mode (STV 0.1 0.2))                   ; 0.1
!(mean (STV 0.1 0.9))                   ; 0.14
!(confidence (STV 0.1 0.2))             ; 0.2
!(count (STV 0.1 0.9))                  ; 9.000000000000002
