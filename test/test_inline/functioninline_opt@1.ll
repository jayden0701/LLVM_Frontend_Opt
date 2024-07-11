
; CHECK-LABEL: define i32 @main()
; CHECK-NOT: call i32 @foo

define i32 @main() {
entry:
    %call = call i32 @foo(i32 10)
    ret i32 %call
}

define i32 @foo(i32 %x) {
entry:
    %add = add i32 %x, 1
    ret i32 %add
}
