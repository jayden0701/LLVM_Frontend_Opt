declare i8* @malloc(i64)
declare void @free(i8*)

define void @test_free_removal() {
entry:
  %ptr = call i8* @malloc(i64 16)
  call void @free(i8* %ptr)
  ret void
}

; CHECK-LABEL: @test_free_removal
; CHECK-NOT: call void @free(i8*)