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

;; Flatten a curried expression.  For instance
;;
;; (flatten ((f a) b)) returns (f a b)
;;
;; Note that it only flattens left-associative application.  Therefore
;; it will not work on the arrow type as it is right-associative.  For
;; instance
;;
;; (flatten (-> T1 (-> T2 T3))) returns (-> T1 (-> T2 T3)), not (-> T1 T2 T3)
(= (flatten $term)
   (case (get-metatype $term)
     ((Symbol $term)
      (Variable $term)
      (Expression
       (if (== $term ())
           ()
           (let* (($hd (flatten (car-atom $term)))
                  ($tl (flatten (cdr-atom $term))))
             (case (get-metatype $hd)
               ((Symbol (cons-atom $hd $tl))
                (Variable (cons-atom $hd $tl))
                (Expression
                 (if (== $hd ())
                     (cons-atom $hd $tl)
                     (let* (($hd-hd (car-atom $hd))
                            ($tl-hd (cdr-atom $hd))
                            ($tl-hd-tl (concat-atom $tl-hd $tl)))
                       (trace! ((term $term)
                                (hd $hd)
                                (tl $tl)
                                (hd-hd $hd-hd)
                                (tl-hd $tl-hd)
                                (tl-hd-tl $tl-hd-tl)
                                (result (cons-atom $hd-hd $tl-hd-tl)))
                               (cons-atom $hd-hd $tl-hd-tl)))))))))))))

;; Test flatten
;; !(assertEqual
;;   (flatten a)
;;   a)
;; !(assertEqual
;;   (flatten $x)
;;   $x)
;; !(assertEqual
;;   (flatten ())
;;   ())
;; !(assertEqual
;;   (flatten (()))
;;   (()))
;; !(assertEqual
;;   (flatten (f a))
;;   (f a))
!(assertEqual
  (flatten ((f a)))
  ((f a)))                        ; NEXT: what should it be? (f a) or ((f a))?
;; !(assertEqual
;;   (flatten (() a))
;;   (() a))
;; !(assertEqual
;;   (flatten ((f a) b))
;;   (f a b))
;; !(assertEqual
;;   (flatten ((f a) ()))
;;   (f a ()))
;; !(assertEqual
;;   (flatten ((f a b) c))
;;   (f a b c))
;; !(assertEqual
;;   (flatten (((f a) b) c))
;;   (f a b c))
;; !(assertEqual
;;   (flatten ((f a) (g c)))
;;   (f a (g c))) ; NEXT
;; !(assertEqual
;;   (flatten (((f a) b) (g c)))
;;   (f a b (g c))) ; NEXT
;; !(assertEqual
;;   (flatten (((f a) b) ((g c) d)))
;;   (f a b (g c d))) ; NEXT
