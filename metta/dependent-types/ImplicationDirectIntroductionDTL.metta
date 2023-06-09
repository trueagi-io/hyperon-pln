;; MeTTa port of the Implication Direct Introduction PLN rule, encoded
;; as dependent types, i.e. propositions as types.
;;
;; See ImplicationDirectIntroductionEntail.metta for more detail on a
;; pseudo formal description.
;;
;; In the case of dependent types, inference rules are constructors of
;; the propositions to be proven.  Then a proof is an tree composed of
;; calls of such constructors.
;;
;; For instance assuming two inference rules
;;
;; ImplicationDirectIntroduction (IDI, for short)
;; Deduction (DED, for short)
;;
;; The following inference tree
;;
;; ...            ...
;; -----(IDI)     -----(IDI)
;; P → Q          Q → R
;; ---------------------(DED)
;;         P → R
;;
;; is represented by the following MeTTa expression
;;
;; (Deduction
;;    (ImplicationDirectIntroduction ...)
;;    (ImplicationDirectIntroduction ...))
;;
;; where the premises of ImplicationDirectIntroduction are left
;; undefined for now.
;;
;; How such propositions as types can be defined still remains to be
;; determined but ideally it may look something like
;;
;; (: Deduction
;;    (-> (≞ (→ $P $Q) $TV1)
;;        (≞ (→ $Q $R) $TV2)
;;        (≞ (→ $P $R) (ded_formula $TV1 $TV2))))
;;
;; where ≞, → are dependent types, and formula is just a regular metta
;; function.

;; Import modules
!(import! &self ../common/truthvalue/EvidentialTruthValue.metta)
!(import! &self ../common/formula/ImplicationDirectIntroductionFormula.metta)

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; All rules are implemented as constructors of propositions encoded
;; as types.

;; To deal with an abritrary number of pieces of evidence the rule is
;; defined inductively.

;; Base case (axiomatic rule):
;;
;; p→q ≞ (ETV ∅ (STV 1 0))
(: implication-direct-introduction-axiom (-> Atom))
(= (implication-direct-introduction-axiom)
   (: IDIAxiom (≞ (→ $p $q) (ETV ∅ (STV 1 0)))))

;; Recursive case (inductive rule):
;;
;; (p a) ≞ patv
;; (q a) ≞ qatv
;; p→q ≞ (ETV ev pqtv)
;; a ∉ ev
;; ⊢
;; p→q ≞ (ETV (insert a ev) tv)
;;
;; where tv is calculated as defined further below.
(: implication-direct-introduction-rule (-> Atom))
(= (implication-direct-introduction-rule)
   (: IDIInduction
      (-> (≞ ($p $a) (Bl $pa))
          (≞ ($q $a) (Bl $qa))
          (≞ (→ $p $q) (ETV $ev $pqtv))
          (∉ $a $ev)
          (≞ (→ $p $q) (ETV (insert $a $ev) (direct_introduction $pa $qa $pqtv))))))
