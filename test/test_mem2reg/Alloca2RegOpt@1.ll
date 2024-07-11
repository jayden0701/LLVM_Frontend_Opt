; Filename: simple_arith.ll
define i32 @compute_sum() {
;CHECK-LABEL: @compute_sum
;CHECK: entry:
;CHECK-NOT: alloca
;CHECK-NOT: load
;CHECK-NOT: store

entry:
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  store i32 10, i32* %x
  store i32 20, i32* %y
  %1 = load i32, i32* %x
  %2 = load i32, i32* %y
  %sum = add i32 %1, %2
  ret i32 %sum
}
