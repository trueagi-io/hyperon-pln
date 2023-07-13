;; MeTTa port for modus ponens PLN rule
;; as DTL (Dependent Type Language)
;;
;; (≞ P ptv)
;; (≞ (→ P Q) pqtv)
;; ⊢
;; (≞ Q qtv)
;;
;; where ptv and pqtv are truth values of the premises P and (→ P Q) respectively.
;; qtv represents the resulting truth value of the conclusion.

;; Import modules
!(import! &self ../common/truthvalue/MeasEq.metta)
!(import! &self ../common/formula/ModusPonensFormula.metta)

;; Define modus ponens rule
(: modus-ponens-rule (-> Atom))
(= (modus-ponens-rule)
   (: ModusPonens
      (-> (≞ $p $ptv)
          (≞ (→ $p $q) $pqtv)
          (≞ $q (modus-ponens-formula $ptv $pqtv)))))
