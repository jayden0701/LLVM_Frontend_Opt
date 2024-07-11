; test constant/variable propagation

define i32 @testProp(i32 %x, i32 %y){
; CHECK-LABEL: define i32 @testProp(
; CHECK: entry:
; CHECK-NEXT: [[A:%.*]] = add i32 %x, %y
; CHECK-NEXT: [[B:%.*]] = add i32 [[A]], %y
; CHECK-NEXT: [[C:%.*]] = add i32 [[B]], [[B]]
; CHECK-NEXT: ret i32 [[C]]
entry:
%1 = add i32 %x, %y
%same = add i32 %1, 0
%2 = add i32 %same, %y
%3 = add i32 %y, %same
%4 = add i32 %2, %3
ret i32 %4
}