;; MeTTa port for deduction PLN rule
;; as the entail relationship, ⊢
;;
;; (≞ P ptv)
;; (≞ Q qtv)
;; (≞ R rtv)
;; (≞ (→ P Q) tv1)
;; (≞ (→ Q R) tv2)
;; ⊢
;; (≞ (→ P R) tv)
;;
;; where ptv, qtv and rtv are of boolean type representing whether P, Q and R has been observed as True or False. tv1 and tv2 represents the truth value for the implication (→ P Q) and (→ Q R) respectively. tv represents the resulting truth value of the conclusion.

;; Import TruthValue
(import &self "TruthValue.metta")

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; Define rule
(⊢ (≞ (→ $P $Q) (PrCnt $sPQ $cPQ)) 
   (≞ (→ $Q $R) (PrCnt $sQR $cQR))
   (≞ (→ $P $R) (formula ($P $Q $R (→ $P $Q) (→ $Q $R)))))

;; TODO: Implement Deduction formula
(= (formula ($P $Q $R $PQ $QR)) (PrCnt 1 0))

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

(= (AB) (≞ (→ A B) (PrCnt 1 0)))
(= (BC) (≞ (→ B C) (PrCnt 1 0)))

;; Forward chain
;; BUG?
!(match &self (⊢ (AB) (BC) $res) $res) ; didn't work

; work around
!(match &self (, (= (AB) $ab) (= (BC) $bc))
    (match &self (⊢ $ab $bc $res) $res))

;; Backward chain
!(match &self (⊢ $ab $bc (≞ (→ A C) $tv)) (S $ab $bc $tv))
