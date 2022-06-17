;; MeTTa port of the Implication Direct Introduction PLN Rule
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
;; (resp. (Q aᵢ)) has been observed as True or False, and tv represent
;; the resulting truth value of the conclusion.
;;
;; The equality symbol ≞ is specifically used to represent the measure
;; of an event, may this measure be boolean, probabilistic (first or
;; second order), or perhaps otherwise.  The idea is to not conflate
;; event and measure to avoid downstream contradictions.
;;
;; NEXT: introduce evidence relation (i.e. keep track of the evidence
;; in the introduced implication).
