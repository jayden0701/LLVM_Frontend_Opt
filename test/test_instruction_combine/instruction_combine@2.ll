; ModuleID = 'example'
source_filename = "example.c"

define i32 @main() {
; CHECK-LABEL: define i32 @main() {
; CHECK-NEXT: entry:
; CHECK-NEXT:   ret i32 44
; CHECK-NEXT:   }
entry:
  %a = mul i32 6, 7
  %b = add i32 %a, 5
  %c = sub i32 %b, 3
  ret i32 %c
}
