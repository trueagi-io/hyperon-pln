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
!(import! &self "formula.metta")

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

;; TODO: Implement Deduction formula
(= (formula ($ptv $qtv $rtv $pqtv $qrtv)) (PrCnt 1 0))

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

(= (P) (≞ (P a) (PrCnt 1 0)))
(= (Q) (≞ (Q a) (PrCnt 1 0)))
(= (R) (≞ (R a) (PrCnt 1 0)))
(= (PQ) (≞ (→ P Q) (PrCnt 0.345 0.91941)))
(= (QR) (≞ (→ Q R) (PrCnt 0.5 0.91941)))

;; Forward chain
!(let* (($p (P))
        ($q (Q))
        ($r (R))
        ($pq (PQ))
        ($qr (QR)))
    (match &self (⊢ $p $q $r $pq $qr $res) $res))

;; Backward chain
!(match &self (⊢ $p $q $r $pq $qr (≞ (→ P R) $tv)) (S $p $q $r $pq $qr $tv))
