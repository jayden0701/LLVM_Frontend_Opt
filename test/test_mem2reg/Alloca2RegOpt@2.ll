; Filename: control_flow.ll
define i32 @test_cond(i1 %cond) {

;CHECK: entry:
;CHECK-NOT: alloca
entry:
  %x = alloca i32, align 4
  store i32 100, i32* %x
  br i1 %cond, label %if.then, label %if.else

;CHECK: if.then:
;CHECK-NOT: load
;CHECK-NOT: store


if.then:
  %1 = load i32, i32* %x
  %inc = add i32 %1, 1
  store i32 %inc, i32* %x
  br label %if.end

if.else:
  %2 = load i32, i32* %x
  %dec = sub i32 %2, 1
  store i32 %dec, i32* %x
  br label %if.end

if.end:
  %3 = load i32, i32* %x
  ret i32 %3
}
