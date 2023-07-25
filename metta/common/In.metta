;; Import modules
!(import! &self OrderedSet.metta)

;; Type representing whether an element is or not in a set
(: ∈ (-> $a (OrderedSet $a) Type))
(: ∉ (-> $a (OrderedSet $a) Type))

;; Constructors for ∉

;; Nothing is in an empty set
(: notin-empty-axiom (-> Atom))
(= (notin-empty-axiom)
   (: NotInEmpty (∉ $x ∅)))

;; If x < y, then x ∉ {y}
(: lt-notin-singleton-rule (-> Atom))
(= (lt-notin-singleton-rule)
   (: LTNotInSingleton (-> (⋖ $x $y)
                           (∉ $x (Singleton $y)))))

;; If x < y, then x ∉ {y, ...}, because OrderedSet is ordered.
(= (lt-notin-prepend-rule)
   (: LTNotInPrepend (-> (⋖ $x $y)
                         (∉ $x (Prepend $y $s $p)))))

;; If x ∉ S, y ∉ S and x < y, then x ∉ (y ∪ S)
(= (lt-notin-recursive-1-rule)
   (: LTNotInRecursive1 (-> (∉ $x $S)
                            (∉ $y $S)
                            (⋖ $x $y)
                            (∉ $x (insert $y $S)))))

;; If x ∉ S, y ∉ S and x < y, then y ∉ (x ∪ S)
(= (lt-notin-recursive-2-rule)
   (: LTNotInRecursive2 (-> (∉ $x $S)
                            (∉ $y $S)
                            (⋖ $x $y)
                            (∉ $y (insert $x $S)))))

