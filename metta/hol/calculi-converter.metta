;; Implement functions to convert terms between MeTTa, lambda calculus
;; and combinatory logic.
;;
;; For the lambda calculus <-> combinatory logic part, the code is
;; inspired from the paper:
;;
;; A correct-by-construction conversion from lambda calculus to
;; combinatory logic, by Wouter Swierstra.
;;
;; As in the paper, the version of combinatory logic in consideration
;; is S, K, I.  For now S, the combinator, cannot be confused with S,
;; the successor function, because Nat is not defined here, however we
;; may want in the future to represent these combinators as AS, AK, ID
;; to not be confused with S, the successor function.  Also all
;; functions are explicitly curried, thus K x y is represented in
;; MeTTa as ((K x) y).
;;
;; On the lambda-calculus side, the MeTTa representation of a lambda
;; abstraction is (λ <VAR> <BODY>).  Applications are explicitly
;; curried as well, thus (x y z) is represented ((x y) z).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Common functions and types ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define Maybe type
(: Maybe (-> $a Type))
(: Nothing (Maybe $a))
(: Just (-> $a (Maybe $a)))

;; Define list type
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Define is-expression, a function that returns True iff the input is
;; a MeTTa expression, meaning it is not a symbol or a variable.
(: is-expression (-> Atom Bool))
(= (is-expression $x) (== (get-metatype $x) Expression))

;; Test is-expression
!(assertEqual (is-expression $x) False)
!(assertEqual (is-expression A) False)
!(assertEqual (is-expression (A B)) True)

;; Define is-variable, a function that returns True iff its input is a
;; MeTTa variable.
(: is-variable (-> Atom Bool))
(= (is-variable $x) (== (get-metatype $x) Variable))

;; Test is-variable
!(assertEqual (is-variable $x) True)
!(assertEqual (is-variable A) False)
!(assertEqual (is-variable (A $x)) False)

;; Define is-symbol, a function that returns True iff its input is a
;; MeTTa symbol.
(: is-symbol (-> Atom Bool))
(= (is-symbol $x) (== (get-metatype $x) Symbol))

;; Test is-symbol
!(assertEqual (is-symbol $x) False)
!(assertEqual (is-symbol A) True)
!(assertEqual (is-symbol (A $x)) False)

;; Till lazy or and and gets into the stdlib
(: lazy-or (-> Bool Atom Bool))
(= (lazy-or False $x) $x)
(= (lazy-or True $x) True)
(: lazy-and (-> Bool Atom Bool))
(= (lazy-and False $x) False)
(= (lazy-and True $x) $x)

;; Return True iff the first argument is a subterm of the second
;; argument.
;;
;; For instance
;;
;; (is-subterm-of A A) returns True
;; (is-subterm-of A (A B)) returns True
;; (is-subterm-of A B) returns False
;; (is-subterm-of A (B C)) returns False
;;
;; It should handle variables properly (that is assume that variables
;; with different names are different terms), for instance
;;
;; (is-subterm-of $x $x) returns True
;; (is-subterm-of $x ($x $y)) returns True
;; (is-subterm-of $x $y) returns False
;; (is-subterm-of $x ($y $z)) return False
;;
;; Terms can of course contain both symbols and variables, for
;; instance
;;
;; (is-subterm-of A ($x A)) returns True
;; (is-subterm-of $x ($x A)) returns True
;; (is-subterm-of A ($x B)) returns False
;; (is-subterm-of $x ($y A)) returns False
;;
;; It should of course detect a subterm when it is buried deeper
;; inside the superterm, for instance
;;
;; (is-subterm-of A (C (B A))) returns True
;; (is-subterm-of A (B (C D))) returns False
(: is-subterm-of (-> Atom Atom Bool))
(= (is-subterm-of $x $y)
   ;; Base cases
   (if (== $x $y)
       True
       (if (== $y ())
           False
           ;; Recursive step
           (if (is-expression $y)
               (lazy-or (let $head (car-atom $y) (is-subterm-of $x $head))
                        (let $tail (cdr-atom $y) (is-subterm-of $x $tail)))
               ;; Final base case
               False))))

;; Test is-subterm-of
!(assertEqual (is-subterm-of A A) True)
!(assertEqual (is-subterm-of A ()) False)
!(assertEqual (is-subterm-of A (A B)) True)
!(assertEqual (is-subterm-of A B) False)
!(assertEqual (is-subterm-of A (B C)) False)
!(assertEqual (is-subterm-of $x $x) True)
!(assertEqual (is-subterm-of $x ($x $y)) True)
!(assertEqual (is-subterm-of $x $y) False)
!(assertEqual (is-subterm-of $x ($y $z)) False)
!(assertEqual (is-subterm-of A ($x A)) True)
!(assertEqual (is-subterm-of $x ($x A)) True)
!(assertEqual (is-subterm-of A ($x B)) False)
!(assertEqual (is-subterm-of $x ($y A)) False)
!(assertEqual (is-subterm-of A (C (B A))) True)
!(assertEqual (is-subterm-of A (B (C D))) False)

;; Return True iff the expression is a tuple of variables
(: all-variables (-> Expression Bool))
(= (all-variables $x) (if (== $x ())
                             True
                             (and (let $head (car-atom $x) (is-variable $head))
                                  (let $tail (cdr-atom $x) (all-variables $tail)))))

;; Return True iff the expression is a tuple of unique variables.
;; Note that it only supports pairs and triples because that is all we
;; need here.
(: uniq-vars (-> Expression Bool))
(= (uniq-vars ($x $y)) (and (all-variables ($x $y)) (not (== $x $y))))
(= (uniq-vars ($x $y $z)) (and (all-variables ($x $y $z))
                               (and (not (== $x $y))
                                    (and (not (== $y $z))
                                         (not (== $x $z))))))

;; Define α-Binding type, that represents a binding from a variable to
;; another variable.
(: α-Binding Type)
(: ↔α (-> Variable Variable α-Binding))

;; Insert an α-binding in a list of α-bindings.  Returns maybe the new
;; list of α-bindings if the insertion succeeded, that is the
;; α-binding is consistent with the list, or entirely missing from it.
(: α-insert (-> α-Binding (List α-Binding) (Maybe (List α-Binding))))
;; Base case
(= (α-insert (↔α $x $y) Nil) (Just (Cons (↔α $x $y) Nil)))
;; Recursive step
(= (α-insert (↔α $x $y) (Cons (↔α $z $w) $tail))
   (if (== $x $z)
       (if (== $y $w)
           (Just (Cons (↔α $z $w) $tail))
           Nothing)
       (if (== $y $w)
           Nothing
           (case (α-insert (↔α $x $y) $tail)
             ((Nothing Nothing)
              ((Just $νtl) (Just (Cons (↔α $z $w) $νtl))))))))

;; Test α-insert
!(assertEqual
  (α-insert (↔α $x $y) Nil)
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-insert (↔α $x $y) (Cons (↔α $x $y) Nil))
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-insert (↔α $x $y) (Cons (↔α $x $z) Nil))
  Nothing)
!(assertEqual
  (α-insert (↔α $x $y) (Cons (↔α $z $w) Nil))
  (Just (Cons (↔α $z $w) (Cons (↔α $x $y) Nil))))

;; Join two α-bindings to produce an α-bindings consisting of the
;; union of these.  If the two α-bindings provided in input are
;; inconsistent, or one of them in Nothing, then return Nothing.
(: α-join (-> (Maybe (List α-Binding))
              (Maybe (List α-Binding))
              (Maybe (List α-Binding))))
;; Base cases
(= (α-join Nothing Nothing) Nothing)
(= (α-join Nothing (Just $_)) Nothing)
(= (α-join (Just $_) Nothing) Nothing)
(= (α-join (Just Nil) (Just $other)) (Just $other))
;; Recursive step
(= (α-join (Just (Cons $head $tail)) (Just $other))
   (α-join (Just $tail) (α-insert $head $other)))

;; Test α-join
!(assertEqual
  (α-join Nothing Nothing)
  Nothing)
!(assertEqual
  (α-join (Just Nil) (Just Nil))
  (Just Nil))
!(assertEqual
  (α-join (Just Nil) (Just (Cons (↔α $x $y) Nil)))
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-join (Just (Cons (↔α $x $y) Nil)) (Just Nil))
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-join (Just Nil) (Just (Cons (↔α $x $y) Nil)))
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-join (Just (Cons (↔α $x $y) Nil)) (Just (Cons (↔α $x $z) Nil)))
  Nothing)
!(assertEqual
  (α-join (Just (Cons (↔α $x $y) Nil)) (Just (Cons (↔α $x $y) Nil)))
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-join (Just (Cons (↔α $x $y) Nil)) (Just (Cons (↔α $z $w) Nil)))
  (Just (Cons (↔α $z $w) (Cons (↔α $x $y) Nil))))

;; Given two terms, $lhs and $rhs, return maybe a list of α-bindings
;; so that if $lhs is α-equivalent to $rhs, substituting all variables
;; in $rhs according to the α-bindings would result in a term that is
;; equal to $lhs.  If $lhs and $rhs are not α-equivalent then return
;; Nothing.
(: α-bindings (-> Atom Atom (Maybe (List α-Binding))))
(= (α-bindings $lhs $rhs)
   (case (get-metatype $lhs)
     ((Symbol (if (== $lhs $rhs)
                  (Just Nil)
                  Nothing))
      (Grounded (if (== $lhs $rhs)
                    (Just Nil)
                    Nothing))
      (Variable (if (is-variable $rhs)
                    (Just (Cons (↔α $lhs $rhs) Nil))
                    Nothing))
      (Expression (if (== $lhs ())
                      ;; $lhs is ()
                      (if (== $rhs ())
                          (Just Nil)
                          Nothing)
                      ;; $lhs is not ()
                      (if (== $rhs ())
                          Nothing
                          (let* (($hd-lhs (car-atom $lhs))
                                 ($tl-lhs (cdr-atom $lhs))
                                 ($hd-rhs (car-atom $rhs))
                                 ($tl-rhs (cdr-atom $rhs))
                                 ($hd-α-bs (α-bindings $hd-lhs $hd-rhs))
                                 ($tl-α-bs (α-bindings $tl-lhs $tl-rhs)))
                            (α-join $hd-α-bs $tl-α-bs))))))))

;; Test α-bindings
!(assertEqual
  (α-bindings A B)
  Nothing)
!(assertEqual
  (α-bindings $x B)
  Nothing)
!(assertEqual
  (α-bindings () ())
  (Just Nil))
!(assertEqual
  (α-bindings $x $y)
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-bindings (R $x) (R $y))
  (Just (Cons (↔α $x $y) Nil)))
!(assertEqual
  (α-bindings ((R $x) A) ((R $y) $z))
  Nothing)
!(assertEqual
  (α-bindings ((R $x) $x) ((R $z) $w))
  Nothing)
!(assertEqual
  (α-bindings ((R $x) $y) ((R $z) $z))
  Nothing)
!(assertEqual
  (α-bindings ((R $x) $y) ((R $z) $w))
  (Just (Cons (↔α $y $w) (Cons (↔α $x $z) Nil))))

;; Return True iff two given terms are alpha-equivalent.  For now all
;; variables are assumed to be free, the notion of scope is not
;; implemented.
(: =α (-> Atom Atom Bool))
(= (=α $lhs $rhs) (case (α-bindings $lhs $rhs)
                    ((Nothing False)
                     ((Just $_) True))))

;; Test =α
!(assertEqual (=α $x $x) True)
!(assertEqual (=α $x $y) True)
!(assertEqual (=α A B) False)
!(assertEqual (=α A $y) False)
!(assertEqual (=α (R $x) (R $y)) True)
!(assertEqual (=α (R $x $x) (R $y $z)) False)

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; NEXT: fix lambda application reduction, see
;; https://github.com/trueagi-io/metta-examples/issues/39

;; ;; Reduce lambda application
;; ;; (= ((λ $x $f) $y) (let $x $y $f))
;; (= ((λ $x $f) $y) (let ($νx $νf) (sealed ($x) ($x $f)) (let $νx $y $νf)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Combinatory logic to λ-calculus ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Convert combinatory logic term to lambda-calculus
(: cl2lc (-> Atom Atom))
;; Base cases
(= (cl2lc ID) (λ $x $x))
(= (cl2lc AK) (λ $x (λ $y $x)))
(= (cl2lc AS) (λ $f (λ $g (λ $x (($f $x) ($g $x))))))
(= (cl2lc AM) (λ $x ($x $x)))
;; Recursive step
(= (cl2lc ($f $g)) ((cl2lc $f) (cl2lc $g)))

;; Test cl2lc

;; According to ChatGPT the following holds (NEXT: make sure there are
;; no hallucination):
;;
;; Z (zero) would be represented by
;; - combinatory logic: (AK ID)
;; - lambda calculus: (λ $f (λ $x $x))
;;
;; S (successor) would be represented by (NEXT: is it really the case?)
;; - combinatory logic: ((AS (AK AS)) AK)
;; - lambda calculus: (λ $n (λ $f (λ $x ($f (($n $f) $x)))))
;;
;; 1 would be represented by
;; - combinatory logic: NEXT
;; - lambda calculus: (λ $f (λ $x ($f $x)))
;;
;; 2 would be represented by
;; - combinatory logic: ((((AS (AK AS)) AK) ((AS (AK AS)) AK)) (AK ID))
;; - lambda calculus: (λ $f (λ $x ($f ($f $x))))
;;
;; plus (addition) would be represented by
;; - combinatory logic: ((AS (AS AK)) ID)
;; - lambda calculus: ((λ $m) ((λ $n) ((λ $f) ((λ $x) (($m f) (($n $f) $x))))))
;;
;; times (multiplication) would be represented by
;; - combinatory logic: ((AS ((AS (AK AS)) AK)) ID)
;; - lambda calculus: ((λ $m) ((λ $n) ((λ $f) ((λ $x) (($m ($n $f)) $x)))))

;; ;; Convert (AK ID) to (λ $f (λ $x $x)) (zero in lambda calculus)
;; ;;
;; ;; TODO: re-enable assertEqual when it will support alpha-equivalence.
;; ;; Maybe we should introduce something like assertAlphaEqual.
;; ;;
;; ;; !(assertEqual
;;   !(cl2lc (AK ID))
;;   ;; (λ $f (λ $x $x)))

;; ;; Convert ((AS ID) ID) to (λ $x ($x $x)) (M, the Mockingbird combinator)
;; !(cl2lc ((AS ID) ID))

;; ;; Disabled because it does not half, as it should
;; ;; Convert (AM AM) (reduction should not halt)
;; ;; !(cl2lc (AM AM))

;; ;; Convert (AS ID) to
;; !(cl2lc (AS ID))

;; ;; NEXT: find out if the following is correct

;; ;; Convert ((AS (AK AS)) AK) to
;; ;; (λ $n (λ $f (λ $x ($f (($n $f) $x))))) (successor in lambda calculus)
;; !(cl2lc ((AS (AK AS)) AK))

;; ;; Convert 1 to lambda calculus
;; !(cl2lc ((((AS (AK AS)) AK) ((AS (AK AS)) AK)) (AK ID)))

;; ;; Convert 2 to lambda calculus
;; !(cl2lc ((((AS (AK AS)) AK) ((AS (AK AS)) AK)) (AK ID)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; λ-calculus to combinatory logic ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; NEXT: can we avoid the is-variable condition by using the type checker?

;; ;; Convert lambda-calculus term to combinatory logic term.
;; (: lc2cl (-> Atom Atom))
;; (= (lc2cl $term)
;;    (case (get-metatype $term)
;;      ((Variable $term)
;;       (Symbol $term)
;;       (Expression (case $term
;;                     (;; Base cases
;;                      (() ())                                 ; Empty tuple
;;                      ((λ $x $x)                              ; ID
;;                       (if (is-variable $x) ID (empty)))
;;                      ((λ $x (λ $y $x))                       ; AK
;;                       (if (uniq-vars ($x $y)) AK (empty)))
;;                      ((λ $f (λ $g (λ $x (($f $x) ($g $x))))) ; AS
;;                       (if (uniq-vars ($f $g $x)) AS (empty)))
;;                      ((λ $x ($x $x))                         ; AM
;;                       (if (is-variable $x) AM (empty)))
;;                      ;; Recursive steps
;;                      ((λ $x $f)) (if (and (is-variable $x) (not (is-subterm-of $x $f)))
;; ;;                          (AK (lc2cl $f))
;; ;;                          (empty)))

;;                      (($f $g) ((lc2cl $f) (lc2cl $g)))

;; ;; NEXT: test (λ $x (λ $y $z))

;; ;; NEXT: maybe introduce alpha-equivalent

;; ;; ;; Base cases
;; ;; (= (lc2cl (λ $x $x)) (if (is-variable $x) ID (empty)))
;; ;; (= (lc2cl (λ $x (λ $y $x))) (if (uniq-vars ($x $y)) AK (empty)))
;; ;; (= (lc2cl (λ $f (λ $g (λ $x (($f $x) ($g $x)))))) (if (uniq-vars ($f $g $x))
;; ;;                                                       AS
;; ;;                                                       (empty)))
;; ;; (= (lc2cl (λ $x ($x $x))) (if (is-variable $x) AM (empty)))
;; ;; ;; Recursive steps
;; ;; (= (lc2cl (λ $x $f)) (if (and (is-variable $x) (not (is-subterm-of $x $f)))
;; ;;                          (AK (lc2cl $f))
;; ;;                          (empty)))
;; ;; (= (lc2cl (λ $x ($f $g))) (if (is-variable $x)
;; ;;                               ((AS (lc2cl (λ $x $f))) (lc2cl (λ $x $g)))
;; ;;                               (empty)))
;; ;; (= (lc2cl ($f $g)) ((lc2cl $f) (lc2cl $g)))

;; ;; ;; Test lc2cl

;; ;; ;; Convert (λ $x $x) to ID
;; ;; !(assertEqual (lc2cl (λ $x $x)) ID)

;; ;; ;; Convert (λ $x (λ $y $x)) to AK
;; ;; !(assertEqual (lc2cl (λ $x (λ $y $x))) AK)

;; ;; ;; Convert (λ $f (λ $g (λ $x (($f $x) ($g $x))))) to AS
;; ;; !(assertEqual (lc2cl (λ $f (λ $g (λ $x (($f $x) ($g $x)))))) AS)

;; ;; ;; Convert (λ $x ($x $x)) to AM
;; ;; !(assertEqualToResult
;; ;;   (lc2cl (λ $x ($x $x)))
;; ;;   (AM
;; ;;    ((AS ID) ID)))

;; ;; ;; Convert Z from lambda calculus to combinatory logic, that is
;; ;; ;; (λ $f (λ $x $x)) |-> (AK ID)
;; ;; !(assertEqual
;; ;;   (lc2cl (λ $f (λ $x $x)))
;; ;;   (AK ID))


;; !(lc2cl $f)
;; ;; !(lc2cl ($f $x))
;; ;; !(lc2cl ($f ($f $x)))
;; ;; !(lc2cl (λ $x ($f ($f $x))))
;; ;; !(lc2cl (λ $f (λ $x ($f ($f $x)))))

;; ;; ;; NEXT: find out why the following does not work

;; ;; ;; Convert (λ $g (λ $x ($g $x))) to ?
;; ;; !(lc2cl (λ $g (λ $x ($g $x))))

;; ;; ;; ;; Convert (λ $g (λ $x ($x ($g $x)))) to ?
;; ;; ;; !(lc2cl (λ $g (λ $x ($x ($g $x)))))

;; ;; ;; ;; Convert ((λ $f (λ $g (λ $x (($f $x) ($g $x))))) (λ $y $y)) to (AS ID)
;; ;; ;; !(lc2cl ((λ $f (λ $g (λ $x (($f $x) ($g $x))))) (λ $y $y)))

;; ;; ;; ;; Convert S from lambda calculus to combinatory logic.  That is
;; ;; ;; ;; (λ $n (λ $f (λ $x ($f (($n $f) $x))))) |-> ((AS (AK AS)) AK)
;; ;; ;; !(lc2cl (λ $n (λ $f (λ $x ($f (($n $f) $x))))))

;; ;; ;; (λ $n (λ $f (λ $x ($f (($n $f) $x)))))
;; ;; ;; -->

;; ;; ;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; ;; MeTTa to λ-calculus ;;
;; ;; ;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; ;; NEXT:
;; ;; ;; 1. replace LET by let (if possible)
;; ;; ;; 2. support let*

;; ;; ;; Convert a MeTTa expression to lambda calculus
;; ;; (: mt2lc (-> Atom Atom))
;; ;; (= (mt2lc $expr)
;; ;;    (if (is-variable $expr)
;; ;;        $expr
;; ;;        (case $expr
;; ;;          (((LET $x $y $f) ((λ $x (mt2lc $f)) (mt2lc $y)))  ; Let
;; ;;           (($f $x) ((mt2lc $f) (mt2lc $x)))                ; Application
;; ;;           ($s $s)))))                                      ; Symbol

;; ;; ;; !(mt2lc
;; ;; ;;   (LET $spleeter-output
;; ;; ;;        (snet.sound-spleeter.spleeter ((snet.sound-spleeter.MkInput "") $input))
;; ;; ;;        (LET $english-vocals (snet.sound-spleeter.Output.vocals $spleeter-output)
;; ;; ;;             (LET $chinese-lyrics
;; ;; ;;                  (naint.machine-translation.Output.translation
;; ;; ;;                   (naint.machine-translation.translate
;; ;; ;;                    (((naint.machine-translation.MkInput "English") "Chinese")
;; ;; ;;                     (snet.speech-recognition.Text.text
;; ;; ;;                      (snet.speech-recognition.s2t
;; ;; ;;                       (snet.speech-recognition.MkAudio $english-vocals))))))
;; ;; ;;                  (LET $midi-notes (tomidi.MIDI.data (tomidi.MkAudio $english-vocals))
;; ;; ;;                       (LET $chinese-vocals
;; ;; ;;                            (naint.midi2voice-zh.Answer.output_audio
;; ;; ;;                             (naint.midi2voice-zh.singingZH
;; ;; ;;                              (((naint.midi2voice-zh.MkQuery $chinese-lyrics)
;; ;; ;;                                $midi-notes) 1.0)))
;; ;; ;;                            (mixer.Audio.data
;; ;; ;;                             (mixer.mix
;; ;; ;;                              ((mixer.MkMultiAudio
;; ;; ;;                                (snet.sound-spleeter.Output.accomp $spleeter-output))
;; ;; ;;                               $chinese-vocals)))))))))
