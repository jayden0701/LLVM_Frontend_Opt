define i64 @testShift(i64 %a){
; CHECK-LABEL: @testShift(
; CHECK-NEXT: [[X:%.*]] = mul i64 [[A:%.*]], 2
; CHECK-NEXT: [[Y:%.*]] = udiv i64 [[A]], 4
    %x = shl i64 %a, 1
    %y = lshr i64 %a, 2
    ret i64 %a
}