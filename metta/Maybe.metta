;; Define Maybe type
(: Maybe (-> $a Type))
(: Nothing (Maybe $a))
(: Just (-> $a (Maybe $a)))

;; Overload some operators
(= (< (Just $x) (Just $y)) (< $x $y))
(= (< (Just $x) Nothing) False)
(= (< Nothing (Just $x)) True)

;; Test
!(< (Just 10) (Just 20))
!(< (Just 10) Nothing)
!(< Nothing (Just 10))
