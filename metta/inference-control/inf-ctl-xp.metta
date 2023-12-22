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

;;;;;;;;;;;;;
;; Context ;;
;;;;;;;;;;;;;

;; Queries and results are contextualized.  For now we rely on a
;; concrete implementation instead of an interface.

;; Takes a context type, a value type, and create a type representing
;; a contextualized value.
(: CtxVal (-> $ctx $a Type))

;; Ctx constructor, takes a context, a value, and construct a
;; contextualized value.
(: MkCtxVal (-> $ctx $a (CtxVal $ctx $a)))

;; Access functions

;; Access the context of a contextualized value
(: CtxVal.context (-> (CtxVal $ctx $a) $ctx))
(= (CtxVal.context (MkCtxVal $c $x) $c))

;; Access the value of the contextualized value
(: CtxVal.value (-> (CtxVal $ctx $a) $a))
(= (CtxVal.value (MkCtx $c $x) $c))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward DTL Curried ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Backward Chainer.  The depth is replaced by:
;;
;; * Contextualized input and output.
;; * Context updater and aggregator functions.
;; * Termination predicate.  Terminating amounts to pruning here.
;;
;; The context updater is to update the context from the caller before
;; the recursive calls.  The context aggregator is to aggregate the
;; contexts resulting from children calls, as well the updated
;; context.
(: bc (-> (CtxVal $ctx $a)         ; Contextualized query
          (-> $ctx $ctx)           ; Context updater
          (-> $ctx $ctx $ctx $ctx) ; Context aggregator
          (-> $ctx Bool)           ; Termination predicate
          (CtxVal $ctx $a)))       ; Contextualized result

;; Base case.  Terminates no matter what, either by pruning the branch
;; or by querying the kb.  Thanks to non-determinism, terminating the
;; branch does not terminate alternative branches.
(= (bc (MkCtxVal $ctx (: $prf $ccln)) $ctx_upd $ctx_agg $tmn_pred)
   (if ($tmn_pred $ctx)
       ;; Terminate by pruning the branch
       (empty)
       ;; Terminate by querying the kb
       (MkCtxVal ($ctx_upd $ctx) (match &kb (: $prf $ccln) (: $prf $ccln)))))

;; Recursive step.  Recursion only happens if termination is
;; unsatisfied.  If termination is satisfied, the branch is pruned.
(= (bc (MkCtxVal $ctx (: ($prfabs $prfarg) $ccln)) $ctx_upd $ctx_agg $tmn_pred)
   (if ($tmn_pred $ctx)
       ;; Terminate by pruning the branch
       (empty)
       ;; Continue
       (let* (;; Update context to be passed to the recursive calls
              ($utx ($ctx_upd $ctx))
              ;; Recurse on proof abstraction
              ((MkCtxVal $ctxabs (: $prfabs (-> $prms $ccln)))
               (bc (MkCtxVal $utx (: $prfabs (-> $prms $ccln))) $ctx_upd $ctx_agg $tmn_pred))
              ;; Recurse on proof argument
              ((MkCtxVal $ctxarg (: $prfarg $prms))
               (bc (MkCtxVal $utx (: $prfarg $prms)) $ctx_upd $ctx_agg $tmn_pred))
              ;; Merge all contexts so far to form a new context
              ($ntx ($ctx_agg $utx $ctxabs $ctxarg)))
         ;; Build contextualized result
         (MkCtxVal $ntx (: ($prfabs $prfarg) $ccln)))))

;;;;;;;;;;
;; Test ;;
;;;;;;;;;;

;; The context is a natural number

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

;; Define context updater, which just decrease a natural
(: dec (-> Nat Nat))
(= (dec Z) Z)
(= (dec (S $k)) $k)

;; Define context aggregator, which just pass the updated context
(: fst (-> Nat Nat Nat Nat))
(= (fst $x $y $z) $x)

;; Define termination predicate, which just terminates at zero
(: is_zero (-> Nat Bool))
(= (is_zero Z) True)
(= (is_zero (S $k)) False)

;; Prove nothing, depth of 0 means everything is pruned.
!(assertEqualToResult
  (bc (MkCtxVal (fromNumber 0) (: $prf A)) dec fst is_zero)
  ())

;; Prove A
!(bc (MkCtxVal (fromNumber 1) (: $prf A)) dec fst is_zero)

;; Prove (-> $pq (-> $p B))
!(bc (MkCtxVal (fromNumber 1) (: $prfabs (-> $pq (-> $p B)))) dec fst is_zero)

;; Prove (-> A B)
!(bc (MkCtxVal (fromNumber 2) (: ($prfabs $prfarg) (-> $p B))) dec fst is_zero)

;; Prove B
!(bc (MkCtxVal (fromNumber 3) (: $prf B)) dec fst is_zero)

;; Prove C
!(bc (MkCtxVal (fromNumber 4) (: $prf C)) dec fst is_zero)

;; Prove C (via deduction as well)
!(bc (MkCtxVal (fromNumber 5) (: $prf C)) dec fst is_zero)
