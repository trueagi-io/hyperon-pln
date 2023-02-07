;; Disable importing if then else conditional as it is a built-in
;; !(import! &self IfThenElse.metta)

;; Test if
!("============ Test if ============")
!(if True A B)
!(if False A B)
