;; Definition of a List data structure with various methods for it.

;; Declaration of List data structure
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Define conditional
(= (if True $x $y) $x)
(= (if False $x $y) $y)

;; Insert an element to a presumably sorted list, remains sorted.
(= (insert $x Nil) (Cons $x Nil))
(= (insert $x (Cons $head $tail))
   (if (< $x $head)
       (Cons $x (Cons $head $tail))
       (Cons $head (insert $x $tail))))

;; Test insert
!(println! ("============ Test insert ============"))
!(println! (insert 1 Nil))
!(println! (insert 2 (insert 1 Nil)))
!(println! (insert 3 (insert 2 (insert 1 Nil))))

;; Sort a list
(= (sort Nil) Nil)
(= (sort (Cons $head $tail)) (insert $head (sort $tail)))

;; Test sort
!(println! ("============ Test sort ============"))
!(println! (sort (Cons 1 Nil)))
!(println! (sort (Cons 2 (Cons 1 Nil))))
!(println! (sort (Cons 3 (Cons 1 (Cons 2 Nil)))))

;; Check if an element is in a list (sorted or not)
(= (elem $x Nil) False)
(= (elem $x (Cons $head $tail)) (if (== $x $head) True (elem $x $tail)))

;; Test elem
!(println! ("============ Test elem ============"))
!(println! (elem 1 (Cons 3 (Cons 1 (Cons 2 Nil)))))
!(println! (elem 5 (Cons 3 (Cons 1 (Cons 2 Nil)))))

;; Remove duplicates from a list
(= (uniq_ $acc Nil) Nil)
(= (uniq_ $acc (Cons $head $tail))
   (if (elem $head $acc)
       (uniq_ $acc $tail)
       (Cons $head (uniq_ (Cons $head $acc) $tail))))
(= (uniq $l) (uniq_ Nil $l))

;; Test uniq
!(println! ("============ Test uniq ============"))
!(println! (uniq (Cons 2 (Cons 3 (Cons 1 (Cons 2 Nil))))))
!(println! (uniq (Cons 2 (Cons 3 (Cons 3 (Cons 2 Nil))))))

;; Insert an element in a presumably sorted list without duplicate.
;; Only insert if the element is not already in the list as to produce
;; a sorted list without duplicate.
(= (insert_uniq $x Nil) (Cons $x Nil))
(= (insert_uniq $x (Cons $head $tail))
   (if (== $x $head)
       (Cons $head $tail)
       (if (< $x $head)
           (Cons $x (Cons $head $tail))
           (Cons $head (insert_uniq $x $tail)))))

;; Test insert_uniq
!(println! ("============ Test insert_uniq ============"))
!(println! (== (insert_uniq 1 Nil) (Cons 1 Nil)))
!(println! (insert_uniq 2 (insert_uniq 1 Nil)))
!(println! (insert_uniq 3 (insert_uniq 2 (insert_uniq 1 Nil))))
!(println! (insert_uniq 2 (insert_uniq 3 (insert_uniq 2 (insert_uniq 1 Nil)))))
