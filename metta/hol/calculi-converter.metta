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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Combinatory logic to λ-calculus ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; Convert combinatory logic term to lambda-calculus
;; (: cl2lc (-> Atom Atom))
;; ;; Base cases
;; (= (cl2lc ID) (λ $x $x))
;; (= (cl2lc AK) (λ $x (λ $y $x)))
;; (= (cl2lc AS) (λ $f (λ $g (λ $x (($f $x) ($g $x))))))
;; (= (cl2lc AM) (λ $x ($x $x)))
;; ;; Recursive step
;; (= (cl2lc ($f $g)) ((cl2lc $f) (cl2lc $g)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; λ-calculus to combinatory logic ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;; NEXT: complete.  It would be good if there is a notion of guards
;; Return True iff $x is a subterm of $f
;; (= (is-subterm-of $x $x) True)
;; (= (is-subterm-of $x $y) False)            ; NEXT if $x ≠ $y
;; (= (is-subterm-of $x ($x $y)) True)
;; (= (is-subterm-of $x ($y $x)) True)
;; (= (is-subterm-of $x ($y $z)) False)       ; NEXT if $x ≠ $y and $x ≠ $z
;; (= (is-subterm-of $x $y) (if (== $x $y)
;;                           True
;;                           ;; NEXT
(= (is-subterm-of $x $y)
   (if (== $x $y)
       True
       (case $y
         ((($a $b) (or (is-subterm-of $x $a)
                       (is-subterm-of $x $b)))
          (($a $b $c) (or (is-subterm-of $x $a)
                          (is-subterm-of $x $b)
                          (is-subterm-of $x $c)))
          ($_ False)))))

;; Tests
;; !(assertEqual (is-subterm-of A A) True)
;; !(assertEqual (is-subterm-of A (A B)) True)
;; !(assertEqual (is-subterm-of A B) False)
;; !(assertEqual (is-subterm-of A (B C)) False)
;; !(assertEqual (is-subterm-of $x $x) True)
!(assertEqual (is-subterm-of $x ($x $y)) True)
;; !(assertEqual (is-subterm-of $x $y) False)
;; !(assertEqual (is-subterm-of $x ($y $z)) False)
;; !(assertEqual (is-subterm-of A ($x A)) True)
;; !(assertEqual (is-subterm-of $x ($x A)) True)
;; !(assertEqual (is-subterm-of A ($x B)) False)
;; !(assertEqual (is-subterm-of $x ($y A)) False)
;; !(assertEqual (is-subterm-of A (C (B A))) True)
;; !(assertEqual (is-subterm-of A (B (C D))) False)

;; ;; Convert lambda-calculus term to combinatory logic term
;; (: lc2cl (-> Atom Atom))
;; ;; Base case
;; (= (lc2cl (λ $x $x)) ID)
;; ;; Recursive steps
;; (= (lc2cl (λ $x $f)) (if (is-subterm-of $x $f) (empty) (AK (lc2cl $f))))
;; (= (lc2cl (λ $x ($f $g))) ((AS (lc2cl (λ $x $f))) (lc2cl (λ $x $g))))
;; (= (lc2cl ($f $g)) ((lc2cl $f) (lc2cl $g)))

;; ;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; MeTTa to λ-calculus ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; Return True iff $x is a variable
;; (: is-variable (-> Atom Bool))
;; (= (is-variable $x)
;;    (case (let $x 1 True)
;;      ((True True)
;;       (%void% False))))

;; ;; NEXT:
;; ;; 1. replace LET by let (if possible)
;; ;; 2. support let*

;; ;; Convert a MeTTa expression to lambda calculus
;; (: mt2lc (-> Atom Atom))
;; (= (mt2lc $expr)
;;    (if (is-variable $expr)
;;        $expr
;;        (case $expr
;;          (((LET $x $y $f) ((λ $x (mt2lc $f)) (mt2lc $y)))  ; Let
;;           (($f $x) ((mt2lc $f) (mt2lc $x)))                ; Application
;;           ($s $s)))))                                      ; Symbol

;; ;;;;;;;;;;;;;;;;;;;;;
;; ;; Reduction rules ;;
;; ;;;;;;;;;;;;;;;;;;;;;

;; ;; NEXT: fix lambda application reduction, see
;; ;; https://github.com/trueagi-io/metta-examples/issues/39

;; ;; Reduce lambda application
;; (= ((λ $x $f) $y) (let $x $y $f))

;; ;;;;;;;;;;;
;; ;; Tests ;;
;; ;;;;;;;;;;;

;; ;; According to ChatGPT the following holds (NEXT: make sure there are
;; ;; no hallucination):
;; ;;
;; ;; Z (zero) would be represented by
;; ;; - combinatory logic: (AK ID)
;; ;; - lambda calculus: (λ $f (λ $x $x))
;; ;;
;; ;; S (successor) would be represented by (NEXT: is it really the case?)
;; ;; - combinatory logic: ((AS (AK AS)) AK)
;; ;; - lambda calculus: (λ $n (λ $f (λ $x ($f (($n $f) $x)))))
;; ;;
;; ;; 1 would be represented by
;; ;; - combinatory logic: NEXT
;; ;; - lambda calculus: (λ $f (λ $x ($f $x)))
;; ;;
;; ;; 2 would be represented by
;; ;; - combinatory logic: ((((AS (AK AS)) AK) ((AS (AK AS)) AK)) (AK ID))
;; ;; - lambda calculus: (λ $f (λ $x ($f ($f $x))))
;; ;;
;; ;; plus (addition) would be represented by
;; ;; - combinatory logic: ((AS (AS AK)) ID)
;; ;; - lambda calculus: ((λ $m) ((λ $n) ((λ $f) ((λ $x) (($m f) (($n $f) $x))))))
;; ;;
;; ;; times (multiplication) would be represented by
;; ;; - combinatory logic: ((AS ((AS (AK AS)) AK)) ID)
;; ;; - lambda calculus: ((λ $m) ((λ $n) ((λ $f) ((λ $x) (($m ($n $f)) $x)))))

;; ;; ;; Convert (AK ID) to (λ $f (λ $x $x)) (zero in lambda calculus)
;; ;; ;;
;; ;; ;; TODO: re-enable assertEqual when it will support alpha-equivalence.
;; ;; ;; Maybe we should introduce something like assertAlphaEqual.
;; ;; ;;
;; ;; ;; !(assertEqual
;; ;;   !(cl2lc (AK ID))
;; ;;   ;; (λ $f (λ $x $x)))

;; ;; ;; Convert ((AS ID) ID) to (λ $x ($x $x)) (M, the Mockingbird combinator)
;; ;; !(cl2lc ((AS ID) ID))

;; ;; Convert (M M) (reduction should not halt)
;; ;; !(cl2lc (M M))

;; ;; NEXT: fix lambda application reduction, see
;; ;; https://github.com/trueagi-io/metta-examples/issues/39
;; !(let $x (λ $y ($y $y)) ($x $x))

;; ;; ;; Convert ((AS (AK AS)) AK) to
;; ;; ;; (λ $n (λ $f (λ $x ($f (($n $f) $x))))) (successor in lambda calculus)
;; ;; !(cl2lc ((AS (AK AS)) AK))

;; ;; ;; Convert 1 to lambda calculus
;; ;; !(cl2lc ((((AS (AK AS)) AK) ((AS (AK AS)) AK)) (AK ID)))

;; ;; ;; Convert 2 to lambda calculus
;; ;; !(cl2lc ((((AS (AK AS)) AK) ((AS (AK AS)) AK)) (AK ID)))

;; ;; !(mt2lc
;; ;;   (LET $spleeter-output
;; ;;        (snet.sound-spleeter.spleeter ((snet.sound-spleeter.MkInput "") $input))
;; ;;        (LET $english-vocals (snet.sound-spleeter.Output.vocals $spleeter-output)
;; ;;             (LET $chinese-lyrics
;; ;;                  (naint.machine-translation.Output.translation
;; ;;                   (naint.machine-translation.translate
;; ;;                    (((naint.machine-translation.MkInput "English") "Chinese")
;; ;;                     (snet.speech-recognition.Text.text
;; ;;                      (snet.speech-recognition.s2t
;; ;;                       (snet.speech-recognition.MkAudio $english-vocals))))))
;; ;;                  (LET $midi-notes (tomidi.MIDI.data (tomidi.MkAudio $english-vocals))
;; ;;                       (LET $chinese-vocals
;; ;;                            (naint.midi2voice-zh.Answer.output_audio
;; ;;                             (naint.midi2voice-zh.singingZH
;; ;;                              (((naint.midi2voice-zh.MkQuery $chinese-lyrics)
;; ;;                                $midi-notes) 1.0)))
;; ;;                            (mixer.Audio.data
;; ;;                             (mixer.mix
;; ;;                              ((mixer.MkMultiAudio
;; ;;                                (snet.sound-spleeter.Output.accomp $spleeter-output))
;; ;;                               $chinese-vocals)))))))))
