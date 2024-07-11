; ModuleID = 'test/test_loop_unroll_full/loop_unroll_full_opt@4.c'
source_filename = "test/test_loop_unroll_full/loop_unroll_full_opt@4.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
  ; CHECK-LABEL: define dso_local i32 @main() #0 {
; CHECK: entry:
; CHECK-NEXT:   %call = call i64 (...) @read()
; CHECK-NEXT:   %conv = trunc i64 %call to i32
; CHECK-NEXT:   %smax = call i32 @llvm.smax.i32(i32 %conv, i32 0)
; CHECK-NEXT:   %wide.trip.count = zext i32 %smax to i64
; CHECK-NEXT:   br label %for.cond

; CHECK: for.cond:                                         ; preds = %for.body.3, %entry
; CHECK-NEXT:   %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next.3, %for.body.3 ]
; CHECK-NEXT:   %exitcond = icmp ne i64 %indvars.iv, %wide.trip.count
; CHECK-NEXT:   br i1 %exitcond, label %for.body, label %for.end

; CHECK: for.body:                                         ; preds = %for.cond
; CHECK-NEXT:   call void @write(i64 noundef %indvars.iv)
; CHECK-NEXT:   %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
; CHECK-NEXT:   %exitcond.1 = icmp ne i64 %indvars.iv.next, %wide.trip.count
; CHECK-NEXT:   br i1 %exitcond.1, label %for.body.1, label %for.end

; CHECK: for.body.1:                                       ; preds = %for.body
; CHECK-NEXT:   call void @write(i64 noundef %indvars.iv.next)
; CHECK-NEXT:   %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv, 2
; CHECK-NEXT:   %exitcond.2 = icmp ne i64 %indvars.iv.next.1, %wide.trip.count
; CHECK-NEXT:   br i1 %exitcond.2, label %for.body.2, label %for.end

; CHECK: for.body.2:                                       ; preds = %for.body.1
; CHECK-NEXT:   call void @write(i64 noundef %indvars.iv.next.1)
; CHECK-NEXT:   %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv, 3
; CHECK-NEXT:   %exitcond.3 = icmp ne i64 %indvars.iv.next.2, %wide.trip.count
; CHECK-NEXT:   br i1 %exitcond.3, label %for.body.3, label %for.end

; CHECK: for.body.3:                                       ; preds = %for.body.2
; CHECK-NEXT:   call void @write(i64 noundef %indvars.iv.next.2)
; CHECK-NEXT:   %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv, 4
; CHECK-NEXT:   br label %for.cond, !llvm.loop !5

; CHECK: for.end:                                          ; preds = %for.cond, %for.body, %for.body.1, %for.body.2
; CHECK-NEXT:   ret i32 0
; CHECK-NEXT: }
entry:
  %retval = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, ptr %retval, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %n) #3
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  store i32 %conv, ptr %n, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %i) #3
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4
  %1 = load i32, ptr %n, align 4
  %cmp = icmp slt i32 %0, %1
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  call void @llvm.lifetime.end.p0(i64 4, ptr %i) #3
  br label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i32, ptr %i, align 4
  %conv2 = sext i32 %2 to i64
  call void @write(i64 noundef %conv2)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %3 = load i32, ptr %i, align 4
  %inc = add nsw i32 %3, 1
  store i32 %inc, ptr %i, align 4
  br label %for.cond, !llvm.loop !5

for.end:                                          ; preds = %for.cond.cleanup
  call void @llvm.lifetime.end.p0(i64 4, ptr %n) #3
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
