; Test DeductionDTL and ImplicationDirectionIntroductionDTL rules

;; Improt the rules
!(import! &self ImplicationDirectIntroductionDTL.metta)
!(import! &self DeductionDTL.metta)

;; Background knowledge
(: P42m (≞ (P 42) (Bl True)))
(: Q42m (≞ (Q 42) (Bl False)))
(: Pm (≞ P (STV 1 0.1)))
(: Qm (≞ Q (STV 1 0.5)))
(: Rm (≞ R (STV 1 0.1)))
(: QRm (≞ (→ Q R) (STV 1 0.5)))

;; Test a combination of deduction and implication direct introduction
;;
;; Build the following inference tree
;;
;; ----------(Pm) ----------(Qm) ----------(Rm)                     --------------(QRm)
;; P ≞ <1 0.1>    Q ≞ <1 0.1>    R ≞ <1 0.1>       P → Q ≞ $etv     Q → R ≞ <1 0.5>
;; --------------------------------------------------------------------------------(Deduction)
;;                                P → Q ≞ $tv

;; ---------(P42m) ---------(Q42m) -----------------(IDIAxiom) -----(NotInEmpty)
;; (P 42) ≞ ⊤      (Q 42) ≞ ⊥      P → Q ≞ (∅, <1 0>)          42 ∉ ∅
;; ------------------------------------------------------------------(IDIInduction)
;;                              P → Q ≞ $etv
;;
;;

;; NEXT: port to DTL
;; ;; Matching query to do IDI and deduction rules
;; !(match &self
;;     ;; Premises
;;     (, (≞ $p $ptv)
;;        (≞ $q $qtv)
;;        (≞ $r $rtv)
;;        (≞ ($p $a) $patv)
;;        (≞ ($q $a) $qatv)
;;        (∉ $a $ev)
;;        (≞ (→ $q $r) $qrtv))
;;     ;; Conclusion
;;     (deduction (≞ $p $ptv)
;;                (≞ $q $qtv)
;;                (≞ $r $rtv)
;;                (idi_induction (≞ ($p $a) $patv) (≞ ($q $a) $qatv) (idi_axiom) (∉ $a $ev))
;;                (≞ (→ $q $r) $qrtv)))
