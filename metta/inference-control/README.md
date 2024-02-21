# Inference Control Experiments

This folder contains a number of experiments on backward chaining
inference control.

Each experiment is realized as a variation of the curried backward
chainer defined under the `metta/curried-chaining` folder.  All
variations follow the same basic idea, which is to place termination
or continuation conditionals at the start of each branch (everytime
reduction is non-deterministically forked).  Thus the branch can only
continue if it is evaluated to do so.

## Overview

A short overview of each experiment is provided below, followed by a
more detailed description of our last most successful experiment.

- `inf-ctl-xp.metta` was the first attempt.  All places in the
  backward chainer code that create of a non-deterministic branch are
  wrapped around a termination conditional.  These places are the base
  case, the recursive step and the match query.  The termination
  condition is passed as a termination predicate to the backward
  chainer, alongside a context and a context updater.  Two tests are
  carried out:
  1. Reproduce the maximum depth behavior of the regular curried
     backward chainer.
  2. Provide a user programmed termination predicate to prune the
     non-deterministic evaluation and find proofs sooner.

- `inf-ctl-month-xp.metta` was the second attempt.  It is almost
  identical to `inf-ctl-xp.metta` but tested over another knowledge
  base, that of the chronological order of the months, with a shortcut
  for January, as it preceeds all other months.

- `inf-ctl-month-bc-xp.metta` was the third attempt.  It is almost
  identical to `inf-ctl-month-xp.metta` but instead of providing a
  user defined termination predicate, it provides a user defined
  theory about inference control and calls the backward chainer to
  evaluate termination.  Thus in order to terminate a backward
  chaining branch, the termination condition calls yet another
  instance of the backward chainer, if it manages to find a proof of
  termination, then it terminates, and continues otherwise.  That
  experiment failed because it is difficult in MeTTa to reason about
  terms with free variables without systematically altering them with
  unification and subtitution, which is required to reason about the
  state of a proof.  Since adding a proper quotation mechanism was
  beyond the scope of that experiment we decided to work around that
  limitation as described in the next and final experiment.

- `inf-ctl-month-bc-cont-xp.metta` was the fourth and final attempt.
  It is derived from `inf-ctl-month-bc-xp.metta` but with a number of
  differences.
  1. Termination conditionals are replaced by continuation
     conditionals.
  2. A dedicated control structure containing the continuation
     predicates and update functions is provided.
  3. Continuation predicates are different for each type of branches,
     base case, recursive step and match query.
  More information about that experiment can be found in the next
  Section.

## Description of `inf-ctl-month-bc-cont-xp.metta`

### Controlled Backward Chainer

As explained above the controlled backward chainer is an altered
version of the curried backward chainer recalled below

```
;; Curried Backward Chainer
(: bc (-> $a    ; Knowledge base
          $b    ; Query
          Nat   ; Maximum depth
          $b))  ; Query result

;; Base case
(= (bc $kb (: $prf $ccln) $_) (match &kb (: $prf $ccln) (: $prf $ccln)))

;; Recursive step
(= (bc (: ($prfabs $prfarg) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) (bc (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) (bc (: $prfarg $prms) $k)))
     (: ($prfabs $prfarg) $ccln)))
```

One may observe 3 places for non-deterministic reduction

1. The entry of the base case `(bc $kb (: $prf $ccln) $_)` which
   non-deterministically competes with the entry of the recursive step
   `(bc (: ($prfabs $prfarg) $ccln) (S $k))` when the depth is above
   zero.

2. The entry of the recursive step for the reason explained above.

3. The match query `(match &kb (: $prf $ccln) (: $prf $ccln))` inside
   the base case which, as per MeTTa semantics, returns the results as
   a non-deterministic superposition.

The idea is to wrap these 3 places with conditionals to prune branches
created at run-time by the backward chainer.  In addition, context
updater functions are provided.  In order to hold the predicates and
updater functions we defined the following control structure

```
(: Control (-> $b $c Type))
(: MkControl (-> (-> $b $c $c)      ; Abstraction context updater
                 (-> $b $c $c)      ; Argument context updater
                 (-> $b $c Bool)    ; Base case continuation predicate
                 (-> $b $c Bool)    ; Recursive step continuation predicate
                 (-> $b $c Bool)    ; Match continuation predicate
                 (Control $b $c)))  ; Control type
```

The `Control` type constructor defines a type parameterized by the
type of the query `$b` and the type of the context `$c`.

The `MkControl` data constructor defines a data structure respectively
holding:
1. The context updater applied before recursively calling the backward
   chainer on the proof abstraction.
2. The context updater applied before recursively calling the backward
   chainer on the proof argument.
3. The continuation predicate in charge of deciding whether to
   continue the base case depending on the current query and context.
4. The continuation predicate in charge of deciding whether to
   continue the recursive step depending the current query and
   context.
5. The continuation predicate in charge of deciding whether to
   continue the base case depending on the current query result and
   context.  This one is important because at the time of its calling
   the match call has unified the query with the knowledge base and
   thus much more information is available to make a decision about
   the continuation.

Given that control structure we can now present the controlled
backward chainer, starting with its type definition

```
(: bc (-> $a               ; Knowledge base
          (Control $b $c)  ; Control structure
          $c               ; Context
          $b               ; Query
          $b))             ; Query result
```

Meaning, it takes in arguments

1. The knowledge base containing the axioms and rules of the logic.
2. The control structure holding the continuation predicates and
   updater functions for inference control.
3. The user defined context
4. The query of the form `(: PROOF THEOREM)`.

You may notice that the maximum depth argument has been removed.
Indeed, it is no longer required since it can be emulated with the
proper control structure and context, as described further below.

The base case of the controlled backward chainer becomes

```
(= (bc $kb                                               ; Knowledge base
       (MkControl $absupd $argupd $bcont $rcont $mcont)  ; Control
       $ctx                                              ; Context
       (: $prf $ccln))                                   ; Query
   ;; Base case continuation conditional
   (if ($bcont (: $prf $ccln) $ctx)
       ;; Continue by querying the kb
       (match $kb (: $prf $ccln)
              ;; Match continuation conditional
              (if ($mcont (: $prf $ccln) $ctx)
                  ;; Continue by returning the queried result
                  (: $prf $ccln)
                  ;; Terminate by pruning
                  (empty)))
       ;; Terminate by pruning
       (empty)))
```

replicating the regular curried backward chainer base case but with 2
conditionals, one at the entry of the function with continuation
predicate `$bcont`, and one as a post-filtering conditional applied to
the results of the match call, with continuation predicate `$mcont`.

The recursive step of the controlled backward chainer becomes

```
(= (bc $kb                                              ; Knowledge base
       (MkControl $absupd $argupd $bcont $rcont $mcont) ; Control
       $ctx                                             ; Context
       (: ($prfabs $prfarg) $ccln))                     ; Query
   ;; Recursive step continuation conditional
   (if ($rcont (: ($prfabs $prfarg) $ccln) $ctx)
       ;; Continue by recursing
       (let* (;; Recurse on proof abstraction
              ((: $prfabs (-> $prms $ccln))
               (bc $kb                                         ; Knowledge base
                   (MkControl $absupd $argupd $bcont $rcont $mcont)   ; Control
                   ($absupd (: ($prfabs $prfarg) $ccln) $ctx) ; Updated context
                   (: $prfabs (-> $prms $ccln))))     ; Proof abstraction query
              ;; Recurse on proof argument
              ((: $prfarg $prms)
               (bc $kb                                         ; Knowledge base
                   (MkControl $absupd $argupd $bcont $rcont $mcont)   ; Control
                   ($argupd (: ($prfabs $prfarg) $ccln) $ctx) ; Updated context
                   (: $prfarg $prms))))                  ; Proof argument query
         ;; Output result
         (: ($prfabs $prfarg) $ccln))
       ;; Terminate by pruning
       (empty)))
```

replicating the regular curried backward chainer recursive step but
with a conditional at the entry of the function with the continuation
predicate `$rcont`.  Another addition is the application of the
abstraction and argument context updaters, via calling `$absupd` and
`argupd` respectively before the recursive calls.

### Maximum Depth Controlled Backward Chainer

Once the controlled backward chainer defined we still need to provide
continuation predicates and context updaters.  As in the previous
experiments out first tests are done by using the maximum depth as
context, thus the control structure is defined as follows

```
!(bind! &md-ctl (MkControl depth-updater    ; Abstraction context updater
                           depth-updater    ; Argument context updater
                           top-continuor    ; Base case continuor
                           gtz-continuor    ; Recursive step continuor
                           top-continuor))  ; Match continuor
```

where `depth-updater` is defined as follows

```
(: depth-updater (-> $a Nat Nat))
(= (depth-updater $query $depth) (dec $depth))
```

meaning it takes a query, a context which is a natural number, and
returns an updated context which is the natural number decreased by 1.

The `top-continuor` is merely a constant predicate that is always
`True`

```
(: top-continuor (-> $a Nat Bool))
(= (top-continuor $query $depth) True)
```

meaning that base case and match calls are always allowed to continue.

The maximum depth is then controlled by the continuation predicate
controlling the recursive step.

```
(: gtz-continuor (-> $a Nat Bool))
(= (gtz-continuor $query $depth)
   (not (is-zero $depth)))
```

which is only true if the depth is greater than zero.

The effect of running the controlled backward chainer with that
control structure is that it reproduces the original backward chainer
code without inference control.

### Reasoning-base Controlled Backward Chainer

NEXT

## Conclusion

- Post-filtering should be inside match.
