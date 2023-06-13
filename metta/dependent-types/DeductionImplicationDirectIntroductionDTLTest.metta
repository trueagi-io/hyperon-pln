; Test DeductionDTL and ImplicationDirectionIntroductionDTL rules

;; Improt the rules
!(import! &self ImplicationDirectIntroductionDTL.metta)
!(import! &self DeductionDTL.metta)

;; Background knowledge
(: Pm (≞ P (STV 0.2 0.1)))
(: Qm (≞ Q (STV 0.3 0.5)))
(: Rm (≞ R (STV 0.4 0.1)))
(: P42m (≘ (P 42) True))
(: Q42m (≘ (Q 42) True))
(: QRm (≞ (→ Q R) (STV 1 0.5)))

;; Test a combination of deduction and implication direct introduction
;;
;; Build the following inference tree
;;
;;                                                     ---------(P42m) ---------(Q42m) -----------------(IDIAxiom) -----(NothingInEmpty)
;;                                                     (P 42) = ⊤      (Q 42) = ⊤      P → Q ≞ (∅, <1 0>)          42 ∉ ∅
;; ------------(Pm) ------------(Qm) ------------(Rm)  ------------------------------------------------------------------(IDIInduction)  -----------------(QRm)
;; P ≞ <0.2 0.1>    Q ≞ <0.3 0.1>    R ≞ <0.4 0.1>                                          P → Q ≞ $etv                                 Q → R ≞ <0.9 0.8>
;; ----------------------------------------------------------------------------------------------------------------------------------------------(Deduction)
;;                                                                   P → Q ≞ $tv
(: deduction_idi_prf (≞ (→ P Q) $tv))
(= deduction_idi_prf (Deduction Pm Qm Rm (IDIInduction P42m Q42m IDIAxiom NotInEmpty) QRm))
!(deduction_idi_prf)
!(get-type deduction_idi_prf)
;; NEXT: use synthesizer to infer the type, then ultimately the proof tree
