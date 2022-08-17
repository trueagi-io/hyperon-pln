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
;;        (≞ (→ $P $R) (formula $TV1 $TV2))))
;;
;; where ≞, → are dependent types, and formula is just a regular metta
;; function.

;; Import modules
!(import! &self "TruthValue.metta")
!(import! &self "Set.metta")

;;;;;;;;;;;;;;;;;;;;;
;; Rule Definition ;;
;;;;;;;;;;;;;;;;;;;;;

;; All rules are implemented as constructors of propositions encoded
;; as types.

;; To deal with an abritrary number of pieces of evidence the rule is
;; defined inductively.

;; Base case (axiomatic rule):
;;
;; p→q ≞ (ETV Empty (PrCnt 1 0))
(: IDIAxiom
   (≞ (→ $p $q) (ETV Empty (PrCnt 1 0))))

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
(: IDIInduction
   (-> (≞ ($p $a) $patv)
       (≞ ($q $a) $qatv)
       (≞ (→ $p $q) (ETV $ev $pqtv))
       (∉ $a $ev)
       (≞ (→ $p $q) (ETV (insert $a $ev) (formula $ptv $qtv $pqtv)))))

;; Rule formula, where tv, the resulting truth value is calculated as
;; follows
;;
;; tv = (pos_cnt + pb*qb) / (cnt + pb)
;;
;; where pos_cnt is the positive count of pqtv
;;       cnt is the total count of pqtv
;;       pb is 1 if patv is (Bl True), 0 otherwise
;;       qb is 1 if qatv is (Bl True), 0 otherwise
;;
;; For now it is assumed that patv and qatv are boolean truth values.
(= (formula $ptv $qtv $pqtv)
   (let* (($pb (mode $ptv))
          ($qb (mode $qtv))
          ($cnt (+ (count $pqtv) $pb)))
     (if (< 0 $cnt)
         (PrCnt (/ (+ (pos_count $pqtv) (* $pb $qb)) $cnt) $cnt)
         (PrCnt 1 0))))
