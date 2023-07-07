;; Implement a unifier.  Like with `let` the left term must be an
;; Atom, so if it is function it will not be evaluated.  The
;; implementation however uses `case`, not `let`, that way it filters
;; out terms which haves not been fully rewritten.
(: unify (-> Atom $a $a $a))
(= (unify $lterm $rterm $rewrite) (case $rterm (($lterm $rewrite))))

;; Like unify but takes a tuple of pairs of terms to unify, and a
;; rewrite term.
(: unify* (-> Atom $a $a))
;; Base case
(= (unify* () $rewrite) $rewrite)
;; Recursive case
(= (unify* $pairs $rewrite)
   (case (car-atom $pairs)
     ((($lterm $rterm)
       (unify $lterm $rterm (unify* (cdr-atom $pairs) $rewrite))))))
