;; Test Implication Direct Introduction Entail Rule

!(import! &self "ImplicationDirectIntroductionEntail.metta")

;; Test formula
!(formula (Bl True) (Bl False) (PrCnt 1 1))

;; KB
(= (PA) (≞ (P A) (Bl True)))
(= (QA) (≞ (Q A) (Bl False)))

;; ;; Forward inference step
;; !(let $pa (PA)
;;    (let $qa (QA)
;;      (match &self (⊢ $pa $qa $conclusion) $conclusion)))

;; ;; Backward inference step
;; !(match &self (⊢ $p1 $p2 (≞ (→ P Q) $tv)) (S $p1 $p2 $tv))
