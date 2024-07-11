; ModuleID = '.tmp/a.ll'
source_filename = "bitcount1/src/bitcount1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local i32 @countSetBits(i32 noundef %n) #0 {

  ; CHECK-LABEL: define dso_local i32 @countSetBits(i32 noundef %n) #0 {
; CHECK: entry:
; CHECK-NEXT:   br label %while.cond

; CHECK: while.cond:                                       ; preds = %while.body.3, %entry
; CHECK-NEXT:   %n.addr.0 = phi i32 [ %n, %entry ], [ %shr.3, %while.body.3 ]
; CHECK-NEXT:   %count.0 = phi i32 [ 0, %entry ], [ %add.3, %while.body.3 ]
; CHECK-NEXT:   %tobool = icmp ne i32 %n.addr.0, 0
; CHECK-NEXT:   br i1 %tobool, label %while.body, label %while.end

; CHECK: while.body:                                       ; preds = %while.cond
; CHECK-NEXT:   %and = and i32 %n.addr.0, 1
; CHECK-NEXT:   %add = add i32 %count.0, %and
; CHECK-NEXT:   %shr = lshr i32 %n.addr.0, 1
; CHECK-NEXT:   %tobool.1 = icmp ne i32 %shr, 0
; CHECK-NEXT:   br i1 %tobool.1, label %while.body.1, label %while.end

; CHECK: while.body.1:                                     ; preds = %while.body
; CHECK-NEXT:   %and.1 = and i32 %shr, 1
; CHECK-NEXT:   %add.1 = add i32 %add, %and.1
; CHECK-NEXT:   %shr.1 = lshr i32 %shr, 1
; CHECK-NEXT:   %tobool.2 = icmp ne i32 %shr.1, 0
; CHECK-NEXT:   br i1 %tobool.2, label %while.body.2, label %while.end

; CHECK: while.body.2:                                     ; preds = %while.body.1
; CHECK-NEXT:   %and.2 = and i32 %shr.1, 1
; CHECK-NEXT:   %add.2 = add i32 %add.1, %and.2
; CHECK-NEXT:   %shr.2 = lshr i32 %shr.1, 1
; CHECK-NEXT:   %tobool.3 = icmp ne i32 %shr.2, 0
; CHECK-NEXT:   br i1 %tobool.3, label %while.body.3, label %while.end

; CHECK: while.body.3:                                     ; preds = %while.body.2
; CHECK-NEXT:   %and.3 = and i32 %shr.2, 1
; CHECK-NEXT:   %add.3 = add i32 %add.2, %and.3
; CHECK-NEXT:   %shr.3 = lshr i32 %shr.2, 1
; CHECK-NEXT:   br label %while.cond, !llvm.loop !5

; CHECK: while.end:                                        ; preds = %while.body.2, %while.body.1, %while.body, %while.cond
; CHECK-NEXT:   %count.0.lcssa = phi i32 [ %count.0, %while.cond ], [ %add, %while.body ], [ %add.1, %while.body.1 ], [ %add.2, %while.body.2 ]
; CHECK-NEXT:   ret i32 %count.0.lcssa
; CHECK-NEXT: }
entry:
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %n.addr.0 = phi i32 [ %n, %entry ], [ %shr, %while.body ]
  %count.0 = phi i32 [ 0, %entry ], [ %add, %while.body ]
  %tobool = icmp ne i32 %n.addr.0, 0
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %and = and i32 %n.addr.0, 1
  %add = add i32 %count.0, %and
  %shr = lshr i32 %n.addr.0, 1
  br label %while.cond, !llvm.loop !5

while.end:                                        ; preds = %while.cond
  ret i32 %count.0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
entry:
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  %call1 = call i32 @countSetBits(i32 noundef %conv)
  %conv2 = zext i32 %call1 to i64
  call void @write(i64 noundef %conv2)
  ret i32 0
}

declare i64 @read(...) #2

declare void @write(i64 noundef) #2

attributes #0 = { nounwind uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

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
