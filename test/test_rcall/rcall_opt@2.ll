define i32 @fibonacci(i32 %n) {
entry:
  %cmp = icmp ult i32 %n, 2
  br i1 %cmp, label %return, label %recurse

recurse:
  %n_minus_1 = sub i32 %n, 1
  %n_minus_2 = sub i32 %n, 2
  %fib_n_minus_1 = call i32 @fibonacci(i32 %n_minus_1)
  %fib_n_minus_2 = call i32 @fibonacci(i32 %n_minus_2)
  %result = add i32 %fib_n_minus_1, %fib_n_minus_2
  br label %return

return:
  %ret = phi i32 [ %n, %entry ], [ %result, %recurse ]
  ret i32 %ret
}

; CHECK-LABEL: @fibonacci(
; CHECK: entry:
; CHECK-NEXT: %cmp = icmp ult i32 %n, 2
; CHECK-NEXT: br i1 %cmp, label %return, label %recurse
; CHECK: recurse:
; CHECK: %n_minus_1 = sub i32 %n, 1
; CHECK: %n_minus_2 = sub i32 %n, 2
; CHECK: %fib_n_minus_1 = tail call i32 @fibonacci(i32 %n_minus_1)
; CHECK: %fib_n_minus_2 = tail call i32 @fibonacci(i32 %n_minus_2)
; CHECK-NEXT: %result = add i32 %fib_n_minus_1, %fib_n_minus_2
; CHECK-NEXT: br label %return
; CHECK: return:
; CHECK: %ret = phi i32 [ %n, %entry ], [ %result, %recurse ]
; CHECK-NEXT: ret i32 %ret
