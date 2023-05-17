;; Formula and other functions used for the deduction rule

;; Import modules
!(import! &self ../truthvalue/TruthValue.metta)
!(import! &self ../Num.metta)

; Consistency Conditions
(: smallest-intersection-probability (-> Number Number Number))
(= (smallest-intersection-probability $sA $sB)
  (clamp (/ (- (+ $sA $sB) 1) $sA) 0 1))

(: largest-intersection-probability (-> Number Number Number))
(= (largest-intersection-probability $sA $sB)
  (clamp (/ $sB $sA) 0 1))

(: conditional-probability-consistency (-> Number Number Number Bool))
(= (conditional-probability-consistency $sA $sB $sAB)
  (and (< 0 $sA)
       (and (<= (smallest-intersection-probability $sA $sB) $sAB)
            (<= $sAB (largest-intersection-probability $sA $sB)))))

;; Main Formula
(: simple-deduction-strength-formula (-> Number Number Number Number Number Number))
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

;; Deduction formula
(= (ded_formula $ptv $qtv $rtv $pqtv $qrtv)
    (let*
        (($cP (confidence $ptv))
         ($cQ (confidence $qtv))
         ($cR (confidence $rtv))
         ($cPQ (confidence $pqtv))
         ($cQR (confidence $qrtv))
         ($sPQ (mode $pqtv))
         ($sQR (mode $qrtv))
         ($sP (mode $ptv))
         ($sQ (mode $qtv))
         ($sR (mode $rtv)))
        (let*
            (($sPR (simple-deduction-strength-formula $sP $sQ $sR $sPQ $sQR))
             ($cPR (min $cP (min $cQ (min $cR (min $cPQ $cQR))))))
            (if (== $sPR 0)
                (PrCnt 1 0)
                (PrCnt $sPR $cPR)))))
