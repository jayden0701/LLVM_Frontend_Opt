; (3 + x) + 5 = x + (3 + 5) 등등
; instruction의 순서는 다소 바뀔 수 있다

define i32 @testConst(i32 %x){
; CHECK-LABEL: @testConst(
; CHECK-LABEL: entry:
; CHECK: mul i32 %[[VAR2:[a-zA-Z_.][a-zA-Z0-9_.]*]], 15
; CHECK: and i32 %[[VAR3:[a-zA-Z_.][a-zA-Z0-9_.]*]], 2
; CHECK: or i32 %[[VAR4:[a-zA-Z_.][a-zA-Z0-9_.]*]], 3
; CHECK: xor i32 %[[VAR5:[a-zA-Z_.][a-zA-Z0-9_.]*]], 3
; CHECK: add i32 %[[VAR1:[a-zA-Z_.][a-zA-Z0-9_.]*]], 8
entry: 
%1 = add i32 %x, 3
%2 = add i32 5, %1
%3 = mul i32 %x, 3
%4 = mul i32 5, %3
%5 = and i32 %x, 10
%6 = and i32 2, %5
%7 = or i32 %x, 1
%8 = or i32 2, %7
%9 = xor i32 %x, 1
%10 = xor i32 2, %9

%z.0 = add i32 %2, %4
%z.1 = mul i32 %6, %8
%z.2 = and i32 %z.0, %10
%z.3 = xor i32 %z.1, %z.2
ret i32 %z.3
}