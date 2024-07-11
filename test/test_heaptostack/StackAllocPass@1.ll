declare ptr @malloc(i64)


; Basic test to see if memory is allocated to the stack instead of the heap

define void @test_only_malloc() {
entry:
  %ptr = call ptr @malloc(i64 16)
  ; CHECK: %[[PTR:.*]] = alloca i8, i64 16
  ; CHECK-NEXT: store i8 42, ptr %[[PTR]], align 1
  store i8 42, ptr %ptr, align 1
  ret void
}