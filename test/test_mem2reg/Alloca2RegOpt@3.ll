; Filename: multi_vars.ll


define i32 @calculate(i32 %input) {

;CHECK: entry:
;CHECK-NOT: load
;CHECK-NOT: alloca
;CHECK-NOT: store

entry:
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %c = alloca i32, align 4
  store i32 %input, i32* %a
  %1 = load i32, i32* %a
  %mult = mul i32 %1, 2
  store i32 %mult, i32* %b
  %2 = load i32, i32* %b
  %add = add i32 %2, 10
  store i32 %add, i32* %c
  %3 = load i32, i32* %c
  ret i32 %3
}
