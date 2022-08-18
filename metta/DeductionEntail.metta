;; MeTTa port for deduction PLN rule
;; as the entail relationship, ⊢
;;
;; (≞ P ptv)
;; (≞ Q qtv)
;; (≞ R rtv)
;; (≞ (→ P Q) tv1)
;; (≞ (→ Q R) tv2)
;; ⊢
;; (≞ (→ P R) TV)
;;
;; where ptv, qtv, rtv, tv1 and tv2 are truth values of the
;; premises P, Q, R, (→ P Q) and (→ Q R) respectively.
;; TV represents the resulting truth value of the conclusion.

;; Import TruthValue
!(import! &self "TruthValue.metta")

;; Import helper functions
!(import! &self "Formula.metta")

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

(⊢ ;; premises
   (≞ $P $ptv)
   (≞ $Q $qtv)
   (≞ $R $rtv)
   (≞ (→ $P $Q) $pqtv)
   (≞ (→ $Q $R) $qrtv)
   ;; conclusion
   (≞ (→ $P $R) (formula ($ptv $qtv $rtv $pqtv $qrtv))))

(= (formula ($ptv $qtv $rtv $pqtv $qrtv))
    (let* 
        (($cP (confidence $ptv))
         ($cQ (confidence $qtv))
         ($cR (confidence $rtv))
         ($cPQ (confidence $pqtv))
         ($cQR (confidence $qrtv))
         ($sPQ (mode $pqtv))
         ($sQR (mode $qrtv))
         ($sP  (mode $ptv))
         ($sQ (mode $qtv))
         ($sR (mode $rtv)))
        (let* 
            (($sPR (simple-deduction-strength-formula $sP $sQ $sR $sPQ $sQR))
             ($cPR (min $cP (min $cQ (min $cR (min $cPQ $cQR))))))
            (if (== $sPR 0)
                (PrCnt 1 0)
                (PrCnt $sPR $cPR)))))
