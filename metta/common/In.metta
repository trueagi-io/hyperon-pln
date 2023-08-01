;; Definitions of ∈ and ∉ types including axioms and rules

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

;; If x ∉ S, y ∉ S and x < y, then x ∉ (y ∪ S)
(= (lt-notin-recursive-left-rule)
   (: LTNotInRecursiveLeft (-> (∉ $x $S)
                               (∉ $y $S)
                               (⋖ $x $y)
                               (∉ $x (insert $y $S)))))

;; If x ∉ S, y ∉ S and x < y, then y ∉ (x ∪ S)
(= (lt-notin-recursive-right-rule)
   (: LTNotInRecursiveRight (-> (∉ $x $S)
                                (∉ $y $S)
                                (⋖ $x $y)
                                (∉ $y (insert $x $S)))))

