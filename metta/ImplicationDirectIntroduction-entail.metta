;; MeTTa port of the Implication Direct Introduction PLN rule, encoded
;; as the entail relationship, ⊢
;;
;; (≞ (P a₁) p₁)
;; ...
;; (≞ (P aₙ) pₙ)
;; (≞ (Q a₁) q₁)
;; ...
;; (≞ (Q aₙ) qₙ)
;; ⊢
;; (≞ (→ P Q) tv)
;;
;; where pᵢ (resp. qᵢ) are of boolean type representing whether (P aᵢ)
;; (resp. (Q aᵢ)) has been observed as True or False, and tv
;; represents the resulting truth value of the conclusion.
;;
;; The equality symbol ≞ is specifically used to represent the measure
;; of an event, may this measure be boolean, probabilistic (first or
;; second order), or otherwise.  The idea is to not conflate event and
;; measure to avoid downstream contradictions.
;;
;; NEXT: keep track of the evidence.  Could be stored in ≞, ⊢ or the
;; truth value.

;;;;;;;;;;;;;;;;;;;;;;
;; Truth Value Type ;;
;;;;;;;;;;;;;;;;;;;;;;

;; TruthValue type
(: TruthValue Type)

;; Boolean TV constructor
(: Bl (-> Bool TruthValue))

;; First order probability TV constructor, i.e. mere probability.
(: Pr (-> Number TruthValue))

;; Second order probability TV constructor, i.e. probability and count.
(: PrCnt (-> Number Number TruthValue))

;; Evidence type
(: Evidence (-> Set Type))

;; Evidential TruthValue type
(: EvidentialTruthValue (-> TruthValue Evidence Type))

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; Define rule.  Only two premises for now.  NEXT: support an
;; arbitrary number of permises, probably using induction.
(⊢ (≞ ($P $a) (Bl $p))
   (≞ ($Q $a) (Bl $q))
   (≞ (→ $P $Q) (formula $p $q)))

;; Define rule formula
(= (formula False $_)
   (PrCnt 1.0 0.0))
(= (formula True True)
   (PrCnt 1.0 1.0))
(= (formula True False)
   (PrCnt 0.0 1.0))

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; KB
(= (PA) (≞ (P A) (Bl True)))
(= (QA) (≞ (Q A) (Bl False)))

;; Formula
!(formula True False)

;; Forward inference step
!(match &self (⊢ (PA) (QA) $conclusion) $conclusion)

;; Backward inference step
!(match &self (⊢ $p1 $p2 (≞ (→ P Q) $tv)) (S $p1 $p2 $tv))
