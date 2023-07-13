;; Formula for the modus ponens rule

;; Import modules
!(import! &self ../truthvalue/TruthValue.metta)
!(import! &self ../Num.metta)

(= (modus-ponens-formula $ptv $pqtv)
    (let*
        (($Pc (confidence $ptv))
         ($PQc (confidence $pqtv))
         ($Ps (mode $ptv))
         ($PQs (mode $pqtv))
         ($notPQs 0.2)
         ($notPQc 1))
        (STV
            (+ (* $PQs $Ps) (* $notPQs (- 1 $Ps)))
            (min (min $PQc $notPQc) $Pc))))
