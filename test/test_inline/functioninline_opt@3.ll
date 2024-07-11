; call foo in loop

define i32 @main() {
entry:
    %sum = alloca i32, align 4
    store i32 0, i32* %sum, align 4
    br label %loop

;CHECK: loop:
;CHECK-NOT: call
loop:                                             ; preds = %loop, %entry
    %i = phi i32 [ 0, %entry ], [ %inc, %loop ]
    %call = call i32 @foo(i32 %i)
    %sum1 = load i32, i32* %sum, align 4
    %add = add i32 %sum1, %call
    store i32 %add, i32* %sum, align 4
    %inc = add i32 %i, 1
    %cond = icmp slt i32 %inc, 10
    br i1 %cond, label %loop, label %exit

exit:                                              ; preds = %loop
    %result = load i32, i32* %sum, align 4
    ret i32 %result
}

define i32 @foo(i32 %x) {
entry:
    %mul = mul i32 %x, 2
    ret i32 %mul
}
