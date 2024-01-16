;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inference control experiments.  Attempt to reproduce the OpenCog
;; Classic inference control meta learning
;; https://github.com/opencog/pln/tree/master/examples/pln/inference-control-meta-learning
;;
;; Letters are replaced by months.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and Rule Base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Knowledge and rule base
!(bind! &kb (new-space))

;; For now we try to define the problem without having to define
;; Month.
;;
;; ;; January, February, etc, are months
;; !(add-atom &kb (: Jan Month))
;; !(add-atom &kb (: Feb Month))
;; !(add-atom &kb (: Mar Month))
;; !(add-atom &kb (: Apr Month))
;; !(add-atom &kb (: May Month))
;; !(add-atom &kb (: Jun Month))
;; !(add-atom &kb (: Jul Month))
;; !(add-atom &kb (: Aug Month))
;; !(add-atom &kb (: Sep Month))
;; !(add-atom &kb (: Oct Month))
;; !(add-atom &kb (: Nov Month))
;; !(add-atom &kb (: Dec Month))

;; January precedes February, which precedes Mars, etc.
!(add-atom &kb (: jf (≼ Jan Feb)))
!(add-atom &kb (: fm (≼ Feb Mar)))
!(add-atom &kb (: ma (≼ Mar Apr)))
!(add-atom &kb (: am (≼ Apr May)))
!(add-atom &kb (: mj (≼ May Jun)))
!(add-atom &kb (: jj (≼ Jun Jul)))
!(add-atom &kb (: ja (≼ Jul Aug)))
!(add-atom &kb (: as (≼ Aug Sep)))
!(add-atom &kb (: so (≼ Sep Oct)))
!(add-atom &kb (: on (≼ Oct Nov)))
!(add-atom &kb (: nd (≼ Nov Dec)))

;; Precedence is non strict, i.e. reflexive
!(add-atom &kb (: Relf (≼ $x $x)))

;; Precedence is transitive
!(add-atom &kb (: Trans (-> (≼ $x $y)
                            (-> (≼ $y $z)
                                (≼ $x $z)))))

;; Shortcut rule: January precedes all months
!(add-atom &kb (: JPA (≼ Jan $x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward Controlled Chainer ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Backward Chainer.  The arguments of the backward chainer are:
;;
;; * Context abstraction updater.  Given the current query and
;;   context, update the context before recursively calling the
;;   backward chainer on the proof abstraction.
;;
;; * Context argument updater.  Given the current query and context,
;;   update the context before recursively calling the backward
;;   chainer on the proof argument.
;;
;; * Termination predicate.  Given the current query and context,
;;   provide the condition of a conditional wrapping the base case and
;;   recursive step functions (pre-application), as well its results
;;   (post-application).  Terminating amounts to pruning the reduction
;;   (as in evaluation) branches.  For now there is only one
;;   termination predicate for both pre and post application, in the
;;   future we may want to separate it in two.
;;
;; * Query: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables that may be
;;   filled by the backward chainer.
;;
;; * Context: a context to be updated and passed to the recursive
;;   calls of the backward chainer.
;;
;; The choice of the arguments of the context updaters and the
;; termination predicate is justified as follows.  Context updaters
;; take first the query, which can be viewed an updater modulator,
;; which then takes the actual context to the return updated one.  An
;; alternative would have been to construct a contextualized query,
;; and update that contextualized query instead.  However, we do not
;; do that to guaranty that the user-programmed inference control does
;; not interfere with the correctness of the chainer.
(: bc (-> (-> $a $ct $ct)      ; Context abstraction updater
          (-> $a $ct $ct)      ; Context argument updater
          (-> $a $ct Bool)     ; Termination predicate
          $ct                  ; Context
          $a                   ; Query
          $a))                 ; Query result

;; Base case.  Terminates no matter what, either by pruning the branch
;; or by querying the kb.  Thanks to non-determinism, terminating the
;; branch does not terminate alternative branches.
(= (bc $absupd $argupd $tmnpred $ctx (: $prf $ccln))
   ;; Pre-application termination conditional
   (if ($tmnpred (: $prf $ccln) $ctx)
       ;; Terminate by pruning the branch
       (empty)
       ;; Continue by querying the kb
       (match &kb (: $prf $ccln)
              ;; Post-application termination conditional
              (if ($tmnpred (: $prf $ccln) $ctx)
                  ;; Terminate by pruning the branch
                  (empty)
                  ;; Continue by returning the queried result
                  (: $prf $ccln)))))

;; Recursive step.  Recursion only happens if the termination
;; condition is false.  Otherwise, the branch is pruned.
(= (bc $absupd $argupd $tmnpred $ctx (: ($prfabs $prfarg) $ccln))
   ;; Pre-application termination conditional
   (if ($tmnpred (: ($prfabs $prfarg) $ccln) $ctx)
       ;; Terminate by pruning the branch
       (empty)
       ;; Continue by recursing
       (let* (;; Recurse on proof abstraction
              ((: $prfabs (-> $prms $ccln))
               (bc ;; Context updaters and termination predicate
                   $absupd $argupd $tmnpred
                   ;; Updated context for proof abstraction
                   ($absupd (: ($prfabs $prfarg) $ccln) $ctx)
                   ;; Proof abstraction query
                   (: $prfabs (-> $prms $ccln))))
              ;; Recurse on proof argument
              ((: $prfarg $prms)
               (bc ;; Context updaters and termination predicate
                   $absupd $argupd $tmnpred
                   ;; Updated context for proof argument
                   ($argupd (: ($prfabs $prfarg) $ccln) $ctx)
                   ;; Proof argument query
                   (: $prfarg $prms))))
         ;; Post-application termination conditional
         (if ($tmnpred (: ($prfabs $prfarg) $ccln) $ctx)
             ;; Terminate by pruning the branch
             (empty)
             ;; Continue by returning result
             (: ($prfabs $prfarg) $ccln)))))

;;;;;;;;;;;;;;;;;;;;;;
;; Common functions ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Return True iff $lhs unifies with $rhs
(: ≐ (-> $a $a Bool))
(= (≐ $lhs $rhs) (case $rhs (($lhs True) ($_ False))))

;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define <=
(: <= (-> $a $a Bool))
(= (<= $x $y) (or (< $x $y) (== $x $y)))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;; NEXT
