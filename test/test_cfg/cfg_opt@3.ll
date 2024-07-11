; if there is store, do not merge to Pred
define i64 @test3(i64 %a, i64 %b, ptr %p){
; CHECK-LABEL: @test3(
; CHECK-LABEL: entry:
; CHECK-NEXT: %cond = icmp eq i64 %a, %b
; CHECK-NEXT: %y = shl i64 %b, 2
; CHECK-NEXT: br i1 %cond, label %if.true, label %end

; CHECK-LABEL: if.true:
; CHECK-NEXT: store i64 42, ptr %p
; CHECK-NEXT: br label %end

; CHECK-LABEL: end:
; CHECK-NEXT: %z = phi i64 [ %a, %if.true ], [ %y, %entry ]
; CHECK-NEXT: ret i64 %z
    entry:
    %cond = icmp eq i64 %a, %b
    br i1 %cond, label %if.true, label %if.false

    if.true:
    store i64 42, ptr %p
    br label %end

    if.false:
    %y = shl i64 %b, 2
    br label %end

    end:
    %z = phi i64 [ %a, %if.true ], [ %y, %if.false ]
    ret i64 %z
}