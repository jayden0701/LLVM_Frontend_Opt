; Write your own check here.
; Feel free to add arguments to @f, so its signature becomes @f(i32 %x, ...).
; But, this file should contain one function @f() only.
; FileCheck syntax: https://llvm.org/docs/CommandGuide/FileCheck.html

define i32 @fMathmeticallyTrivial(i32 %a, i32 %b, i1 %cond) {
; CHECK-LABEL: define i32 @fMathmeticallyTrivial(
; CHECK: entry:
; CHECK-NEXT: br i1 %cond, label %bb_eq, label %bb_ne
; CHECK: bb_eq:
; CHECK-NEXT: [[COND1:%.*]] = icmp eq i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT: br i1 [[COND1]], label %triv, label %nochange
; CHECK: bb_ne:
; CHECK-NEXT: [[COND2:%.*]] = icmp ne i32 [[A]], [[B]]
; CHECK-NEXT: br i1 [[COND2]], label %nochange, label %triv
; CHECK: triv:
; CHECK-NEXT: %bUse1 = sub i32 9, [[A]]
; CHECK-NEXT: ret i32 [[A]]
; CHECK: nochange:
; CHECK-NEXT: %bUse2 = sub i32 10, [[B]]
; CHECK-NEXT: ret i32 [[B]]

  entry:
  br i1 %cond, label %bb_eq, label %bb_ne

  bb_eq:
  %cond1 = icmp eq i32 %b, %a
  br i1 %cond1, label %triv, label %nochange

  bb_ne:
  %cond2 = icmp ne i32 %a, %b
  br i1 %cond2, label %nochange, label %triv

  triv:
  %bUse1 = sub i32 9, %b
  ret i32 %b

  nochange:
  %bUse2 = sub i32 10, %b
  ret i32 %b
}