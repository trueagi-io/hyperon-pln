;; TODO: add description

!(import! &self "IfThenElse.metta")

;; Limit an number to be within a certain range
(= (limit $x $l $u)
  (max $l (min $u $x)))

;; Define max
(= (max $a $b) (if (> $a $b) $a $b))

;; Define min
(= (min $a $b) (if (< $a $b) $a $b))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $a $b) (or (< $a $b) (== $a $b)))

;; Define >=
(: >= (-> $a $a Bool))
(= (>= $a $b) (or (> $a $b) (== $a $b)))

; Consistency Conditions
(= (smallest-intersection-probability $sA $sB)
  (limit (/ (- (+ $sA $sB) 1) $sA) 0 1))

(= (largest-intersection-probability $sA $sB)
  (limit (/ $sB $sA) 0 1))

(= (conditional-probability-consistency $sA $sB $sAB)
  (and (< 0 $sA)
       (and (<= (smallest-intersection-probability $sA $sB) $sAB)
            (<= $sAB (largest-intersection-probability $sA $sB)))))

;; Main Formula
(= (simple-deduction-strength-formula $sA $sB $sC $sAB $sBC)
  (if
     (and
        (conditional-probability-consistency $sA $sB $sAB)
        (conditional-probability-consistency $sB $sC $sBC))
     ;; Preconditions are met
     (if (< 0.99 $sB)
        ;; sB tends to 1
        $sC
        ;; otherwise
        (+ (* $sAB $sBC) (/ (* (- 1 $sAB) (- $sC (* $sB $sBC))) (- 1 $sB))))
     ;; Preconditions are not met
     0))
