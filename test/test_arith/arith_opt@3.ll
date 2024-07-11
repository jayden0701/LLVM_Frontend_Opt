define i32 @allTest(i32 %a, i1 %b){
    ; CHECK-LABEL: @allTest(
    ; CHECK-NEXT: [[a:%.*]] = mul i32 [[A:%.*]], 4
    ; CHECK-NEXT: [[b:%.*]] = udiv i32 [[a]], 2
    ; CHECK-NEXT: %t = icmp eq i32 [[A]], [[b]]
    ; CHECK-NEXT: [[d:%.*]] = mul i1 %t, %b
    ; CHECK-NEXT: [[e:%.*]] = select i1 [[d]], i1 true, i1 false
    ; CHECK-NEXT: [[f:%.*]] = icmp ne i1 [[e]], false
    ; CHECK-NEXT: [[g:%.*]] = urem i32 %a, 32
    ; CHECK-NEXT: ret i32 [[b]]
    %x = shl i32 %a, 2
    %y = lshr i32 %x, 1
    %t = icmp eq i32 %a, %y
    %k = and i1 %t, %b
    %k.1 = or i1 %k, 0
    %k.2 = xor i1 %k.1, 0
    %k.3 = and i32 %a, 31
    ret i32 %y
}