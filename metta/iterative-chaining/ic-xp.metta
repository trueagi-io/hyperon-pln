;; Standalone iterative chaining experiments.

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

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Forward Bare Entail ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Reuse the Bare Entail forward chainer of
;; `../forward-chaining/fc-xp.metta`.  However it only returns results
;; at the exact provided depth, that way we avoid redundancy, which is
;; better in the context of testing the iterative chainer.

;; Foward chainer
(: fc_bare (-> Atom (-> Atom) (-> Atom) Nat Atom))
;; Base case
(= (fc_bare $premise $kb $rb Z) $premise)
;; Recursive steps
(= (fc_bare $premise1 $kb $rb (S $k))
   (let* (((⊢ $premise1 $premise2 $conclusion) ($rb))
          ($premise2 ($kb)))
     (fc_bare $conclusion $kb $rb $k)))
(= (fc_bare $premise2 $kb $rb (S $k))
   (let* (((⊢ $premise1 $premise2 $conclusion) ($rb))
          ($premise1 ($kb)))
     (fc_bare $conclusion $kb $rb $k)))

;; Knowledge base
(: kb_bare (-> Atom))
(= (kb_bare) (superpose ((→ A B)
                         (→ B C)
                         A)))

;; Rule base
(: rb_bare (-> Atom))
(= (rb_bare) (superpose ((⊢             ; Modus Ponens
                          ;; Premises
                          (→ $p $q)
                          $p
                          ;; Conclusion
                          $q)
                         (⊢             ; Deduction
                          ;; Premises
                          (→ $p $q)
                          (→ $q $r)
                          ;; Conclusion
                          (→ $p $r)))))

;; Test forward chainer
! "=== Test Forward Bare Entail ==="
!(assertEqual
  (fc_bare A kb_bare rb_bare (fromNumber 1))
  B)
!(assertEqual
  (fc_bare A kb_bare rb_bare (fromNumber 2))
  C)
!(assertEqualToResult
  (fc_bare (→ A B) kb_bare rb_bare (fromNumber 2))
  (C
   C))

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility Functions ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; Define quoted to prevent wrapped atom from being interpreted
(: quoted (-> Atom Atom))

;; Define nullary lambda
(: lambda0 (-> Atom (-> $t)))
(= ((lambda0 $body)) $body)

;; Define unary lambda
(: lambda1 (-> Variable Atom (-> $a $t)))
(= ((lambda1 $var $body) $val)
    (let (quoted $var) (quoted $val) $body))

;; Test utility functions
! "=== Test Utility Functions ==="

;; Test lambda0
!(assertEqualToResult
  ((lambda0 "f"))
  ("f"))
!(assertEqualToResult
  ((let $s (superpose ("f" "g")) (lambda0 $s)))
  ("f" "g"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iterative Chainer Wrapped Around Forward Bare Entail (no collapse) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Call the forward chainer iteratively, adding the conclusions to the
;; knowledge after each iterations.  That version does not collapse
;; the results of the forward chainer between iterations.
(: ic_bare (-> Atom                          ; Premise
               (-> Atom)                     ; Knowledge base
               (-> Atom)                     ; Rule base
               Nat                           ; Depth
               Nat                           ; Number of iterations
               (-> Atom)))                   ; Updated knowledge base
(= (ic_bare $prms $kb $rb $depth Z) $kb)
(= (ic_bare $prms $kb $rb $depth (S $k))
   (case (fc_bare $prms $kb $rb $depth)
     (($result (ic_bare $result (superpose ($kb (lambda0 $result))) $rb $depth $k))
      (%void (empty)))))

;; Test Iterative Chainer Wrapped Ardoun Forward Bare Entail (no collapse)
! "=== Test Iterative Chainer Wrapped Ardoun Forward Bare Entail (no collapse) ==="

;; No iteration
!(assertEqual
  (ic_bare A kb_bare rb_bare Z Z)
  kb_bare)

;; No iteration (apply result)
!(assertEqualToResult
  ((ic_bare A kb_bare rb_bare Z Z))
  ((→ A B)
   (→ B C)
   A))

;; One iteration of one step forward chainer (apply result)
!(assertEqualToResult
  (ic_bare A kb_bare rb_bare (fromNumber 1) (fromNumber 1))
  (kb_bare
   (lambda0 B)))

;; One iteration of one step forward chainer (apply result)
!(assertEqualToResult
  ((ic_bare A kb_bare rb_bare (fromNumber 1) (fromNumber 1)))
  ((→ A B)
   (→ B C)
   A
   B))

;; Two iterations of one step forward chainer
!(assertEqualToResult
  (ic_bare A kb_bare rb_bare (fromNumber 1) (fromNumber 2))
  (kb_bare
   (lambda0 C)))

;; Two iterations of one step forward chainer (apply result)
!(assertEqualToResult
  ((ic_bare A kb_bare rb_bare (fromNumber 1) (fromNumber 2)))
  ((→ A B)
   (→ B C)
   A
   C))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iterative Chainer Wrapped Around Forward Bare Entail (collapse) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Call the forward chainer iteratively, adding the conclusions to the
;; knowledge after each iterations.  That version collapses the
;; results of the forward chainer between iterations.
(: ic_bare_collapse (-> Atom                          ; Premise
                        (-> Atom)                     ; Knowledge base
                        (-> Atom)                     ; Rule base
                        Nat                           ; Depth
                        Nat                           ; Number of iterations
                        (-> Atom)))                   ; Updated knowledge base
(= (ic_bare_collapse $prms $kb $rb $depth Z) $kb)
(= (ic_bare_collapse $prms $kb $rb $depth (S $k))
   (let* (($clp_res (collapse (fc_bare $prms $kb $rb $depth)))
          ($kb_ext (lambda0 (superpose $clp_res)))
          ($nu_kb (superpose ($kb $kb_ext))))
     (ic_bare_collapse (superpose $clp_res) $nu_kb $rb $depth $k)))

;; Test Iterative Chainer Wrapped Ardoun Forward Bare Entail (no collapse)
! "=== Test Iterative Chainer Wrapped Ardoun Forward Bare Entail (collapse) ==="

;; No iteration
!(assertEqual
  (ic_bare_collapse A kb_bare rb_bare Z Z)
  kb_bare)

;; No iteration (apply result)
!(assertEqualToResult
  ((ic_bare_collapse A kb_bare rb_bare Z Z))
  ((→ A B)
   (→ B C)
   A))

;; One iteration of one step forward chainer
!(assertEqualToResult
  (ic_bare_collapse A kb_bare rb_bare (fromNumber 1) (fromNumber 1))
  (kb_bare
   (lambda0 (superpose (B)))))

;; One iteration of one step forward chainer (apply result)
!(assertEqualToResult
  ((ic_bare_collapse A kb_bare rb_bare (fromNumber 1) (fromNumber 1)))
  ((→ A B)
   (→ B C)
   A
   B))

;; NEXT: fix the following tests

;; Two iterations of one step forward chainer
;; !(assertEqualToResult
  !(ic_bare_collapse A kb_bare rb_bare (fromNumber 1) (fromNumber 2))
  ;; (kb_bare
  ;;  (lambda0 (superpose (A B)))
  ;;  (lambda0 (superpose (A B)))
  ;;  (lambda0 (superpose (A B)))))

;; Two iterations of one step forward chainer (apply result)
;; !(assertEqualToResult
  !((ic_bare_collapse A kb_bare rb_bare (fromNumber 1) (fromNumber 2)))
  ;; ((→ A B)
  ;;  (→ B C)
  ;;  A
  ;;  A
  ;;  B
  ;;  A
  ;;  B
  ;;  A
  ;;  B)

;; ;;;;;;;;;;;;;;;;;;;;;;;
;; ;; Forward Revertant ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;

;; ;; Knowledge base
;; !(bind! &kb (new-space))
;; !(add-atom &kb (: ab (→ A B)))
;; !(add-atom &kb (: bc (→ B C)))
;; !(add-atom &kb (: a A))

;; ;; Rule base
;; !(bind! &rb (new-space))
;; !(add-atom &rb (: ModusPonens (->
;;                                ;; Premises
;;                                (→ $p $q)
;;                                $p
;;                                ;; Conclusion
;;                                $q)))
;; !(add-atom &rb (: Deduction (->
;;                              ;; Premises
;;                              (→ $p $q)
;;                              (→ $q $r)
;;                              ;; Conclusion
;;                              (→ $p $r))))
