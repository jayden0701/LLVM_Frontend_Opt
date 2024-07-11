define i32 @constant_fold() {
; CHECK-LABEL: @constant_fold(
; CHECK-NEXT:    add i32 1, 2
	%a = add i32 1, 2
  %b = sub i32 %a, 1
  ret i32 %b
}

