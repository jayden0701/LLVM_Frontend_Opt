define i32 @factorial(i32 %n) {
entry:
  %cmp = icmp eq i32 %n, 0
  br i1 %cmp, label %return, label %recurse

recurse:
  %n.dec = sub i32 %n, 1
  %call = call i32 @factorial(i32 %n.dec)   ; Recursive call
  %result = mul i32 %n, %call
  br label %return

return:
  %ret = phi i32 [ 1, %entry ], [ %result, %recurse ]
  ret i32 %ret
}

; CHECK-LABEL: @factorial(
; CHECK: entry:
; CHECK-NEXT: %cmp = icmp eq i32 %n, 0
; CHECK-NEXT: br i1 %cmp, label %return, label %recurse
; CHECK: recurse:
; CHECK: %n.dec = sub i32 %n, 1
; CHECK: %call = tail call i32 @factorial{{.*}}(i32 %n.dec)
; CHECK-NEXT: %result = mul i32 %n, %call
; CHECK-NEXT: br label %return
; CHECK: return:
; CHECK: %ret = phi i32 [ 1, %entry ], [ %result, %recurse ]
; CHECK-NEXT: ret i32 %ret
