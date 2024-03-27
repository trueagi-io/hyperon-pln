# Inference Control Experiments

This folder contains a number of experiments on backward chaining
inference control.

Each experiment is realized as a variation of the curried backward
chainer defined under the `metta/curried-chaining` folder.  All
variations follow the same basic idea, which is to place termination
or continuation conditionals at the start of each non-deterministic
branch.  Thus the branch can only continue if it is evaluated to do
so.

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
  termination, then it terminates, otherwise continues.  That
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

### Curried Backward Chainer

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

The curried backward chainer works as follows:

1. Base case: the proof of a conclusion, expressed as `(: $prf $ccln)`
   is already present in the knowledge base.  A mere `match` query may
   suffice to retrieve such a proof and conclusion.

2. Recursive step: if no such proof and conclusion exist in the
   knowledge base then the problem is dividing into two sub-problems:

   2.1. finding a proof abstraction, `$prfabs`, of a unary rule
        leading a premise, `$prms`, to the target conclusion, `$ccln`.

   2.2. finding a proof argument, `$prfarg`, of the premise defined
        above.

Note that the curried backward chainer is given a maximum depth and
the recursive step is only allowed to be called when such maximum
depth is greater than zero.  This is a crude way to avoid infinite
recursion and can be improved by introducing finer inference control
as discussed further below.

Note also that for such backward chainer to operate, all rules must be
unary, and since MeTTa is not curried by default, n-ary rules must be
explicitely curried, such as

```
(: Trans (-> (=== $x $y) (-> (=== $y $z) (=== $x $z))))
```

instead of

```
(: Trans (-> (=== $x $y) (=== $y $z) (=== $x $z)))
```

This can however be worked around either by preprocessing rules or
adding a currying inferrence rule that does that on the fly.

Finally, note that all unifications that are taking place during
backward chaining (via `match` or `let*`) may be further constrained
by providing `$prf` and `$ccln` as partially or wholly grounded
expressions instead of variables.  Depending on how constrained they
are, the backward chainer may behave differently, such as

1. regular backward chaining, if `$ccln` is partially grounded and
   `$prf` is a variable;

2. proof checking, if both `$prf` and `$ccln` are fully grounded;

3. even forward chaining, if `$prf` is partially grounded and `$ccln`
   is a variable;

4. any combination thereof.

More variations of such backward chainer exist, such as one producing
fully annotated proofs (see [proof-tree](../proof-tree)), or one more
amenable to build constructive proofs (see [hol](../hol)).  However,
we choose the particular variation presented above to experiment with
inference control because it is the simplest one.

### Controlled Backward Chainer

We identify 3 places where non-deterministism occurs in the curried
backward chainer:

1. The entry of the base case `(bc $kb (: $prf $ccln) $_)` which
   non-deterministically competes with the entry of the recursive step
   `(bc (: ($prfabs $prfarg) $ccln) (S $k))` when the depth is above
   zero.

2. The entry of the recursive step for the reason explained above.

3. The match query `(match &kb (: $prf $ccln) (: $prf $ccln))` in the
   base case, which, as per MeTTa semantics, returns the results as a
   non-deterministic superposition.

The idea is to wrap these 3 places with conditionals to prune branches
created at run-time by the backward chainer.  In addition, a context
used as input of the predicates inside these conditionals, is provided
as well as context updater functions.  In order to hold the predicates
and updater functions we defined the following control structure

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

3. The continuation predicate in charge of deciding whether to enter
   the base case depending on the current query and context.

4. The continuation predicate in charge of deciding whether to enter
   the recursive step depending the current query and context.

5. The continuation predicate in charge of deciding whether to
   continue the base case *after* getting the results of the `match`
   call.  This one is important because at the time of its calling,
   the `match` call has already unified the query with the knowledge
   base and thus much more information is available to make a decision
   about the continuation.

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

1. A knowledge base containing the axioms and rules of the logic.

2. A control structure holding the continuation predicates and updater
   functions for inference control.

3. A user defined context.

4. A query of the form `(: PROOF THEOREM)`.

You may notice that the maximum depth argument has been removed.  It
is no longer required since it can be emulated with the proper control
structure and context, as described further below.

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
the results of the `match` call, with continuation predicate `$mcont`.
Note the use of `(empty)` which has the effect of pruning the branch.

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
`argupd` before the recursive calls.

### Maximum Depth Controlled Backward Chainer

Once the controlled backward chainer is defined we still need to
provide continuation predicates and context updaters.  Our first test
is to use the maximum depth as context, thus the control structure is
defined as follows

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
control structure is to reproduce the original backward chainer code
without inference control.

The corresponding code can be found after the boxed comment

```
;;;;;;;;;;;;;;;;;;;;;;
;; Context is depth ;;
;;;;;;;;;;;;;;;;;;;;;;
```

in [inf-ctl-month-bc-cont-xp.metta](inf-ctl-month-bc-cont-xp.metta).

### Reasoning-base Controlled Backward Chainer

NEXT

The corresponding code can be found after the boxed comment

```
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Context is depth and target theorem ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```

in [inf-ctl-month-bc-cont-xp.metta](inf-ctl-month-bc-cont-xp.metta).

## Conclusion

This work is only scratching the surface.  Below are a few suggestions
for improvements and futher exploration.

1. The post-filtering conditional in the base case should be replaced
   by a proper attentional focus mechanism.  This would save
   computation spent by over-retreaving results which are then lost by
   filtering.  Instead the `match` call should be able to restrict its
   attention to reflect the predicate of that conditional.

2. The code of the controlled backward chainer could be automatically
   generated from the vanilla backward chainer code, possibly applying
   some optimizations during the rewrite as to pay up-front some of
   the cost instead of at run-time.  This could be applied to any
   non-deterministic MeTTa program as well and relates to the broader
   notion of program specialization, as per Alexey Potapov et al's
   work in other contexts.

3. In the current design, the control mechanism is centralized and
   systematic, which incurs a considerable overhead.  Each and every
   step needs to go through the approval of the "global police" (in
   Greg Meredith's words), also making such control not amenable to
   concurrent processing.

4. As previously discussed in various calls, the inference control
   mechanics need not to exist only as MeTTa code.  It could exist
   below MeTTa, as Minimal MeTTa code.  Or even below Minimal MeTTa,
   as foreign function code.  In fact there may be ways for these
   multiple levels to co-exist as particular implementations of the
   same specification, maybe expressed with the help of type
   primitives over abstract program traces, as suggested by Ben
   Goertzel.

5. The idea of using the backward chainer to control the backward
   chainer can be pushed much further.  Inference control rules could
   be discovered via mining, evolutionary programming, reasoning or
   combinations thereof.

6. Inference control may also exist at a higher level, going beyond
   directly pruning or selecting the most likely branch.  For instance
   by expressing the process of searching proofs in more abstract and
   compositional ways.  Higher level inference control rules could for
   instance express how to decompose certain problems or how to apply
   certain tatics.

7. In the experiment of using the backward chainer to control the
   backward chainer, the knowledge base of the controlled backward
   chainer is different than that of the knowledge base of the
   controlling backward chainer.  In future versions such knowledge
   bases could be the same.  This is certainly feasible with an
   efficient attentional focus mechanism.  Meaning that any knowledge
   gained about solving problems in general would potentially be
   transferable to the problems of controlling the backward chainer,
   enabling the possibility of a virtuous feedback loop.  Thus, as the
   backward chainer would get smarter at solving problems in the outer
   world, it would also get smarter at solving problems in the inner
   world.
