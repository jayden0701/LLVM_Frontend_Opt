; Write your own check here.
; Feel free to add arguments to @f, so its signature becomes @f(i32 %x, ...).
; But, this file should contain one function @f() only.
; FileCheck syntax: https://llvm.org/docs/CommandGuide/FileCheck.html

define i32 @fEqNeTest(i32 %a, i32 %b, i32 %c) {
; CHECK-LABEL: define i32 @fEqNeTest(
; CHECK: entry:
; CHECK-NEXT: [[COND1:%.*]] = icmp eq i32 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT: [[COND2:%.*]] = icmp ne i32 [[A]], [[C:%.*]]
; CHECK-NEXT: br i1 [[COND1]], label %bb_1, label %end
; CHECK: bb_1:
; CHECK-NEXT: call void @g(i32 [[A]], i32 [[A]])
; CHECK-NEXT: br i1 [[COND2]], label %end, label %bb_2
; CHECK: bb_2:
; CHECK-NEXT: call void @g(i32 [[A]], i32 [[A]])
; CHECK-NEXT: br label %end
; CHECK: end:
; CHECK-NEXT: [[RES:%.*]] = phi i32 [ [[B]], %entry ], [ [[A]], %bb_1 ], [ [[A]], %bb_2 ]
; CHECK-NEXT: ret i32 [[RES]]
;
  entry:
  %cond1 = icmp eq i32 %a, %b
  %cond2 = icmp ne i32 %a, %c
  br i1 %cond1, label %bb_1, label %end

  bb_1:
    call void @g(i32 %a, i32 %b)
    br i1 %cond2, label %end, label %bb_2

  bb_2:
    call void @g(i32 %b, i32 %c)
    br label %end

  end:
  %res = phi i32 [ %b, %entry ], [ %b, %bb_1 ], [ %c, %bb_2 ]
  ret i32 %res
}

declare void @g(i32, i32)