;; Import IfThenElse
!(import! &self "IfThenElse.metta")

;; Proof type encoding that the appended element is less than the head
;; of the set.  Such proof is a dummy axiom for now.
(: ElemLTHeadPrf Type)
(: Dum ElemLTHeadPrf)

;; Definition of a set data structure.  Under the hood it is a sorted
;; list without duplicates.  In order to guaranty that, the
;; constructor Cons takes an additional argument encoding a proof that
;; the element to append is less than the head.
(: Set (-> $a Type))
(: Empty (Set $a))
(: Singleton (-> $a (Set $a)))
(: Prepend (-> $a (Set $a) ElemLTHeadPrf (Set $a)))

;; Check if an element is in a set.  TODO: optimize using the fact
;; that it is a set.
(: elem (-> $a (Set $a) Bool))
(= (elem $x Empty) False)
(= (elem $x (Singleton $y)) (== $x $y))
(= (elem $x (Prepend $head $tail Dum))
   (if (== $x $head) True (elem $x $tail)))

;; Insert an element into a set.  Only insert if the element is not
;; already in the set as to produce a set, i.e. a sorted list without
;; duplicate.
(: insert (-> $a (Set $a) (Set $a)))
(= (insert $x Empty) (Singleton $x))
(= (insert $x (Singleton $y))
   (if (== $x $y)
       (Singleton $y)
       (if (< $x $y)
           (Prepend $x (Singleton $y) Dum)
           (Prepend $y (Singleton $x) Dum))))
(= (insert $x (Prepend $head $tail $prf))
   (if (== $x $head)
       (Prepend $head $tail $prf)
       (if (< $x $head)
           (Prepend $x (Prepend $head $tail $prf) Dum)
           (Prepend $head (insert $x $tail) Dum))))

;; TODO: Prove that `insert` preserves order and uniqueness
