define i8 @testAddSub(i8 %a, i8 %b){
; CHECK-LABEL: @testAddSub(
; CHECK-NEXT: [[W:%.*]] = call i8 @incr_i8(i8 %a)
; CHECK-NEXT: [[X:%.*]] = call i8 @incr_i8(i8 [[W]])
; CHECK-NEXT: [[Y:%.*]] = call i8 @decr_i8(i8 [[X]])
; CHECK-NEXT: [[Z:%.*]] = call i8 @decr_i8(i8 [[Y]])
; CHECK-NEXT: ret i8 [[Z]]
    %w = sub i8 %a, -1
    %x = add i8 %w, 1
    %y = add i8 %x, -1
    %z = sub i8 %y, 1
    ret i8 %z
}