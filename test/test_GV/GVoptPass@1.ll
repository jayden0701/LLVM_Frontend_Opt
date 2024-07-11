; basic loop with a call to an external function

@global_var = global i32 42, align 4

define void @test_function() {
entry:
  br label %loop

;CHECK: loop:
;CHECK-NEXT: call
loop:
  %val = load i32, i32* @global_var
  call void @consume(i32 %val)
  br i1 true, label %loop, label %exit

exit:
  ret void
}

declare void @consume(i32)
