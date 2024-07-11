; ModuleID = 'unroll_test/test3.c'
source_filename = "unroll_test/test3.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
  ; CHECK-LABEL: define dso_local i32 @main() #0 {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %call = call i64 (...) @read()
; CHECK-NEXT:   %call7 = call i64 (...) @read()
; CHECK-NEXT:   %call7.1 = call i64 (...) @read()
; CHECK-NEXT:   %call7.2 = call i64 (...) @read()
; CHECK-NEXT:   %call7.3 = call i64 (...) @read()
; CHECK-NEXT:   %call7.12 = call i64 (...) @read()
; CHECK-NEXT:   %call7.1.1 = call i64 (...) @read()
; CHECK-NEXT:   %call7.2.1 = call i64 (...) @read()
; CHECK-NEXT:   %call7.3.1 = call i64 (...) @read()
; CHECK-NEXT:   %call7.25 = call i64 (...) @read()
; CHECK-NEXT:   %call7.1.2 = call i64 (...) @read()
; CHECK-NEXT:   %call7.2.2 = call i64 (...) @read()
; CHECK-NEXT:   %call7.3.2 = call i64 (...) @read()
; CHECK-NEXT:   %call7.38 = call i64 (...) @read()
; CHECK-NEXT:   %call7.1.3 = call i64 (...) @read()
; CHECK-NEXT:   %call7.2.3 = call i64 (...) @read()
; CHECK-NEXT:   %call7.3.3 = call i64 (...) @read()
; CHECK-NEXT:   %conv = trunc i64 %call to i32
; CHECK-NEXT:   ret i32 0
; CHECK-NEXT: }
entry:
  %retval = alloca i32, align 4
  %n = alloca i32, align 4
  %i = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, ptr %retval, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %n) #3
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  store i32 %conv, ptr %n, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr %i) #3
  store i32 0, ptr %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc8, %entry
  %0 = load i32, ptr %i, align 4
  %cmp = icmp slt i32 %0, 4
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  store i32 2, ptr %cleanup.dest.slot, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr %i) #3
  br label %for.end10

for.body:                                         ; preds = %for.cond
  call void @llvm.lifetime.start.p0(i64 4, ptr %j) #3
  store i32 0, ptr %j, align 4
  br label %for.cond2

for.cond2:                                        ; preds = %for.inc, %for.body
  %1 = load i32, ptr %j, align 4
  %cmp3 = icmp slt i32 %1, 4
  br i1 %cmp3, label %for.body6, label %for.cond.cleanup5

for.cond.cleanup5:                                ; preds = %for.cond2
  store i32 5, ptr %cleanup.dest.slot, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr %j) #3
  br label %for.end

for.body6:                                        ; preds = %for.cond2
  %call7 = call i64 (...) @read()
  br label %for.inc

for.inc:                                          ; preds = %for.body6
  %2 = load i32, ptr %j, align 4
  %inc = add nsw i32 %2, 1
  store i32 %inc, ptr %j, align 4
  br label %for.cond2, !llvm.loop !5

for.end:                                          ; preds = %for.cond.cleanup5
  br label %for.inc8

for.inc8:                                         ; preds = %for.end
  %3 = load i32, ptr %i, align 4
  %inc9 = add nsw i32 %3, 1
  store i32 %inc9, ptr %i, align 4
  br label %for.cond, !llvm.loop !8

for.end10:                                        ; preds = %for.cond.cleanup
  store i32 0, ptr %retval, align 4
  store i32 1, ptr %cleanup.dest.slot, align 4
  call void @llvm.lifetime.end.p0(i64 4, ptr %n) #3
  %4 = load i32, ptr %retval, align 4
  ret i32 %4
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare i64 @read(...) #2

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
!8 = distinct !{!8, !6, !7}
