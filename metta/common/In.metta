;; Import modules
!(import! &self Set.metta)

;; Type representing whether an element is or not in a set
(: ∈ (-> $a (Set $a) Type))
(: ∉ (-> $a (Set $a) Type))

;; Constructors for ∉
(: nothing-in-empty-axiom (-> Atom))
(= (nothing-in-empty-axion) (: NothingInEmpty (∉ $x ∅)))
