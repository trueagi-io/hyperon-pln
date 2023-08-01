;; Import modules
!(import! &self BelieveMe.metta)

;; Proof type encoding that the appended element is less than the head
;; of the set.  No constructors defined yet.  In the mean time one can
;; use `believe_me` instead.
;;
;; NEXT: we have 2 options:
;;
;;       1. Ignore ElemLTHeadPrf, or even remove it from Prepend.  In
;;       that case we would only rely on insert to be correct.  If so,
;;       we may provide a proof that it is.
;;
;;       2. Do not ignore ElemLTHeadPrf.  In this case we do not need
;;       to prove that insert is correct.
;;
;;       Either way, it's likely that Singleton can be removed.  If we
;;       go with 1, which seems likely, then Singleton can definitely
;;       be removed.
(: ElemLTHeadPrf Type)

;; Definition of a set data structure.  Under the hood it is a sorted
;; list without duplicates.  In order to guaranty that it is sorted
;; without duplicates, the constructor Prepend takes an additional
;; argument encoding a proof that the element to prepend is less than
;; the head of the set to be prepended to.
(: OrderedSet (-> $a Type))
(: ∅ (OrderedSet $a))
(: Singleton (-> $a (OrderedSet $a)))   ; TODO: could probably avoid
                                        ; that if ElemLTHeadPrf
                                        ; includes the empty set.
;; Maybe rename Prepend to SCons, OSCons or ::
(: Prepend (-> $a (OrderedSet $a) ElemLTHeadPrf (OrderedSet $a)))

;; Check if an element is in a set.  TODO: optimize using the fact
;; that it is an ordered set.
(: elem (-> $a (OrderedSet $a) Bool))
(= (elem $x ∅) False)
(= (elem $x (Singleton $y)) (== $x $y))
(= (elem $x (Prepend $head $tail $prf))
   (if (== $x $head) True (elem $x $tail)))

;; Insert an element into a set.  Only insert if the element is not
;; already in the set as to produce a set, i.e. a sorted list without
;; duplicate.
(: insert (-> $a (OrderedSet $a) (OrderedSet $a)))
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
