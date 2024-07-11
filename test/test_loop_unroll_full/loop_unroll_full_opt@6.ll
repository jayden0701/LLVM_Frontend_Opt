; ModuleID = 'test/test_loop_unroll_full/loop_unroll_full_opt@6.c'
source_filename = "test/test_loop_unroll_full/loop_unroll_full_opt@6.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
  ; CHECK-LABEL: define dso_local i32 @main() #0 {
; CHECK: entry:
; CHECK-NEXT:   %call = call i64 (...) @read()
; CHECK-NEXT:   br label %while.cond

; CHECK: while.cond:                                       ; preds = %while.body.3, %entry
; CHECK-NEXT:   %i.0 = phi i64 [ %call, %entry ], [ %dec.3, %while.body.3 ]
; CHECK-NEXT:   %dec = add nsw i64 %i.0, -1
; CHECK-NEXT:   %cmp = icmp sgt i64 %i.0, 0
; CHECK-NEXT:   br i1 %cmp, label %while.body, label %while.end

; CHECK: while.body:                                       ; preds = %while.cond
; CHECK-NEXT:   call void @write(i64 noundef %dec)
; CHECK-NEXT:   %dec.1 = add nsw i64 %i.0, -2
; CHECK-NEXT:   %cmp.1 = icmp sgt i64 %dec, 0
; CHECK-NEXT:   br i1 %cmp.1, label %while.body.1, label %while.end

; CHECK: while.body.1:                                     ; preds = %while.body
; CHECK-NEXT:   call void @write(i64 noundef %dec.1)
; CHECK-NEXT:   %dec.2 = add nsw i64 %i.0, -3
; CHECK-NEXT:   %cmp.2 = icmp sgt i64 %dec.1, 0
; CHECK-NEXT:   br i1 %cmp.2, label %while.body.2, label %while.end

; CHECK: while.body.2:                                     ; preds = %while.body.1
; CHECK-NEXT:   call void @write(i64 noundef %dec.2)
; CHECK-NEXT:   %dec.3 = add nsw i64 %i.0, -4
; CHECK-NEXT:   %cmp.3 = icmp sgt i64 %dec.2, 0
; CHECK-NEXT:   br i1 %cmp.3, label %while.body.3, label %while.end

; CHECK: while.body.3:                                     ; preds = %while.body.2
; CHECK-NEXT:   call void @write(i64 noundef %dec.3)
; CHECK-NEXT:   br label %while.cond, !llvm.loop !5

; CHECK: while.end:                                        ; preds = %while.body.2, %while.body.1, %while.body, %while.cond
; CHECK-NEXT:   ret i32 0
; CHECK-NEXT: }
entry:
  %retval = alloca i32, align 4
  %i = alloca i64, align 8
  store i32 0, ptr %retval, align 4
  call void @llvm.lifetime.start.p0(i64 8, ptr %i) #3
  %call = call i64 (...) @read()
  store i64 %call, ptr %i, align 8
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %0 = load i64, ptr %i, align 8
  %dec = add nsw i64 %0, -1
  store i64 %dec, ptr %i, align 8
  %cmp = icmp sgt i64 %0, 0
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %1 = load i64, ptr %i, align 8
  call void @write(i64 noundef %1)
  br label %while.cond, !llvm.loop !5

while.end:                                        ; preds = %while.cond
  call void @llvm.lifetime.end.p0(i64 8, ptr %i) #3
  ret i32 0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare i64 @read(...) #2

declare void @write(i64 noundef) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

attributes #0 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"clang version 18.1.0rc (https://github.com/llvm/llvm-project.git 461274b81d8641eab64d494accddc81d7db8a09e)"}
!5 = distinct !{!5, !6, !7}
!6 = !{!"llvm.loop.mustprogress"}
!7 = !{!"llvm.loop.unroll.disable"}
