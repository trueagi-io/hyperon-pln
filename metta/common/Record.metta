;; Given a function call, (f x), produce record(s) of that function
;; call, (≘ f x (f x)).  ≘ is the MeTTa equivalent of ExecutionLink.
(= (record $f ($arg)) (≘ $f $arg ($f $arg)))
(= (record $f ($arg1 $arg2)) (≘ $f ($arg1 $arg2) ($f $arg1 $arg2)))
(= (record $f ($arg1 $arg2 $arg3)) (≘ $f ($arg1 $arg2 $arg3) ($f $arg1 $arg2 $arg3)))
(= (record $f ($arg1 $arg2 $arg3 $arg4)) (≘ $f ($arg1 $arg2 $arg3 $arg4) ($f $arg1 $arg2 $arg3 $arg4)))
