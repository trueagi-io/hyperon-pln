;; Implement functions to convert terms between lambda-calculus and
;; combinatory logic.
;;
;; The code is extracted from:
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

;; Convert combinatory logic term to lambda-calculus
(: cl2lc (-> Atom Atom))
;; Base cases
(= (cl2lc ID) ((λ $x) $x))
(= (cl2lc AK) ((λ $x) ((λ $y) $x)))
(= (cl2lc AS) ((λ $f) ((λ $g) ((λ $x) (($f $x) ($g $x))))))
;; Recursive step
(= (cl2lc ($f $g)) ((cl2lc $f) (cl2lc $g)))

;; Convert lambda-calculus term to combinatory logic term
(: lc2cl (-> Atom Atom))
;; Base case
(= (lc2cl ((λ $x) $x)) ID)
;; Recursive steps
;; NEXT
;; (= (lc2cl ((λ $x) $f)) (AK (lc2cl $f))) if $x does not occur freely in $f
(= (lc2cl ((λ $x) ($f $g))) ((S (lc2cl ((λ $x) $f))) (lc2cl ((λ $x) $g))))
(= (lc2cl ($f $g)) ((lc2cl $f) (lc2cl $g)))

;; According to ChatGPT:
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
