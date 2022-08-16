;; Import Set
!(import! &self "Set.metta")

;; Test elem
!("============ Test elem ============")
!(elem 1 Empty)
!(elem 1 (Singleton 1))
!(elem 1 (Singleton 2))
!(elem 1 (Prepend 1 (Singleton 2) (believe_me)))
!(elem 1 (Prepend 2 (Singleton 3) (believe_me)))
!(elem 2 (Prepend 1 (Prepend 2 (Singleton 3) (believe_me)) (believe_me)))

;; Test insert
!("============ Test insert ============")
!(insert 1 Empty)
!(insert 2 (insert 1 Empty))
!(insert 3 (insert 2 (insert 1 Empty)))
!(insert 2 (insert 3 (insert 2 (insert 1 Empty))))
