; ModuleID = 'test_module'
source_filename = "test_module"

define i32 @main() {
entry:
  ; Allocate memory
  %ptr1 = call i8* @malloc(i64 10)
  %ptr2 = call i8* @malloc(i64 20)

  ; Use the allocated memory
  %ptr3 = bitcast i8* %ptr1 to i32*
  store i32 42, i32* %ptr3

  ; Free the memory
  call void @free(i8* %ptr1)

  br label %finish

finish:
; CHECK: finish:
; CHECK-NEXT: malloc
; CHECK-NEXT: ret
  ; Allocate more memory
  %ptr4 = call i8* @malloc(i64 30)

  ; Free the second pointer
  call void @free(i8* %ptr2)

  ; Free the last allocated memory
  call void @free(i8* %ptr4)

  ; Return from main
  ret i32 0
}

; External function declarations
declare i8* @malloc(i64)
declare void @free(i8*)
