; Write your own check here.
; Feel free to add arguments to @f, so its signature becomes @f(i32 %x, ...).
; But, this file should contain one function @f() only.
; FileCheck syntax: https://llvm.org/docs/CommandGuide/FileCheck.html

define i32 @fConstPropagation(i32 %a, i32 %b, i1 %cond) {
; CHECK-LABEL: define i32 @fConstPropagation(
; CHECK: eq:
; CHECK-NEXT: %condne = icmp ne i32 0, [[B:%.*]]
; CHECK: ne:
; CHECK-NEXT: %bUse = sub i32 8, 0
; CHECK: triv:
; CHECK-NEXT: %bUse1 = sub i32 9, 1
; CHECK-NEXT: ret i32 1
; CHECK: nochange:
; CHECK-NEXT: %bUse2 = sub i32 10, [[B]]
; CHECK-NEXT: ret i32 [[B]]
  entry:
  %condeq = icmp eq i32 %a, 0
  br i1 %condeq, label %eq, label %middle

  eq:
  %condne = icmp ne i32 %a, %b
  br i1 %condne, label %middle, label %ne

  ne:
  %bUse = sub i32 8, %b
  br label %middle

  middle:
  br i1 %cond, label %bb_eq, label %bb_ne

  bb_eq:
  %cond1 = icmp eq i32 %b, 1
  br i1 %cond1, label %triv, label %nochange

  bb_ne:
  %cond2 = icmp ne i32 1, %b
  br i1 %cond2, label %nochange, label %triv

  triv:
  %bUse1 = sub i32 9, %b
  ret i32 %b

  nochange:
  %bUse2 = sub i32 10, %b
  ret i32 %b
}