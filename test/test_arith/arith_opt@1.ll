define i1 @testBitwise(i1 %a, i1 %b){
; CHECK-LABEL: @testBitwise(
; CHECK-NEXT: [[X:%.*]] = mul i1 [[A:%.*]], [[B:%.*]]
; CHECK-NEXT: [[Y:%.*]] = select i1 [[A]], i1 true, i1 [[B]]
; CHECK-NEXT: [[Z:%.*]] = icmp ne i1 [[A]], [[B]]
    %x = and i1 %a, %b
    %y = or i1 %a, %b
    %z = xor i1 %a, %b
    ret i1 %a
}