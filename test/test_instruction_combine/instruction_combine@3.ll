; ModuleID = 'example'
source_filename = "example.c"

define i32 @main() {
; CHECK-LABEL: define i32 @main() {
; CHECK-NEXT: entry:
; CHECK-NEXT:   ret i32 100
; CHECK-NEXT:   }
entry:
  %a = add i32 10, 20
  %b = icmp sgt i32 %a, 25
  %c = select i1 %b, i32 100, i32 50
  ret i32 %c
}
