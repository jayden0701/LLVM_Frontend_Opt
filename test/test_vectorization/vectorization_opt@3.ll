; ModuleID = 'test/test_vectorization/vectorization_opt@1.ll'
source_filename = "test/test_vectorization/vectorization_opt@1.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local void @read_mat(i32 noundef %dim, ptr noundef %mat) #0 {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.body.3, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc.3, %for.body.3 ]
  %exitcond = icmp ne i32 %i.0, %dim
  br i1 %exitcond, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %call = call i64 (...) @read()
  %idxprom = zext i32 %dim to i64
  %arrayidx = getelementptr inbounds i64, ptr %mat, i64 %idxprom
  store i64 %call, ptr %arrayidx, align 8
  %inc = add nuw nsw i32 %i.0, 1
  %exitcond.1 = icmp ne i32 %inc, %dim
  br i1 %exitcond.1, label %for.body.1, label %for.end

for.body.1:                                       ; preds = %for.body
  %call.1 = call i64 (...) @read()
  %idxprom.1 = zext i32 %dim to i64
  %arrayidx.1 = getelementptr inbounds i64, ptr %mat, i64 %idxprom.1
  store i64 %call.1, ptr %arrayidx.1, align 8
  %inc.1 = add nuw nsw i32 %i.0, 2
  %exitcond.2 = icmp ne i32 %inc.1, %dim
  br i1 %exitcond.2, label %for.body.2, label %for.end

for.body.2:                                       ; preds = %for.body.1
  %call.2 = call i64 (...) @read()
  %idxprom.2 = zext i32 %dim to i64
  %arrayidx.2 = getelementptr inbounds i64, ptr %mat, i64 %idxprom.2
  store i64 %call.2, ptr %arrayidx.2, align 8
  %inc.2 = add nuw nsw i32 %i.0, 3
  %exitcond.3 = icmp ne i32 %inc.2, %dim
  br i1 %exitcond.3, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.body.2
  %call.3 = call i64 (...) @read()
  %idxprom.3 = zext i32 %dim to i64
  %arrayidx.3 = getelementptr inbounds i64, ptr %mat, i64 %idxprom.3
  store i64 %call.3, ptr %arrayidx.3, align 8
  %inc.3 = add i32 %i.0, 4
  br label %for.cond, !llvm.loop !5

for.end:                                          ; preds = %for.body.2, %for.body.1, %for.body, %for.cond
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

declare i64 @read(...) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local void @print_mat(i32 noundef %dim, ptr noundef %mat) #0 {
entry:
  %wide.trip.count = zext i32 %dim to i64
  br label %for.cond

for.cond:                                         ; preds = %for.body.3, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next.3, %for.body.3 ]
  %exitcond = icmp ne i64 %indvars.iv, %wide.trip.count
  br i1 %exitcond, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arrayidx = getelementptr inbounds i64, ptr %mat, i64 %indvars.iv
  %0 = load i64, ptr %arrayidx, align 8
  call void @write(i64 noundef %0)
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.1 = icmp ne i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.1, label %for.body.1, label %for.end

for.body.1:                                       ; preds = %for.body
  %arrayidx.1 = getelementptr inbounds i64, ptr %mat, i64 %indvars.iv.next
  %1 = load i64, ptr %arrayidx.1, align 8
  call void @write(i64 noundef %1)
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv, 2
  %exitcond.2 = icmp ne i64 %indvars.iv.next.1, %wide.trip.count
  br i1 %exitcond.2, label %for.body.2, label %for.end

for.body.2:                                       ; preds = %for.body.1
  %arrayidx.2 = getelementptr inbounds i64, ptr %mat, i64 %indvars.iv.next.1
  %2 = load i64, ptr %arrayidx.2, align 8
  call void @write(i64 noundef %2)
  %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv, 3
  %exitcond.3 = icmp ne i64 %indvars.iv.next.2, %wide.trip.count
  br i1 %exitcond.3, label %for.body.3, label %for.end

for.body.3:                                       ; preds = %for.body.2
  %arrayidx.3 = getelementptr inbounds i64, ptr %mat, i64 %indvars.iv.next.2
  %3 = load i64, ptr %arrayidx.3, align 8
  call void @write(i64 noundef %3)
  %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv, 4
  br label %for.cond, !llvm.loop !8

for.end:                                          ; preds = %for.body.2, %for.body.1, %for.body, %for.cond
  ret void
}

declare void @write(i64 noundef) #2

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
; CHECK-LABEL: define dso_local i32 @main() #0 {
; CHECK: entry:
; CHECK-NEXT:   %a = alloca [4 x i64], align 16
; CHECK-NEXT:   %b = alloca [4 x i64], align 16
; CHECK-NEXT:   %c = alloca [4 x i64], align 16
; CHECK-NEXT:   call void @llvm.lifetime.start.p0(i64 32, ptr %a) #3
; CHECK-NEXT:   call void @llvm.lifetime.start.p0(i64 32, ptr %b) #3
; CHECK-NEXT:   call void @llvm.lifetime.start.p0(i64 32, ptr %c) #3
; CHECK-NEXT:   %arraydecay = getelementptr inbounds [4 x i64], ptr %a, i64 0, i64 0
; CHECK-NEXT:   call void @read_mat(i32 noundef 4, ptr noundef %arraydecay)
; CHECK-NEXT:   %arraydecay1 = getelementptr inbounds [4 x i64], ptr %b, i64 0, i64 0
; CHECK-NEXT:   call void @read_mat(i32 noundef 4, ptr noundef %arraydecay1)
; CHECK-NEXT:   %arrayidx = getelementptr inbounds [4 x i64], ptr %a, i64 0, i64 0
; CHECK-NEXT:   %0 = load i64, ptr %arrayidx, align 16
; CHECK-NEXT:   %arrayidx2 = getelementptr inbounds [4 x i64], ptr %b, i64 0, i64 0
; CHECK-NEXT:   %1 = load i64, ptr %arrayidx2, align 16
; CHECK-NEXT:   %add = mul i64 %0, %1
; CHECK-NEXT:   %arrayidx3 = getelementptr inbounds [4 x i64], ptr %c, i64 0, i64 0
; CHECK-NEXT:   store i64 %add, ptr %arrayidx3, align 16
; CHECK-NEXT:   %arraydecay16 = getelementptr inbounds [4 x i64], ptr %c, i64 0, i64 0
; CHECK-NEXT:   call void @print_mat(i32 noundef 4, ptr noundef %arraydecay16)
; CHECK-NEXT:   call void @llvm.lifetime.end.p0(i64 32, ptr %c) #3
; CHECK-NEXT:   call void @llvm.lifetime.end.p0(i64 32, ptr %b) #3
; CHECK-NEXT:   call void @llvm.lifetime.end.p0(i64 32, ptr %a) #3
; CHECK-NEXT:   ret i32 0
; CHECK-NEXT: }
entry:
  %a = alloca [4 x i64], align 16
  %b = alloca [4 x i64], align 16
  %c = alloca [4 x i64], align 16
  call void @llvm.lifetime.start.p0(i64 32, ptr %a) #3
  call void @llvm.lifetime.start.p0(i64 32, ptr %b) #3
  call void @llvm.lifetime.start.p0(i64 32, ptr %c) #3
  %arraydecay = getelementptr inbounds [4 x i64], ptr %a, i64 0, i64 0
  call void @read_mat(i32 noundef 4, ptr noundef %arraydecay)
  %arraydecay1 = getelementptr inbounds [4 x i64], ptr %b, i64 0, i64 0
  call void @read_mat(i32 noundef 4, ptr noundef %arraydecay1)
  %arrayidx = getelementptr inbounds [4 x i64], ptr %a, i64 0, i64 0
  %0 = load i64, ptr %arrayidx, align 16
  %arrayidx2 = getelementptr inbounds [4 x i64], ptr %b, i64 0, i64 0
  %1 = load i64, ptr %arrayidx2, align 16
  %add = mul i64 %0, %1
  %arrayidx3 = getelementptr inbounds [4 x i64], ptr %c, i64 0, i64 0
  store i64 %add, ptr %arrayidx3, align 16
  %arraydecay16 = getelementptr inbounds [4 x i64], ptr %c, i64 0, i64 0
  call void @print_mat(i32 noundef 4, ptr noundef %arraydecay16)
  call void @llvm.lifetime.end.p0(i64 32, ptr %c) #3
  call void @llvm.lifetime.end.p0(i64 32, ptr %b) #3
  call void @llvm.lifetime.end.p0(i64 32, ptr %a) #3
  ret i32 0
}

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
