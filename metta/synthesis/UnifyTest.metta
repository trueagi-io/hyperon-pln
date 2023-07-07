!(import! &self Unify.metta)

;; Test unify.  Should output (Link A B)
!(unify (Link $x B) (Link A $y) (Link $x $y))

;; Test unify*.  Should output (Link A B C)
!(unify* (((Link $x B $z) (Link A $y $z)) ($z C)) (Link $x $y $z))
