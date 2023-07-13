;; Import modules
!(import! &self DeductionDTL.metta)
!(import! &self ModusPonensDTL.metta)
!(import! &self ../synthesis/Synthesize.metta)

;; The cow is big.
;; The cow needs the dog.
;; The dog sees the rabbit.
;; The rabbit chases the cow.
;; The rabbit chases the dog.
;; The rabbit is big.
;; The rabbit sees the dog.
;; If the cow chases the dog then the cow sees the rabbit.
;; If something is big then it chases the dog.
;; Question: The cow sees the rabbit?

;; Knowledge base
(: kb (-> Atom))
(= (kb) (superpose ((: cow_is_big (≞ (is cow big) (STV 0.99 0.99)))
                    (: cow_needs_dog (≞ (needs cow dog) (STV 0.99 0.99)))
                    (: dog_sees_rabbit (≞ (sees dog rabbit) (STV 0.99 0.99)))
                    (: rabbit_chases_cow (≞ (chases rabbit cow) (STV 0.99 0.99)))
                    (: rabbit_chases_dog (≞ (chases rabbit dog) (STV 0.99 0.99)))
                    (: rabbit_is_big (≞ (is rabbit big) (STV 0.99 0.99)))
                    (: rabbit_sees_dog (≞ (sees rabbit dog) (STV 0.99 0.99)))
                    (: cow_chases_dog_sees_rabbit (≞ (→ (chases cow dog) (sees cow rabbit)) (STV 0.99 0.99)))
                    (: x_is_big_chases_dog (≞ (→ (is $x big) (chases $x dog)) (STV 0.99 0.99))))))

;; Rule base
(: rb (-> Atom))
(= (rb) (superpose ((deduction-rule)
                    (modus-ponens-rule))))

! "===== Test synthesizer ===="
!(synthesize (: $proof (≞ (is cow big) (STV $s $c))) (fromNumber 0) kb rb)
!(synthesize (: $proof (≞ (chases cow dog) (STV $s $c))) (fromNumber 1) kb rb)
!(synthesize (: $proof (≞ (sees cow rabbit) (STV $s $c))) (fromNumber 2) kb rb)
