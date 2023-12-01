;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Definition of an omnichainer, Nat, plus and some proofs.            ;;
;;                                                                     ;;
;; The main proof of interest is that Z is the right identity of plus. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The omnichainer is expected to have the following properties:
;;
;; - Rules are curried.
;;
;; - There is no distinction between axioms and rules.
;;
;; - Rule composition, using the traditional composition operator `.`
;;   is included in the chaining process (whether it is embedded in
;;   the chainer implementation or is an external rule remains to be
;;   determined).
;;
;; Given such omnichainer, the inductive property that x + 0 = x
;; implies (S x) + 0 = (S x) should then have the following proof:
;;
;; (. (EqTrans Rec_plus) EqStruct1)

;; NEXT
