;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backward and forward curried chainers generating fully annotated    ;;
;; proof tree.                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;
;; Nat ;;
;;;;;;;;;

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

;; Return the ceiling of a non negative number.  If the number is
;; negative it returns 1.
(: ceil (-> Number Number))
(= (ceil $n) (fromNat (fromNumber $n)))

;;;;;;;;;;;;;;;;;;;;
;; Knowledge base ;;
;;;;;;;;;;;;;;;;;;;;

!(bind! &kb (new-space))

!(add-atom &kb (: a A))
!(add-atom &kb (: ab (→ A B)))
!(add-atom &kb (: bc (→ B C)))
!(add-atom &kb (: ModusPonens
                (-> (→ $p $q)
                    (-> $p
                        $q))))

;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Curried Backward Chainer with fully annotated proofs.  The
;; arguments of the backward chainer are:
;;
;; * Knowledge base: pointer to a space containing axioms and rules in
;;   the format (: <NAME> <RULE>).  Note that rules are explicitely
;;   curried, meaning that a rule with two premises is represented by
;;
;;   (: <NAME> (-> <PREMISE1> (-> <PREMISE2> <CONCLUSION>)))
;;
;; * Query: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables that may be
;;   filled by the backward chainer.
;;
;; * Maximum depth: maximum depth of the generated proof tree.
;;
;; A result is the query with its variables grounded, fully or
;; partially.  If multiple results are possible, they are returned as
;; a superposition.
(: bc (-> $a                            ; Knowledge base space
          $b                            ; Query
          Nat                           ; Maximum depth
          $b))                          ; Result
;; Base case
(= (bc $kb (: $prf $ccln) $_) (match $kb (: $prf $ccln) (: $prf $ccln)))
;; Recursive step
(= (bc $kb (: ($prfabs (: $prfarg $prms)) $ccln) (S $k))
   (let* (((: $prfabs (-> $prms $ccln)) (bc $kb (: $prfabs (-> $prms $ccln)) $k))
          ((: $prfarg $prms) (bc $kb (: $prfarg $prms) $k)))
     (: ($prfabs (: $prfarg $prms)) $ccln)))

;; Test curried backward chainer
!(assertEqual
  (bc &kb (: $prf A) (fromNumber 0))
  (: a A))
!(assertEqual
  (bc &kb (: $prf B) (fromNumber 2))
  (: ((ModusPonens (: ab (→ A B))) (: a A)) B))
!(assertEqual
  (bc &kb (: $prf C) (fromNumber 3))
  (: ((ModusPonens (: bc (→ B C))) (: ((ModusPonens (: ab (→ A B))) (: a A)) B)) C))

;;;;;;;;;;;;;;;;;;;;;
;; Forward chainer ;;
;;;;;;;;;;;;;;;;;;;;;

;; Curried Forward Chainer with fully annotated proofs.  The arguments
;; of the forward chainer are:
;;
;; * Knowledge base: pointer to a space containing axioms and rules in
;;   the format (: <NAME> <RULE>).  Note that rules are explicitely
;;   curried, meaning that a rule with two premises is represented by
;;
;;   (: <NAME> (-> <PREMISE1> (-> <PREMISE2> <CONCLUSION>)))
;;
;; * Source: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables.  Beware that
;;   the source is assumed to be true.  That is especially important
;;   to consider when introducing free variables, because these free
;;   variables will be treated as if they are univerally quantified.
;;
;; * Maximum depth: maximum depth of the generated proof tree.
;;
;; A result is a conclusion that can be reached from the source.  If
;; multiple results are possible, they are returned as a
;; superposition.
(: fc (-> $a                            ; Knowledge base space
          $b                            ; Source
          Nat                           ; Maximum depth
          $b))                          ; Conclusion
;; Base case
(= (fc $kb (: $prf $prms) $_) (: $prf $prms))
;; Recursive step
(= (fc $kb (: $prfarg $prms) (S $k))
   (let (: $prfabs (-> $prms $ccln)) (bc $kb (: $prfabs (-> $prms $ccln)) $k)
        (fc $kb (: ($prfabs (: $prfarg $prms)) $ccln) $k)))
(= (fc $kb (: $prfabs (-> $prms $ccln)) (S $k))
   (let (: $prfarg $prms) (bc $kb (: $prfarg $prms) $k)
        (fc $kb (: ($prfabs (: $prfarg $prms)) $ccln) $k)))

;; Test curried forward chainer
!(assertEqualToResult
  (fc &kb (: ab (→ A B)) (fromNumber 1))
  ((: ab (→ A B))
   (: (ModusPonens (: ab (→ A B))) (-> A B))))
!(assertEqualToResult
  (fc &kb (: ab (→ A B)) (fromNumber 2))
  ((: ab (→ A B))
   (: (ModusPonens (: ab (→ A B))) (-> A B))
   (: ((ModusPonens (: ab (→ A B))) (: a A)) B)))
!(assertEqualToResult
  (fc &kb (: a A) (fromNumber 3))
  ((: a A)
   (: ((ModusPonens (: ab (→ A B))) (: a A)) B)
   (: ((ModusPonens (: bc (→ B C))) (: ((ModusPonens (: ab (→ A B))) (: a A)) B)) C)))

;;;;;;;;;;;;;;;
;; Flattener ;;
;;;;;;;;;;;;;;;

;; Return True iff $term is an expression
(: is-expression (-> Atom Bool))
(= (is-expression $term) (== (get-metatype $term) Expression))

;; Concatenate two expressions
;;
;; for instance
;;
;; (concat-atom (a b) (c d)) returns (a b c d)
(: concat-atom (-> Expression Expression Expression))
(= (concat-atom $el $er)
   (if (== $el ())
       $er
       (let* (($hd (car-atom $el))
              ($tl (cdr-atom $el))
              ($tler (concat-atom $tl $er)))
         (cons-atom $hd $tler))))

;; Test concat-atom
!(assertEqual
  (concat-atom (a b) ())
  (a b))
!(assertEqual
  (concat-atom (a b) (c d))
  (a b c d))

;; Like flatten but treat the given tuple as a list of expressions
;; instead of an expression
(: flatten-map (-> Expression Expression))
(= (flatten-map $tuple)
   (if (== $tuple ())
       ()
       (let* (($head (car-atom $tuple))
              ($tail (cdr-atom $tuple))
              ($flat-head (flatten $head))
              ($flat-tail (flatten-map $tail)))
         (cons-atom $flat-head $flat-tail))))

;; Flatten a curried expression.  For instance
;;
;; (flatten ((f a) b)) returns (f a b)
;;
;; Note that it only flattens left-associative application.  Therefore
;; it will not work on the arrow type as it is right-associative.  For
;; instance
;;
;; (flatten (-> T1 (-> T2 T3))) returns (-> T1 (-> T2 T3)), not (-> T1 T2 T3)
(: flatten (-> Atom Atom))
(= (flatten $term)
   (if (is-expression $term)
       (if (== $term ())
           ()
           (let* (($head (car-atom $term))
                  ($tail (cdr-atom $term))
                  ($flat-head (flatten $head))
                  ($flat-tail (flatten-map $tail)))
             (if (is-expression $flat-head)
                 (if (== $flat-head ())
                     (cons-atom $flat-head $flat-tail)
                     (let* (($hd-hd (car-atom $flat-head))
                            ($tl-hd (cdr-atom $flat-head))
                            ($tl-hd-tl (concat-atom $tl-hd $flat-tail)))
                       (cons-atom $hd-hd $tl-hd-tl)))
                 (cons-atom $flat-head $flat-tail))))
       $term))

;; Test flatten
!(assertEqual
  (flatten a)
  a)
!(assertEqual
  (flatten $x)
  $x)
!(assertEqual
  (flatten ())
  ())
!(assertEqual
  (flatten (()))
  (()))
!(assertEqual
  (flatten (f a))
  (f a))
!(assertEqual
  (flatten ((f a)))
  (f a))
!(assertEqual
  (flatten (() a))
  (() a))
!(assertEqual
  (flatten ((f a) b))
  (f a b))
!(assertEqual
  (flatten ((f a) ()))
  (f a ()))
!(assertEqual
  (flatten ((f a b) c))
  (f a b c))
!(assertEqual
  (flatten (((f a) b) c))
  (f a b c))
!(assertEqual
  (flatten ((f a) b c))
  (f a b c))
!(assertEqual
  (flatten ((f a) (g c)))
  (f a (g c)))
!(assertEqual
  (flatten (((f a) b) (g c)))
  (f a b (g c)))
!(assertEqual
  (flatten ((f a) (g c) (h d)))
  (f a (g c) (h d)))
!(assertEqual
  (flatten (((f a) b) ((g c) d)))
  (f a b (g c d)))
!(assertEqual
  (flatten (: ((ModusPonens (: bc (→ B C)))
               (: ((ModusPonens (: ab (→ A B))) (: a A)) B)) C))
  (: (ModusPonens (: bc (→ B C)) (: (ModusPonens (: ab (→ A B)) (: a A)) B)) C))

;;;;;;;;;;;;
;; Drawer ;;
;;;;;;;;;;;;

;; Return the arity of an expression
(: arity (-> Expression Number))
(= (arity $expr)
   (if (== $expr ())
       0
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr)))
         (+ 1 (arity $tail)))))

;; Split tuple into two tuple from a given position.  For instance
;;
;; (split-tuple (a b c) 0) returns (() (a b c))
;; (split-tuple (a b c) 1) returns ((a) (b c))
;; (split-tuple (a b c) 2) returns ((a b) (c))
;;
;; If the position exceeds the arity of the tuple, then it behaves as
;; if the position was the arity.  For instance
;;
;; (split-tuple (a b c) 4) returns ((a b c) ())
;;
;; If $position is negative then it does not terminate.
(: split-tuple (-> Expression Number Expression))
(= (split-tuple $tuple $position)
   (if (== $position 0)
       (() $tuple)
       (if (== $tuple ())
           (() ())
           (let* (($head (car-atom $tuple))
                  ($tail (cdr-atom $tuple))
                  (($split-head $split-tail) (split-tuple $tail (- $position 1))))
             ((cons-atom $head $split-head) $split-tail)))))

;; Test split-tuple
!(assertEqual
  (split-tuple (a b c) 0)
  (() (a b c)))
!(assertEqual
  (split-tuple (a b c) 1)
  ((a) (b c)))
!(assertEqual
  (split-tuple (a b c) 2)
  ((a b) (c)))
!(assertEqual
  (split-tuple (a b c) 3)
  ((a b c) ()))
!(assertEqual
  (split-tuple (a b c) 4)
  ((a b c) ()))

;; Return the maximum of two number
(: max (-> Number Number Number))
(= (max $x $y) (if (< $x $y) $y $x))

;; Given a tuple of numbers, return the maximum, or 0 if empty.
(: max-element (-> Expression Number))
(= (max-element $tuple)
   (if (== $tuple ())
       0
       (let* (($head (car-atom $tuple))
              ($tail (cdr-atom $tuple))
              ($max-tl (max-element $tail)))
         (max $head $max-tl))))

;; Append a term to an expression
(: append (-> Expression Atom Expression))
(= (append $expr $term)
   (if (== $expr ())
       ($term)
       (let* (($head (car-atom $expr))
              ($tail (cdr-atom $expr))
              ($tail-term (append $tail $term)))
         (cons-atom $head $tail-term))))

;; Append a character to a string
(: append-char (-> String Char String))
(= (append-char $s $c)
   (let* (($cs (stringToChars $s))
          ($csc (append $cs $c)))
     (charsToString $csc)))

;; len-str is added to MeTTa-Python stdlib instead
;; ;; Return the length of a string
;; (: len-str (-> String Number))
;; (= (len-str $s) (let $cs (stringToChars $s) (arity $cs)))

;; Test len-str
!(assertEqual (len-str "abc") 3)

;; concat-str is added to MeTTa-Python stdlib instead
;; ;; Concatenate two strings
;; (: concat-str (-> String String String))
;; (= (concat-str $ls $rs)
;;    (let* (($lcs (stringToChars $ls))
;;           ($rcs (stringToChars $rs))
;;           ($lrcs (concat-atom $lcs $rcs)))
;;      (charsToString $lrcs)))

;; Test concat-str
!(assertEqual (concat-str "abc" "def") "abcdef")

;; Generate a String composed of a repeated String.
(: repeat-str (-> String Number String))
(= (repeat-str $s $n)
   (if (== $n 0)
       ""
       (let $r (repeat-str $s (- $n 1))
         (concat-str $s $r))))

;; Test repeat-str
!(assertEqual (repeat-str "abc" 3) "abcabcabc")

;; Generate a string composed of a reapeated character
;;
;; For instance
;;
;; repeat-chr
(: repeat-chr (-> Char Number String))
(= (repeat-chr $c $n)
   (repeat-str (charsToString ($c)) $n))

;; Test repeat-chr
!(assertEqual (repeat-chr ' ' 3) "   ")

;; Given a tuple of strings, return the length of the string with
;; maximum length.
(: max-len-strs (-> Expression Number))
(= (max-len-strs $strs)
   (if (== $strs ())
       0
       (let $lens (len-str (superpose $strs))
         (max-element (collapse $lens)))))

;; Test max-len-strs
!(assertEqual (max-len-strs ()) 0)
!(assertEqual (max-len-strs ("abc" "a" "abcd")) 4)


;; Pad the tailing part of a string with a given character to reach a
;; given len.  If the string is longer than the target len, then the
;; string is left untouched.
;;
;; For instance
;;
;; (pad-trail "abc" ' ' 5)
;;
;; outputs
;;
;; "abc  "
(: pad-trail (-> String Char Number String))
(= (pad-trail $s $c $n)
   (let $len (len-str $s)
     (if (< $len $n)
         (concat-str $s (repeat-char $c (- $n $len)))
         $s)))

;; Test pad-trail
!(assertEqual (pad-trail "abc" ' ' 5) "abc  ")

;; Like pad-trail but applied to a tuple of strings
(: pad-trails (-> Expression Char Number Expression))
(= (pad-trails $strs $c $n)
   (let* (($head (car-atom $strs))
          ($tail (cdr-atom $strs))
          ($padded-head (pad-trail $head $c $n))

;; Given two tuples of lines, draw them side by side, as if they were
;; both standing on the ground, with a given margin separating them.
;;
;; For instance
;;
;; (draw-side-by-side lhs rhs 1)
;;
;; where lhs represents
;;
;; "  / /"
;; " /-/"
;; "/ /"
;;
;; and rhs represents
;;
;; "  /"
;; " /"
;; "/"
;;
;; outputs
;;
;; "  / /   /"
;; " /-/   /"
;; "/ /   /"
(: draw-side-by-side (-> Expression Expression Number Expression))
(= (draw-side-by-side $lhs $rhs $margin)
   (let* (($lhs-nlines (arity $lhs))
          ($rhs-nlines (arity $rhs)))
     (if (< $lhs-nlines $rhs-lines)
         (let (($lhs-max-len (max-len-strs $lhs))
               ($lhs-padded (pad-trails $lhs $lhs-max-len " "))
         (repeat-str " " (pad-lines $lhs $lhs-max-len)

;; Given a fully annotated proof, return a string corresponding to an
;; ascii drawing of its proof in a Gentzen style.  For now, due to
;; MeTTa not supporting escaped characters, the ascii representation
;; is a tuple of lines, where each line is a String.  For instance the
;; string "abc\ndef" is represented by `("abs" "def")`.
;;
;; For instance
;;
;; (draw (: (ModusPonens (: bc (→ B C))
;;                       (: (ModusPonens (: ab (→ A B))
;;                                       (: a A)) B))
;;           C))
;;
;; Outputs
;;
;; "             -------(ab)  -(a)"
;; "             (→ A B)      A"
;; "-------(bc)  --------------(ModusPonens)"
;; "(→ B C)             B"
;; "---------------------(ModusPonens)"
;; "           C"
(: draw (-> Expression Expression))
(= (draw (: $prf $thrm))
   (if (is-expression $prf)
       ;; The proof is an expression
       (if (== $prf ())
           ()
           (let* (($prfabs (car-atom $prf))
                  ($prfabs-str (repr $prfabs))
                  ($prfabs-str-len (len-str $prfabs))
                  ($prfargs (cdr-atom $prf))
                  ($prfargs-strs (draw-tuple $prfargs))
                  ($prfargs-strs-len (max-element $prfargs-strs))
                  ($thrm-str (repr $thrm))
                  ($thrm-str-len (len-str $thrm-str))
                  ($line-str-len (max $prfargs-strs-len $thrm-str-len))
                  ($line-str (repeat-str "-" $line-str-len))
                  ($prfabs-par-str (concat-str (concat-str "(" $prfabs-str) ")"))
                  ($line-prfabs-str (concat-str $line-str $prfabs-par-str))
                  ($pad-len (ceil (/ (- $line-str-len $thrm-str-len)) 2))
                  ;; NEXT: can we simplify using pad-trail?
                  ($space-pad (repeat-str " " $pad-len))
                  ($padded-thrm-str (concat-str $space-pad $thrm-str)))
             (concat-atom $prfargs-strs ($line-prfabs-str $padded-thrm-str))))
       ;; The proof is a symbol, or else
       (let* (($prf-str (repr $prf))
              ($prf-par-str (concat-str (concat-str "(" $prf-str) ")"))
              ($thrm-str (repr $thrm))
              ($thrm-str-len (len-str $thrm-str))
              ($line-str (repeat-str "-" $thrm-str-len))
              ($line-prf-str (concat-str $line-str $prf-par-str)))
         ($line-prf-str $thrm-str))))

;; ;; Given a tuple of expressions of the form (: PROOF THEOREM), return
;; ;; an ascii drawing of these proofs in a Gentzen style side by side.
;; ;; Like for draw, a multi-line string is represented by a tuple of
;; ;; strings, one on each line.
;; ;;
;; ;; For instance
;; ;;
;; ;; (draw-tuple ((: bc (→ B C))
;; ;;              (: (ModusPonens (: ab (→ A B)) (: a A)) B))
;; ;;
;; ;; outputs
;; ;;
;; ;; "             -------(ab)  -(a)"
;; ;; "             (→ A B)      A"
;; ;; "-------(bc)  --------------(ModusPonens)"
;; ;; "(→ B C)             B"
;; (: draw-tuple (-> Expression Expression))
;; (= (draw-tuple $expr)
;;    (if (== $expr ())
;;        ()
;;        (let* (($head (car-atom $expr))
;;               ($tail (cdr-atom $expr))
;;               ($drawn-head (draw $head))
;;               ($drawn-tail (draw-tuple $tail))
;;               ($drawn-head-nlines (arity $drawn-head))
;;               ($drawn-tail-nlines (arity $drawn-tail)))
;;          (if (< $drawn-head-nlines $drawn-tail-nlines)
;;              ;; The tail is taller
;;              (let* (($head-max-len (max-element (len-str (superpose $drawn-head))
;;                     ($max-len-top-tail NEXT))))))))

;; Test draw
!(draw (: Refl (=== $x $x)))
