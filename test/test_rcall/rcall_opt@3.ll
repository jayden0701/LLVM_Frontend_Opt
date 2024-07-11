define i32 @test_function(i32 %input) {
entry:
  %cmp = icmp ult i32 %input, 5
  br i1 %cmp, label %return, label %recurse

recurse:
  %input_minus_1 = sub i32 %input, 1
  %input_minus_2 = sub i32 %input, 2
  %result = add i32 %input_minus_1, %input_minus_2
  br label %return

return:
  %ret = phi i32 [ %input, %entry ], [ %result, %recurse ]
  ret i32 %ret
}

; CHECK-LABEL: @test_function(
; CHECK: entry:
; CHECK-NEXT: %cmp = icmp ult i32 %input, 5
; CHECK-NEXT: br i1 %cmp, label %return, label %recurse
; CHECK: recurse:
; CHECK: %input_minus_1 = sub i32 %input, 1
; CHECK: %input_minus_2 = sub i32 %input, 2
; CHECK: %result = add i32 %input_minus_1, %input_minus_2
; CHECK-NEXT: br label %return
; CHECK: return:
; CHECK: %ret = phi i32 [ %input, %entry ], [ %result, %recurse ]
; CHECK-NEXT: ret i32 %ret
