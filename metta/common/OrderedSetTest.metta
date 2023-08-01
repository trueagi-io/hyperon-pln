;; Import OrderedSet
!(import! &self OrderedSet.metta)

;; Test elem
!(assertEqual (elem 1 ∅) False)
!(assertEqual (elem 1 (Singleton 1)) True)
!(assertEqual (elem 1 (Singleton 2)) False)
!(elem 1 (Prepend 1 (Singleton 2) (believe_me)))
!(elem 1 (Prepend 2 (Singleton 3) (believe_me)))
!(elem 2 (Prepend 1 (Prepend 2 (Singleton 3) (believe_me)) (believe_me)))

;; Test insert
!(insert 1 ∅)
!(insert 2 (insert 1 ∅))
!(insert 3 (insert 2 (insert 1 ∅)))
!(insert 2 (insert 3 (insert 2 (insert 1 ∅))))
