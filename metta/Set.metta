;; Definition of a set data structure.  Under the hood it is a sorted
;; list without duplicates.  In order to guaranty that, the
;; constructor Cons takes an additional argument encoding a proof that
;; the element to append is less than the head.
(: Set (-> $a Type))
(: Nil (Set $a))
(: Cons (-> $a SetProof Set Set))	; NEXT

;; Proof type encoding that the appended element is less than the head
;; of the set
;; NEXT
(: SetProof Type)

;; Define conditional
(: if (-> Bool $a $a $a))
(= (if True $x $y) $x)
(= (if False $x $y) $y)

;; Check if an element is in a set.  TODO: optimize using the fact
;; that it is a set.
(: elem (-> $a (List $a) Bool))
(= (elem $x Nil) False)
(= (elem $x (Cons $head $tail)) (if (== $x $head) True (elem $x $tail)))

;; Test elem
!("============ Test elem ============")
!(elem 1 (Cons 3 (Cons 1 (Cons 2 Nil))))
!(elem 5 (Cons 3 (Cons 1 (Cons 2 Nil))))

;; Insert an element in a set.  Only insert if the element is not
;; already in the set as to produce a set, i.e. a sorted list without
;; duplicate.
;; NEXT: Prove that it preserves order and uniqueness
(: insert (-> $a (List $a) (List $a)))
(= (insert $x Nil) (Cons $x Nil))
(= (insert $x (Cons $head $tail))
   (if (== $x $head)
       (Cons $head $tail)
       (if (< $x $head)
           (Cons $x (Cons $head $tail))
           (Cons $head (insert $x $tail)))))

;; Test insert
!("============ Test insert ============")
!(insert 2 (insert 1 Nil))
!(insert 3 (insert 2 (insert 1 Nil)))
!(insert 2 (insert 3 (insert 2 (insert 1 Nil))))
