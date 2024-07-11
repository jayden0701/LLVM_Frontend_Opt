; test CSE in a BasicBlock and across BasicBlocks

define i32 @testCSE(i32 %x, i32 %y){
; CHECK-LABEL: @testCSE(
; CHECK: entry:
; CHECK-NEXT: %cond = icmp eq i32 %x, %y
; CHECK-NEXT: [[A:%.*]] = add i32 %x, %y
; CHECK-NEXT: br i1 %cond, label %if.true, label %if.false
; CHECK: if.true:
; CHECK-NEXT: br label %end
; CHECK: if.false:
; CHECK-NEXT: br label %end
; CHECK: end:
; CHECK-NEXT: ret i32 [[A]]

entry:
%cond = icmp eq i32 %x, %y
br i1 %cond, label %if.true, label %if.false

if.true:
%a = add i32 %x, %y
%a_1 = add i32 %x, %y
br label %end

if.false:
%a_2 = add i32 %x, %y
br label %end

end:
%z = phi i32 [ %a_1, %if.true ], [ %a_2, %if.false ]
ret i32 %z
}