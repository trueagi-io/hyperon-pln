;; Import modules
!(import! "Set.metta")

;; Type representing whether an element is or not in a set
(: ∈ (-> $a (Set $a) Type))
(: ∉ (-> $a (Set $a) Type))

;; Constructors for ∉
(: NotInEmpty (∉ $x Empty))
