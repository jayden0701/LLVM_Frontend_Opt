declare ptr @malloc(i64)
declare void @free(ptr)

; Test for recursion detection
define void @recursive_function(i32 %n) {
entry:
  %cond = icmp sgt i32 %n, 0
  br i1 %cond, label %recurse, label %exit

recurse:
  %ptr = call ptr @malloc(i64 16)
  ; CHECK: call ptr @malloc(i64 16)
  store i8 42, ptr %ptr, align 1
  %n1 = sub i32 %n, 1
  call void @recursive_function(i32 %n1)
  call void @free(ptr %ptr)
  br label %exit

exit:
  ret void
}