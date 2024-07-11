; ModuleID = 'example'
source_filename = "example.c"

define i32 @main() {
; CHECK-LABEL: define i32 @main() {
; CHECK-NEXT: entry:
; CHECK-NEXT:   ret i32 60
; CHECK-NEXT:   }
entry:
  %a = add i32 10, 20
  %b = mul i32 %a, 2
  ret i32 %b
}
