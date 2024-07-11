; x*x + x*y + 3*x = (x + 3 + y)*x

define i32 @testAssociate(i32 %x, i32 %y){
; CHECK-LABEL: @testAssociate(
; CHECK-NEXT: %[[VAR1:[a-zA-Z_.][a-zA-Z0-9_.]*]] = add i32 %x, 3
; CHECK-NEXT: %[[VAR2:[a-zA-Z_.][a-zA-Z0-9_.]*]] = add i32 %[[VAR1]], %y
; CHECK-NEXT: %[[VAR3:[a-zA-Z_.][a-zA-Z0-9_.]*]] = mul i32 %[[VAR2]], %x
; CHECK-NEXT: ret i32 %[[VAR3]]
%1 = mul i32 %x, %x
%2 = mul i32 %x, %y
%3 = mul i32 %x, 3
%4 = add i32 %1, %2
%5 = add i32 %4, %3
ret i32 %5
}