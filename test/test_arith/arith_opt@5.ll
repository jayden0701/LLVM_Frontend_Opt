; add를 제외하고는 나머지는 모두 특정 상수값이 됨

define i8 @testSameOperand(i8 %a, i8 %b){
; CHECK-LABEL: @testSameOperand(
; CHECK-NEXT: [[W:%.*]] = mul i8 %a, 2
; CHECK-NEXT: ret i8 1
    %1 = add i8 %a, %a
    %2 = sub i8 %a, %a
    %3 = and i8 %a, %a
    %4 = or i8 %a, %a
    %5 = xor i8 %a, %a
    %6 = urem i8 %a, %a
    %7 = udiv i8 %a, %a
    %8 = icmp eq i8 %a, %a
    ret i8 %7
}