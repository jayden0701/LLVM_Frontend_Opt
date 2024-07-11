; test redundant load elimination

define i32 @testLoadE(i32 %a, ptr %ptr){
; CHECK-LABEL: @testLoadE(
; CHECK:entry:
; CHECK-NEXT: [[A:%.*]] = load i32, ptr %ptr, align 4
; CHECK-NEXT: [[bet:%.*]] = sub i32 %a, 10
; CHECK-NEXT: [[CALL:%.*]] = call i32 @g(i32 [[A]], i32 [[A]])
; CHECK-NEXT: store i32 [[CALL]], ptr %ptr, align 4
; CHECK-NEXT: [[B:%.*]] = add i32 [[A]], [[CALL]]
; CHECK-NEXT: %res = add i32 [[bet]], [[B]]
; CHECK-NEXT: ret i32 %res
entry:
  %0 = load i32, ptr %ptr
  %bet = sub i32 %a, 10
  %1 = load i32, ptr %ptr
  %call = call i32 @g(i32 %0, i32 %1)
  store i32 %call, ptr %ptr
  %2 = load i32, ptr %ptr
  %4 = add i32 %1, %2
  %res = add i32 %bet, %4
  ret i32 %res
}

declare i32 @g(i32, i32)