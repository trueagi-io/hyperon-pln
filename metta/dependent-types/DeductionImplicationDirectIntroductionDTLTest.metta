; Test DeductionDTL and ImplicationDirectionIntroductionDTL rules

;; Improt the rules
!(import! &self ImplicationDirectIntroductionDTL.metta)
!(import! &self DeductionDTL.metta)

;; Background knowledge
(: Pm (≞ P (STV 1 0.1)))
(: Qm (≞ Q (STV 1 0.5)))
(: Rm (≞ R (STV 1 0.1)))
(: P42m (≞ (P 42) (Bl True)))
(: Q42m (≞ (Q 42) (Bl False)))
(: QRm (≞ (→ Q R) (STV 1 0.5)))

;; Test a combination of deduction and implication direct introduction
;;
;; Build the following inference tree
;;
;;                                               ---------(P42m) ---------(Q42m) -----------------(IDIAxiom) -----(NotInEmpty)
;;                                               (P 42) ≞ ⊤      (Q 42) ≞ ⊥      P → Q ≞ (∅, <1 0>)          42 ∉ ∅
;; ----------(Pm) ----------(Qm) ----------(Rm)  ------------------------------------------------------------------(IDIInduction)  --------------(QRm)
;; P ≞ <1 0.1>    Q ≞ <1 0.1>    R ≞ <1 0.1>                                          P → Q ≞ $etv                                 Q → R ≞ <1 0.5>
;; ----------------------------------------------------------------------------------------------------------------------------------------------(Deduction)
;;                                                             P → Q ≞ $tv
(: deduction_idi_prf (≞ (→ P Q) $tv))
(= deduction_idi_prf (Deduction Pm Qm Rm (IDIInduction P42m Q42m IDIAxiom NotInEmpty) QRm))
!(deduction_idi_prf)
!(get-type deduction_idi_prf)
;; NEXT: use synthesizer to infer the type, then ultimately the proof tree
