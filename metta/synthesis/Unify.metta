;; Implement a unifier.  Like with `let` the left term must be an
;; Atom, so if it is function it will not be evaluated.  The
;; implementation however uses `case`, not `let`, that way it filters
;; out terms which haves not been fully rewritten.
(: unify (-> Atom $a $a $a))
(= (unify $lterm $rterm $rewrite)
   (case $rterm (($lterm $rewrite))))

;; Like unify but takes a tuple of pairs of terms to unify, and a
;; rewrite term.
(: unify* (-> Atom $a $a))
(= (unify* $pairs $rewrite)
   (case $pairs
     (;; Base case
      (() $rewrite)
      ;; Recursive case
      ($pairs (let* (($head (car-atom $pairs))
                     ($tail (cdr-atom $pairs)))
                (case $head             ; By using a case we guaranty
                                        ; that ill-formed inputs (non
                                        ; tuple of pairs) will be
                                        ; discarded
                  ((($lterm $rterm)
                    (unify $lterm $rterm
                           (unify* $tail $rewrite))))))))))
