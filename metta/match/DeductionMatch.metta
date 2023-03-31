;; MeTTa port for deduction PLN rule
;; using match
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

;; Import formula functions
!(import! &self ../common/DeductionFormula.metta)

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; The rule is coded as a match query
(: deduction_match (-> $kb Atom))
(= (deduction_match $kb)
   (match $kb
     ;; Premises
     (, (≞ $p $ptv)
        (≞ $q $qtv)
        (≞ $r $rtv)
        (≞ (→ $p $q) $pqtv)
        (≞ (→ $q $r) $qrtv))
     ;; Conclusion
     (≞ (→ $p $r) (ded_formula $ptv $qtv $rtv $pqtv $qrtv))))
