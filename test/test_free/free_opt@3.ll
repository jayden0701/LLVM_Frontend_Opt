; check free inside loop

define i32 @main() {
entry:
    %ptr1 = call i8* @malloc(i32 100)     ; malloc outside loop
    br label %loop1

loop1:                                      ; Loop 1
    %i = phi i32 [ 0, %entry ], [ %i.next, %loop1 ]
    %ptr2 = call i8* @malloc(i32 200)       ; malloc inside loop
    %i.next = add i32 %i, 1
    %cond = icmp slt i32 %i.next, 10
    br i1 %cond, label %loop1, label %loop1.end

;CHECK: loop1.end:
;CHECK-NEXT: free
loop1.end:
    call void @free(i8* %ptr2)              ; free inside loop (should not be deleted)
    br label %middle

;CHECK: middle:
;CHECK-NEXT: free
middle:
    call void @free(i8* %ptr1)              ; free outside loop, but not final(should not be deleted)
    %ptr3 = call i8* @malloc(i32 300)       ; another malloc outside loop
    br label %loop2

loop2:                                      ; Loop 2
    %j = phi i32 [ 0, %middle ], [ %j.next, %loop2 ]
    %j.next = add i32 %j, 1
    %cond2 = icmp slt i32 %j.next, 5
    br i1 %cond2, label %loop2, label %loop2.end

;CHECK: loop2.end:
;CHECK-NEXT: ret
loop2.end:
    call void @free(i8* %ptr3)              ; free outside loop (should be deleted)
    ret i32 0
}

declare i8* @malloc(i32)
declare void @free(i8*)
