;; Given a function call, produce records of that function call.
;; There can be multiple records with only one call due to the
;; non-determinism of MeTTa.  Each record is represented by (⊷ f x y)
;; which can be read as
;;
;; "under f, the image of x is y"
;;
;; ⊷ was chosen because it is described as IMAGE OF in UTF-8.  It is
;; the MeTTa equivalent of ExecutionLink in Atomese.
(= (record $f ($arg)) (⊷ $f $arg ($f $arg)))
(= (record $f ($arg1 $arg2)) (⊷ $f ($arg1 $arg2) ($f $arg1 $arg2)))
(= (record $f ($arg1 $arg2 $arg3)) (⊷ $f ($arg1 $arg2 $arg3) ($f $arg1 $arg2 $arg3)))
(= (record $f ($arg1 $arg2 $arg3 $arg4)) (⊷ $f ($arg1 $arg2 $arg3 $arg4) ($f $arg1 $arg2 $arg3 $arg4)))
