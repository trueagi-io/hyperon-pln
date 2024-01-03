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

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward DTL Curried ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Backward Chainer.  The arguments of the backward chainer are:
;;
;; * Context abstraction updater.  Update the context before
;;   recursively calling the backward chainer on the proof abstraction.
;;
;; * Context argument updater.  Update the context before recursively
;;   calling the backward chainer on the proof argument.
;;
;; * Termination predicate.  Condition of a conditional wrapping the
;;   base case and recursive step functions.  Terminating amounts to
;;   pruning the reduction (as in evaluation) branch.
;;
;; * Query: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables that may be
;;   filled by the backward chainer.
;;
;; * Context: a context to be updated and passed to the recursive
;;   calls of the backward chainer.
;;
;; The context updater is to update the context from the caller before
;; the recursive calls.  The context aggregator is to aggregate the
;; contexts resulting from children calls, as well the updated
;; context.
;;
;; NEXT: maybe the context updaters and the termination predicate
;; should take the query as well.  It could also take a contextualized
;; query, but it's probably not a good idea to return a contextualized
;; query because we don't want the user to be able to modify the
;; query, as it could lead to breaking the backward chainer, as
;; opposed to just pruning its search.
(: bc (-> (-> $ct $ct)      ; Context abstraction updater
          (-> $ct $ct)      ; Context argument updater
          (-> $ct Bool)     ; Termination predicate
          $ct               ; Context
          $a                ; Query
          $a))              ; Query result

;; Base case.  Terminates no matter what, either by pruning the branch
;; or by querying the kb.  Thanks to non-determinism, terminating the
;; branch does not terminate alternative branches.
(= (bc $absupd $argupd $tmnpred $ctx (: $prf $ccln))
   (if ($tmnpred $ctx)
       ;; Terminate by pruning the branch
       (empty)
       ;; Terminate by querying the kb
       (match &kb (: $prf $ccln) (: $prf $ccln))))

;; Recursive step.  Recursion only happens if the termination
;; condition is false.  Otherwise, the branch is pruned.
(= (bc $absupd $argupd $tmnpred $ctx (: ($prfabs $prfarg) $ccln))
   (if ($tmnpred $ctx)
       ;; Terminate by pruning the branch
       (empty)
       ;; Continue
       (let* (;; Recurse on proof abstraction
              ((: $prfabs (-> $prms $ccln))
               (bc ;; Context updaters and termination predicate
                   $absupd $argupd $tmnpred
                   ;; Updated context for proof abstraction
                   ($absupd $ctx)
                   ;; Proof abstraction query
                   (: $prfabs (-> $prms $ccln))))
              ;; Recurse on proof argument
              ((: $prfarg $prms)
               (bc ;; Context updaters and termination predicate
                   $absupd $argupd $tmnpred
                   ;; Updated context for proof argument
                   ($argupd $ctx)
                   ;; Proof argument query
                   (: $prfarg $prms))))
         ;; Construct result
         (: ($prfabs $prfarg) $ccln))))

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

;; Define termination predicate, called inside a conditional wrapping
;; the bc.  Terminates at 0.
(: is-zero (-> Nat Bool))
(= (is-zero Z) True)
(= (is-zero (S $k)) False)

;; Prove nothing, depth of 0 means everything is pruned.
!(assertEqualToResult
  (bc dec dec is-zero (fromNumber 0) (: $prf A))
  ())

;; Prove A
!(bc dec dec is-zero (fromNumber 1) (: $prf A))

;; Prove (-> (→ $p B) (-> $p B))
!(bc dec dec is-zero (fromNumber 1) (: $prfabs (-> $pq (-> $p B))))

;; Prove (-> A B)
!(bc dec dec is-zero (fromNumber 2) (: ($prfabs $prfarg) (-> $p B)))

;; Prove B
!(bc dec dec is-zero (fromNumber 3) (: $prf B))

;; Prove C
!(bc dec dec is-zero (fromNumber 4) (: $prf C))

;; Prove C (via deduction as well)
!(bc dec dec is-zero (fromNumber 5) (: $prf C))

;; Prove (→ A C)
!(bc dec dec is-zero (fromNumber 4) (: $prf (→ A C)))

;; Prove (-> A C)
!(bc dec dec is-zero (fromNumber 4) (: $prf (-> A C)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Context is depth, initial query and current query ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; From the previous runs we obverse 3 things
;; ;;
;; ;; 1. When the queried theorem is (→ x y) then deduction is useful.
;; ;; 2. When the queried theorem is otherwise then modus ponens is enough.
;; ;; 3. Composition . is never necessary even for theorem like (-> x y).
;; ;;
;; ;; We thus define context and control functions reflecting these observations

;; ;; Context type and ctor
;; (: Ctx Type)
;; (: MkCtx (-> Nat                    ; Maximum depth
;;              $iqt                   ; Initial query
;;              $cqt                   ; Current query
;;              Ctx))

;; ;; Define context abstraction updater.  Decrement the depth, leave the
;; ;; initial query unchangedand current queries unchanged.
;; (: abs-updater (-> Ctx Ctx))
;; (= (abs-updater (MkCtx $depth $query (: ($prfabs $prfarg) $ccln)))
;;    (MkCtx (dec $depth) $query (: $prfabs (-> $prms $ccln)))

;; (: $prfabs (-> $prms $ccln))

;; ;; Define termination predicate.  Terminates at 0 and make sure to
;; ;; respect the 3 observations above.  NEXT.
;; (: terminate (-> Ctx Bool))
;; (= (terminate (MkCtx $depth $iniqry $curqry))
;;    (or (is-zero $depth)
       
;;        ))
