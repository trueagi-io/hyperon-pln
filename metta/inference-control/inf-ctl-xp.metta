;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Knowledge and Rule Base ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Similar to the traditional backward chaining DTL but rules are
;; curried.  This allows to partially apply rule which is useful for
;; inferring proof abstractions.

;; Knowledge and rule base
!(bind! &kb (new-space))

;; Knowledge base
!(add-atom &kb (: ab (→ A B)))
!(add-atom &kb (: bc (→ B C)))
!(add-atom &kb (: a A))

;; Rule base
!(add-atom &kb (: ModusPonens (-> (→ $p $q)  ; Premise 1
                                  (-> $p     ; Premise 2
                                      $q)))) ; Conclusion
!(add-atom &kb (: Deduction (-> (→ $q $r)         ; Premise 1
                                (-> (→ $p $q)     ; Premise 2
                                    (→ $p $r))))) ; Conclusion
!(add-atom &kb (: . (-> (-> $q $r)         ; Premise 1
                        (-> (-> $p $q)     ; Premise 2
                            (-> $p $r))))) ; Conclusion

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
;;   future we may want to separate them in two.
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

;;;;;;;;;;;
;; Tests ;;
;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;
;; Context is depth ;;
;;;;;;;;;;;;;;;;;;;;;;

;; The context is the maximum depth, thus reproduces the experiments
;; done so far.  Note that a depth of 1, not 0, allows to query the
;; KB.

;; Define context updater, same for both for proof abstraction and
;; argument.  Decrement the depth.
(: dec (-> Nat Nat))
(= (dec Z) Z)
(= (dec (S $k)) $k)
(: depth-updater (-> $a Nat Nat))
(= (depth-updater $query $depth) (dec $depth))

;; Define termination predicate, called inside a conditional wrapping
;; the bc.  Terminates at 0.
(: is-zero (-> Nat Bool))
(= (is-zero Z) True)
(= (is-zero (S $k)) False)
(: depth-termination (-> $a Nat Bool))
(= (depth-termination $query $depth) (is-zero $depth))

;; Prove nothing, depth of 0 means everything is pruned.
!(assertEqualToResult
  (bc depth-updater depth-updater depth-termination ; Updaters and termination predicate
      (fromNumber 0)                                ; Context
      (: $prf A))                                   ; Query
  ())

;; Prove A
!(assertEqual
  (bc depth-updater depth-updater depth-termination
      (fromNumber 2)
      (: $prf A))
  (: a A))

;; Prove (-> (→ $p B) (-> $p B))
!(assertEqual
  (bc depth-updater depth-updater depth-termination
      (fromNumber 2)
      (: $prfabs (-> $pq (-> $p B))))
  (: ModusPonens (-> (→ $p B) (-> $p B))))

;; Prove (-> A B)
!(assertEqual
  (bc depth-updater depth-updater depth-termination
      (fromNumber 2)
      (: ($prfabs $prfarg) (-> $p B)))
  (: (ModusPonens ab) (-> A B)))

;; Prove B
!(assertEqual
  (bc depth-updater depth-updater depth-termination
      (fromNumber 3)
      (: $prf B))
  (: ((ModusPonens ab) a) B))

;; Prove C
!(assertEqual
  (bc depth-updater depth-updater depth-termination
      (fromNumber 4)
      (: $prf C))
  (: ((ModusPonens bc) ((ModusPonens ab) a)) C))

;; Prove C (via deduction as well)
!(assertEqualToResult
  (bc depth-updater depth-updater depth-termination
      (fromNumber 5)
      (: $prf C))
  ((: ((((. ModusPonens) (Deduction bc)) ab) a) C)
   (: (((. (ModusPonens bc)) (ModusPonens ab)) a) C)
   (: ((ModusPonens ((Deduction bc) ab)) a) C)
   (: ((ModusPonens bc) ((ModusPonens ab) a)) C)))

;; Prove (→ A C)
!(assertEqual
  (bc depth-updater depth-updater depth-termination
      (fromNumber 4)
      (: $prf (→ A C)))
  (: ((Deduction bc) ab) (→ A C)))

;; Prove (-> A C)
!(assertEqualToResult
  (bc depth-updater depth-updater depth-termination
      (fromNumber 4)
      (: $prf (-> A C)))
  ((: (((. ModusPonens) (Deduction bc)) ab) (-> A C))
   (: ((. (ModusPonens bc)) (ModusPonens ab)) (-> A C))
   (: (ModusPonens ((Deduction bc) ab)) (-> A C))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Context is depth and initial query ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; From the previous runs we make the following observations:
;;
;; 1. When the queried theorem is (→ x y) then modus ponens is useless.
;;
;; 2. When the queried theorem is otherwise then deduction is useless.
;;
;; 3. Composition . is useless.
;;
;; Then we define context and control functions reflecting these
;; observations.

;; Context type and ctor
(: QD Type)
(: MkDQ (-> $a                     ; Initial query
            Nat                    ; Maximum depth
            QD))

;; Define context updater, same for both proof abstraction and proof
;; argument.  Decrement the depth, leave the initial query unchanged.
(: qd-updater (-> $a QD QD))
(= (qd-updater $query (MkQD $init-query $depth))
   (MkQD $init-query (dec $depth)))

;; Define termination predicate.  Terminate at depth 0, and respect
;; the 3 observations above.
(: qd-termination (-> $a QD Bool))
(= (qd-termination (: $prf $thm) (MkQD (: $init-prf $init-thm) $depth))
   (or ;; Terminate at depth 0
       (is-zero $depth)
       ;; [3th observation] If the current proof query is . then
       ;; terminate.
       (or (== $prf .)
           ;; [1st observation] If initial queried theorem is (→ x y)
           ;; and current proof query is not Deduction (thus is
           ;; ModusPonens, as it is the only alternative at this
           ;; point), then terminate.
           (if (== $init-thm (→ $x $y))
               (== $prf ModusPonens)
               ;; [2nd observation] Otherwise, if the current proof
               ;; query is not ModusPonens (thus Deduction, as it is
               ;; the only alternative at this point), then terminate.
               (== $prf Deduction)))))

;; Prove nothing, depth of 0 means everything is pruned.
!(assertEqualToResult
  (bc qd-updater qd-updater qd-termination ; Updaters and termination predicate
      (MkQD (: $prf A) (fromNumber 0))     ; Context
      (: $prf A))                          ; Query
  ())

;; Prove A
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: $prf A) (fromNumber 2))
      (: $prf A))
  (: a A))

;; Prove (-> (→ $p B) (-> $p B))
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: $prfabs (-> $pq (-> $p B))) (fromNumber 2))
      (: $prfabs (-> $pq (-> $p B))))
  (: ModusPonens (-> (→ $p B) (-> $p B))))

;; Prove (-> A B)
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: ($prfabs $prfarg) (-> $p B)) (fromNumber 2))
      (: ($prfabs $prfarg) (-> $p B)))
  (: (ModusPonens ab) (-> A B)))

;; Prove B
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: $prf B) (fromNumber 3))
      (: $prf B))
  (: ((ModusPonens ab) a) B))

;; Prove C
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: $prf C) (fromNumber 4))
      (: $prf C))
  (: ((ModusPonens bc) ((ModusPonens ab) a)) C))

;; Prove C (deduction is discarded via inference control)
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: $prf C) (fromNumber 5))
      (: $prf C))
  (: ((ModusPonens bc) ((ModusPonens ab) a)) C))

;; Prove (→ A C)
;; NEXT
!(assertEqual
  (bc qd-updater qd-updater qd-termination
      (MkQD (: $prf (→ A C)) (fromNumber 4))
      (: $prf (→ A C)))
  (: ((Deduction bc) ab) (→ A C)))

;; ;; Prove (-> A C).  Inference control prevents from finding a proof
;; ;; because any of the proofs involve using Deduction, or ., which are
;; ;; both forbidden for that query.
;; !(assertEqualToResult
;;   (bc qd-updater qd-updater qd-termination
;;       (MkQD (: $prf (-> A C)) (fromNumber 4))
;;       (: $prf (-> A C)))
;;   ())
