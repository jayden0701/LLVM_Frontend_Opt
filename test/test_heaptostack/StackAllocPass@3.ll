declare i8* @malloc(i64)

; Test to see if the Stack Allocation pass isn't invoked for memory alloc greater than threshold value
define i8* @test3() {
entry:
  %size = alloca i64, align 8
  store i64 4, i64* %size, align 8
  %ptr1 = call i8* @malloc(i64 4)
    ; CHECK: %[[PTR:.*]] = alloca i8, i64 4
  %ptr2 = call i8* @malloc(i64 8192)
    ; CHECK-NOT: %[[PTR:.*]] = alloca i8, i64 8192
  ret i8* %ptr2
}