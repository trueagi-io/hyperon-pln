;; Import modules
!(import! "Set.metta")

;; Type representing whether an element is in (or not) a set
(: ∈ (-> $a (Set $a) Type))
(: ∉ (-> $a (Set $a) Type))
