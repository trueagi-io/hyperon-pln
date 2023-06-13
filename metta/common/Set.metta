;; Import modules
!(import! &self BelieveMe.metta)

;; Proof type encoding that the appended element is less than the head
;; of the set.  No constructors defined yet.  In the mean time one can
;; use `believe_me` instead.
(: ElemLTHeadPrf Type)

;; Definition of a set data structure.  Under the hood it is a sorted
;; list without duplicates.  In order to guaranty that, the
;; constructor Cons takes an additional argument encoding a proof that
;; the element to append is less than the head.
(: Set (-> $a Type))
(: ∅ (Set $a))
(: Singleton (-> $a (Set $a)))
(: Prepend (-> $a (Set $a) ElemLTHeadPrf (Set $a)))

;; Check if an element is in a set.  TODO: optimize using the fact
;; that it is a set.
(: elem (-> $a (Set $a) Bool))
(= (elem $x ∅) False)
(= (elem $x (Singleton $y)) (== $x $y))
(= (elem $x (Prepend $head $tail $prf))
   (if (== $x $head) True (elem $x $tail)))

;; Insert an element into a set.  Only insert if the element is not
;; already in the set as to produce a set, i.e. a sorted list without
;; duplicate.
;; TODO: Prove that `insert` preserves order and uniqueness
(: insert (-> $a (Set $a) (Set $a)))
(= (insert $x ∅) (Singleton $x))
(= (insert $x (Singleton $y))
   (if (== $x $y)
       (Singleton $y)
       (if (< $x $y)
           (Prepend $x (Singleton $y) (believe_me))
           (Prepend $y (Singleton $x) (believe_me)))))
(= (insert $x (Prepend $head $tail $prf))
   (if (== $x $head)
       (Prepend $head $tail $prf)
       (if (< $x $head)
           (Prepend $x (Prepend $head $tail $prf) (believe_me))
           (Prepend $head (insert $x $tail) (believe_me)))))
