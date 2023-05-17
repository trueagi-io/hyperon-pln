;; MeTTa port for deduction PLN rule
;; as DTL (Dependent Type Language)
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

!(import! &self ../common/formula/DeductionFormula.metta)
!(import! &self ../common/truthvalue/MeasEq.metta)

(: Deduction
    (-> (≞ $p $ptv)
        (≞ $q $qtv)
        (≞ $r $rtv)
        (≞ (→ $p $q) $pqtv)
        (≞ (→ $q $r) $qrtv)
        (≞ (→ $p $r) (ded_formula $ptv $qtv $rtv $pqtv $qrtv))))
