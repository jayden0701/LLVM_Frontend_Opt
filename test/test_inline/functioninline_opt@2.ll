; do not inline recursive functions(they are cheap + can cause infinite loop)


;CHECK: entry:
;CHECK-NEXT: call
define i32 @main() {
entry:
    %call = call i32 @factorial(i32 5)
    ret i32 %call
}

define i32 @factorial(i32 %n) {
entry:
    %cmp = icmp eq i32 %n, 0
    br i1 %cmp, label %base_case, label %recurse

base_case:                                         ; preds = %entry
    ret i32 1

recurse:                                           ; preds = %entry
    %dec = sub i32 %n, 1
    %call = call i32 @factorial(i32 %dec)
    %mul = mul i32 %n, %call
    ret i32 %mul
}
