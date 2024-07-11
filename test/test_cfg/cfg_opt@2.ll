; ternary test
define i64 @test2(i64 %a, i64 %b){
; CHECK-LABEL: @test2(
; CHECK-LABEL: entry:
; CHECK-NEXT: %cond = icmp eq i64 %a, %b
; CHECK-NEXT: %x = lshr i64 %a, 1
; CHECK-NEXT: %y = shl i64 %b, 2
; CHECK-NEXT: %z = select i1 %cond, i64 %x, i64 %y
; CHECK-NEXT: ret i64 %z
    entry:
    %cond = icmp eq i64 %a, %b
    br i1 %cond, label %if.true, label %if.false

    if.true:
    %x = lshr i64 %a, 1
    br label %end

    if.false:
    %y = shl i64 %b, 2
    br label %end

    end:
    %z = phi i64 [%x, %if.true], [%y, %if.false]
    ret i64 %z
}