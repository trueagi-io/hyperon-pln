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
;; is S, K, I.  In MeTTa these combinators are represented as AS, AK,
;; ID to not be confused with the successor function S.  Also all
;; functions are explicitly curried, thus K x y is represented in
;; MeTTa as ((K x) y).
;;
;; On the lambda-calculus side, the MeTTa representation of a lambda
;; abstraction is ((λ <VAR>) <BODY>), all explicitly curried as well.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Combinatory logic to λ-calculus ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Convert combinatory logic term to lambda-calculus
(: cl2lc (-> Atom Atom))
;; Base cases
(= (cl2lc ID) ((λ $x) $x))
(= (cl2lc AK) ((λ $x) ((λ $y) $x)))
(= (cl2lc AS) ((λ $f) ((λ $g) ((λ $x) (($f $x) ($g $x))))))
;; Recursive step
(= (cl2lc ($f $g)) ((cl2lc $f) (cl2lc $g)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; λ-calculus to combinatory logic ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; NEXT: complete the following
;;
;; ;; Convert lambda-calculus term to combinatory logic term
;; (: lc2cl (-> Atom Atom))
;; ;; Base case
;; (= (lc2cl ((λ $x) $x)) ID)
;; ;; Recursive steps
;; ;; (= (lc2cl ((λ $x) $f)) (AK (lc2cl $f))) if $x does not occur freely in $f
;; (= (lc2cl ((λ $x) ($f $g))) ((S (lc2cl ((λ $x) $f))) (lc2cl ((λ $x) $g))))
;; (= (lc2cl ($f $g)) ((lc2cl $f) (lc2cl $g)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; MeTTa to λ-calculus ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Return True iff $x is a variable
(: is-variable (-> Atom Bool))
(= (is-variable $x)
   (case (let $x 1 True)
     ((True True)
      (%void% False))))

;; NEXT:
;; 1. replace LET by let (if possible)
;; 2. support let*

;; Convert a MeTTa expression to lambda calculus
(: mt2lc (-> Atom Atom))
(= (mt2lc $expr)
   (if (is-variable $expr)
       $expr
       (case $expr
         (((LET $x $y $f) (((λ $x) (mt2lc $f)) (mt2lc $y))) ; Let
          (($f $x) ((mt2lc $f) (mt2lc $x)))                 ; Application
          ($s $s)))))                                       ; Symbol

;;;;;;;;;;;;;;;;;;;;;
;; Reduction rules ;;
;;;;;;;;;;;;;;;;;;;;;

;; ;; Reduce lambda application
;; (= (((λ $x) $f) $y) (let $x $y $f))

;;;;;;;;;;;
;; Tests ;;
;;;;;;;;;;;

;; According to ChatGPT the following holds (NEXT: make sure there are
;; no hallucination):
;;
;; Z (zero) would be represented by
;; - combinatory logic: (AK ID)
;; - lambda calculus: ((λ $f) ((λ $x) $x))
;;
;; S (successor) would be represented by
;; - combinatory logic: ((AS (AK AS)) AK)
;; - lambda calculus: ((λ $n) ((λ $f) ((λ $x) ($f (($n $f) $x)))))
;;
;; 2 would be represented by
;; - combinatory logic: ((((S (K S)) K) ((S (K S)) K)) (K I))
;; - lambda calculus: ((λ $f) ((λ $x) ($f ($f $x))))
;;
;; plus (addition) would be represented by
;; - combinatory logic: ((AS (AS AK)) ID)
;; - lambda calculus: ((λ $m) ((λ $n) ((λ $f) ((λ $x) (($m f) (($n $f) $x))))))
;;
;; times (multiplication) would be represented by
;; - combinatory logic: ((S ((S (K S)) K)) I)
;; - lambda calculus: ((λ $m) ((λ $n) ((λ $f) ((λ $x) (($m ($n $f)) $x)))))

;; Convert zero to lambda calculus.
;;
;; TODO: re-enable assertEqual when it will support alpha-equivalence.
;; Maybe we should introduce something like assertAlphaEqual.
;;
;; !(assertEqual
  ;; !(cl2lc (AK ID))
  ;; ((λ $f) ((λ $x) $x)))

;; NEXT: pursue according to the outcome of
;; https://github.com/trueagi-io/hyperon-experimental/issues/242#issuecomment-1948089755

;; NEXT: maybe dig into minimal metta, here are starting points
;;
;; https://github.com/trueagi-io/hyperon-experimental/blob/main/docs/minimal-metta.md
;; https://github.com/trueagi-io/hyperon-experimental/blob/main/lib/src/metta/runner/stdlib.metta

;; Convert successor to lambda calculus
;; !(cl2lc (AK AS))
;; (((λ $x#20) ((λ $y#21) $x#20)) ((λ $f#41) ((λ $g#42) ((λ $x#43) (($f#41 $x#43) ($g#42 $x#43))))))
;; -->
;; ((λ $y#21) ((λ $f#41) ((λ $g#42) ((λ $x#43) (($f#41 $x#43) ($g#42 $x#43))))))
;; !(cl2lc (AS (AK AS)))
;; !(cl2lc ((AS (AK AS)) AK))

;; (((λ $x#20) ((λ $y#21) $x#20)) ((λ $x#41) $x#41))

!(mt2lc
  (LET $spleeter-output
       (snet.sound-spleeter.spleeter ((snet.sound-spleeter.MkInput "") $input))
       (LET $english-vocals (snet.sound-spleeter.Output.vocals $spleeter-output)
            (LET $chinese-lyrics
                 (naint.machine-translation.Output.translation
                  (naint.machine-translation.translate
                   (((naint.machine-translation.MkInput "English") "Chinese")
                    (snet.speech-recognition.Text.text
                     (snet.speech-recognition.s2t
                      (snet.speech-recognition.MkAudio $english-vocals))))))
                 (LET $midi-notes (tomidi.MIDI.data (tomidi.MkAudio $english-vocals))
                      (LET $chinese-vocals
                           (naint.midi2voice-zh.Answer.output_audio
                            (naint.midi2voice-zh.singingZH
                             (((naint.midi2voice-zh.MkQuery $chinese-lyrics)
                               $midi-notes) 1.0)))
                           (mixer.Audio.data
                            (mixer.mix
                             ((mixer.MkMultiAudio
                               (snet.sound-spleeter.Output.accomp $spleeter-output))
                              $chinese-vocals)))))))))
