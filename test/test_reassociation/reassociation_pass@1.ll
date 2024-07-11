; x + y + y + y + y = 4 * y + x

define i32 @testAdd(i32 %x, i32 %y){
; CHECK-LABEL: @testAdd(
; CHECK-NEXT: %[[VAR:[a-zA-Z_.][a-zA-Z0-9_.]*]] = mul i32 %y, 4
; CHECK-NEXT: %[[NUM:[1-9]]] = add i32 %[[VAR]], %x
; CHECK-NEXT: ret i32 %[[NUM]]
%1 = add i32 %x, %y
%2 = add i32 %1, %y
%3 = add i32 %2, %y
%4 = add i32 %3, %y
ret i32 %4
}