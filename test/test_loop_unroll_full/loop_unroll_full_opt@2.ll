; ModuleID = '.tmp/a.ll'
source_filename = "bitcount4/src/bitcount4.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@BitsSetTable256 = external global [256 x i32], align 16

; Function Attrs: nounwind uwtable
define dso_local i32 @countSetBits(i32 noundef %n) #0 {
entry:
  %and = and i32 %n, 255
  %idxprom = sext i32 %and to i64
  %arrayidx = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom
  %0 = load i32, ptr %arrayidx, align 4
  %shr = ashr i32 %n, 8
  %and1 = and i32 %shr, 255
  %idxprom2 = sext i32 %and1 to i64
  %arrayidx3 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom2
  %1 = load i32, ptr %arrayidx3, align 4
  %add = add nsw i32 %0, %1
  %shr4 = ashr i32 %n, 16
  %and5 = and i32 %shr4, 255
  %idxprom6 = sext i32 %and5 to i64
  %arrayidx7 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom6
  %2 = load i32, ptr %arrayidx7, align 4
  %add8 = add nsw i32 %add, %2
  %shr9 = ashr i32 %n, 24
  %idxprom10 = sext i32 %shr9 to i64
  %arrayidx11 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom10
  %3 = load i32, ptr %arrayidx11, align 4
  %add12 = add nsw i32 %add8, %3
  ret i32 %add12
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main() #0 {
  ; CHECK-LABEL: define dso_local i32 @main() #0 {
; CHECK: entry:
; CHECK-NEXT:   store i32 0, ptr @BitsSetTable256, align 16
; CHECK-NEXT:   br label %for.cond
; CHECK: for.cond:                                         ; preds = %for.body, %entry
; CHECK-NEXT:   %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next.31, %for.body ]
; CHECK-NEXT:   %exitcond = icmp ne i64 %indvars.iv, 256
; CHECK-NEXT:   br i1 %exitcond, label %for.body, label %for.end
; CHECK: for.body:                                         ; preds = %for.cond
; CHECK-NEXT:   %0 = trunc i64 %indvars.iv to i32
; CHECK-NEXT:   %div.udiv = udiv i32 %0, 2
; CHECK-NEXT:   %idxprom = sext i32 %div.udiv to i64
; CHECK-NEXT:   %arrayidx = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom
; CHECK-NEXT:   %1 = load i32, ptr %arrayidx, align 4
; CHECK-NEXT:   %arrayidx2 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv
; CHECK-NEXT:   store i32 %1, ptr %arrayidx2, align 4
; CHECK-NEXT:   %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
; CHECK-NEXT:   %2 = trunc i64 %indvars.iv.next to i32
; CHECK-NEXT:   %div.udiv.1 = udiv i32 %2, 2
; CHECK-NEXT:   %idxprom.1 = sext i32 %div.udiv.1 to i64
; CHECK-NEXT:   %arrayidx.1 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.1
; CHECK-NEXT:   %3 = load i32, ptr %arrayidx.1, align 4
; CHECK-NEXT:   %add.1 = add nsw i32 1, %3
; CHECK-NEXT:   %arrayidx2.1 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next
; CHECK-NEXT:   store i32 %add.1, ptr %arrayidx2.1, align 4
; CHECK-NEXT:   %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv, 2
; CHECK-NEXT:   %4 = trunc i64 %indvars.iv.next.1 to i32
; CHECK-NEXT:   %div.udiv.2 = udiv i32 %4, 2
; CHECK-NEXT:   %idxprom.2 = sext i32 %div.udiv.2 to i64
; CHECK-NEXT:   %arrayidx.2 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.2
; CHECK-NEXT:   %5 = load i32, ptr %arrayidx.2, align 4
; CHECK-NEXT:   %arrayidx2.2 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.1
; CHECK-NEXT:   store i32 %5, ptr %arrayidx2.2, align 4
; CHECK-NEXT:   %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv, 3
; CHECK-NEXT:   %6 = trunc i64 %indvars.iv.next.2 to i32
; CHECK-NEXT:   %div.udiv.3 = udiv i32 %6, 2
; CHECK-NEXT:   %idxprom.3 = sext i32 %div.udiv.3 to i64
; CHECK-NEXT:   %arrayidx.3 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.3
; CHECK-NEXT:   %7 = load i32, ptr %arrayidx.3, align 4
; CHECK-NEXT:   %add.3 = add nsw i32 1, %7
; CHECK-NEXT:   %arrayidx2.3 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.2
; CHECK-NEXT:   store i32 %add.3, ptr %arrayidx2.3, align 4
; CHECK-NEXT:   %indvars.iv.next.3 = add nuw nsw i64 %indvars.iv, 4
; CHECK-NEXT:   %8 = trunc i64 %indvars.iv.next.3 to i32
; CHECK-NEXT:   %div.udiv.4 = udiv i32 %8, 2
; CHECK-NEXT:   %idxprom.4 = sext i32 %div.udiv.4 to i64
; CHECK-NEXT:   %arrayidx.4 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.4
; CHECK-NEXT:   %9 = load i32, ptr %arrayidx.4, align 4
; CHECK-NEXT:   %arrayidx2.4 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.3
; CHECK-NEXT:   store i32 %9, ptr %arrayidx2.4, align 4
; CHECK-NEXT:   %indvars.iv.next.4 = add nuw nsw i64 %indvars.iv, 5
; CHECK-NEXT:   %10 = trunc i64 %indvars.iv.next.4 to i32
; CHECK-NEXT:   %div.udiv.5 = udiv i32 %10, 2
; CHECK-NEXT:   %idxprom.5 = sext i32 %div.udiv.5 to i64
; CHECK-NEXT:   %arrayidx.5 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.5
; CHECK-NEXT:   %11 = load i32, ptr %arrayidx.5, align 4
; CHECK-NEXT:   %add.5 = add nsw i32 1, %11
; CHECK-NEXT:   %arrayidx2.5 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.4
; CHECK-NEXT:   store i32 %add.5, ptr %arrayidx2.5, align 4
; CHECK-NEXT:   %indvars.iv.next.5 = add nuw nsw i64 %indvars.iv, 6
; CHECK-NEXT:   %12 = trunc i64 %indvars.iv.next.5 to i32
; CHECK-NEXT:   %div.udiv.6 = udiv i32 %12, 2
; CHECK-NEXT:   %idxprom.6 = sext i32 %div.udiv.6 to i64
; CHECK-NEXT:   %arrayidx.6 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.6
; CHECK-NEXT:   %13 = load i32, ptr %arrayidx.6, align 4
; CHECK-NEXT:   %arrayidx2.6 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.5
; CHECK-NEXT:   store i32 %13, ptr %arrayidx2.6, align 4
; CHECK-NEXT:   %indvars.iv.next.6 = add nuw nsw i64 %indvars.iv, 7
; CHECK-NEXT:   %14 = trunc i64 %indvars.iv.next.6 to i32
; CHECK-NEXT:   %div.udiv.7 = udiv i32 %14, 2
; CHECK-NEXT:   %idxprom.7 = sext i32 %div.udiv.7 to i64
; CHECK-NEXT:   %arrayidx.7 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.7
; CHECK-NEXT:   %15 = load i32, ptr %arrayidx.7, align 4
; CHECK-NEXT:   %add.7 = add nsw i32 1, %15
; CHECK-NEXT:   %arrayidx2.7 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.6
; CHECK-NEXT:   store i32 %add.7, ptr %arrayidx2.7, align 4
; CHECK-NEXT:   %indvars.iv.next.7 = add nuw nsw i64 %indvars.iv, 8
; CHECK-NEXT:   %16 = trunc i64 %indvars.iv.next.7 to i32
; CHECK-NEXT:   %div.udiv.8 = udiv i32 %16, 2
; CHECK-NEXT:   %idxprom.8 = sext i32 %div.udiv.8 to i64
; CHECK-NEXT:   %arrayidx.8 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.8
; CHECK-NEXT:   %17 = load i32, ptr %arrayidx.8, align 4
; CHECK-NEXT:   %arrayidx2.8 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.7
; CHECK-NEXT:   store i32 %17, ptr %arrayidx2.8, align 4
; CHECK-NEXT:   %indvars.iv.next.8 = add nuw nsw i64 %indvars.iv, 9
; CHECK-NEXT:   %18 = trunc i64 %indvars.iv.next.8 to i32
; CHECK-NEXT:   %div.udiv.9 = udiv i32 %18, 2
; CHECK-NEXT:   %idxprom.9 = sext i32 %div.udiv.9 to i64
; CHECK-NEXT:   %arrayidx.9 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.9
; CHECK-NEXT:   %19 = load i32, ptr %arrayidx.9, align 4
; CHECK-NEXT:   %add.9 = add nsw i32 1, %19
; CHECK-NEXT:   %arrayidx2.9 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.8
; CHECK-NEXT:   store i32 %add.9, ptr %arrayidx2.9, align 4
; CHECK-NEXT:   %indvars.iv.next.9 = add nuw nsw i64 %indvars.iv, 10
; CHECK-NEXT:   %20 = trunc i64 %indvars.iv.next.9 to i32
; CHECK-NEXT:   %div.udiv.10 = udiv i32 %20, 2
; CHECK-NEXT:   %idxprom.10 = sext i32 %div.udiv.10 to i64
; CHECK-NEXT:   %arrayidx.10 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.10
; CHECK-NEXT:   %21 = load i32, ptr %arrayidx.10, align 4
; CHECK-NEXT:   %arrayidx2.10 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.9
; CHECK-NEXT:   store i32 %21, ptr %arrayidx2.10, align 4
; CHECK-NEXT:   %indvars.iv.next.10 = add nuw nsw i64 %indvars.iv, 11
; CHECK-NEXT:   %22 = trunc i64 %indvars.iv.next.10 to i32
; CHECK-NEXT:   %div.udiv.11 = udiv i32 %22, 2
; CHECK-NEXT:   %idxprom.11 = sext i32 %div.udiv.11 to i64
; CHECK-NEXT:   %arrayidx.11 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.11
; CHECK-NEXT:   %23 = load i32, ptr %arrayidx.11, align 4
; CHECK-NEXT:   %add.11 = add nsw i32 1, %23
; CHECK-NEXT:   %arrayidx2.11 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.10
; CHECK-NEXT:   store i32 %add.11, ptr %arrayidx2.11, align 4
; CHECK-NEXT:   %indvars.iv.next.11 = add nuw nsw i64 %indvars.iv, 12
; CHECK-NEXT:   %24 = trunc i64 %indvars.iv.next.11 to i32
; CHECK-NEXT:   %div.udiv.12 = udiv i32 %24, 2
; CHECK-NEXT:   %idxprom.12 = sext i32 %div.udiv.12 to i64
; CHECK-NEXT:   %arrayidx.12 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.12
; CHECK-NEXT:   %25 = load i32, ptr %arrayidx.12, align 4
; CHECK-NEXT:   %arrayidx2.12 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.11
; CHECK-NEXT:   store i32 %25, ptr %arrayidx2.12, align 4
; CHECK-NEXT:   %indvars.iv.next.12 = add nuw nsw i64 %indvars.iv, 13
; CHECK-NEXT:   %26 = trunc i64 %indvars.iv.next.12 to i32
; CHECK-NEXT:   %div.udiv.13 = udiv i32 %26, 2
; CHECK-NEXT:   %idxprom.13 = sext i32 %div.udiv.13 to i64
; CHECK-NEXT:   %arrayidx.13 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.13
; CHECK-NEXT:   %27 = load i32, ptr %arrayidx.13, align 4
; CHECK-NEXT:   %add.13 = add nsw i32 1, %27
; CHECK-NEXT:   %arrayidx2.13 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.12
; CHECK-NEXT:   store i32 %add.13, ptr %arrayidx2.13, align 4
; CHECK-NEXT:   %indvars.iv.next.13 = add nuw nsw i64 %indvars.iv, 14
; CHECK-NEXT:   %28 = trunc i64 %indvars.iv.next.13 to i32
; CHECK-NEXT:   %div.udiv.14 = udiv i32 %28, 2
; CHECK-NEXT:   %idxprom.14 = sext i32 %div.udiv.14 to i64
; CHECK-NEXT:   %arrayidx.14 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.14
; CHECK-NEXT:   %29 = load i32, ptr %arrayidx.14, align 4
; CHECK-NEXT:   %arrayidx2.14 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.13
; CHECK-NEXT:   store i32 %29, ptr %arrayidx2.14, align 4
; CHECK-NEXT:   %indvars.iv.next.14 = add nuw nsw i64 %indvars.iv, 15
; CHECK-NEXT:   %30 = trunc i64 %indvars.iv.next.14 to i32
; CHECK-NEXT:   %div.udiv.15 = udiv i32 %30, 2
; CHECK-NEXT:   %idxprom.15 = sext i32 %div.udiv.15 to i64
; CHECK-NEXT:   %arrayidx.15 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.15
; CHECK-NEXT:   %31 = load i32, ptr %arrayidx.15, align 4
; CHECK-NEXT:   %add.15 = add nsw i32 1, %31
; CHECK-NEXT:   %arrayidx2.15 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.14
; CHECK-NEXT:   store i32 %add.15, ptr %arrayidx2.15, align 4
; CHECK-NEXT:   %indvars.iv.next.15 = add nuw nsw i64 %indvars.iv, 16
; CHECK-NEXT:   %32 = trunc i64 %indvars.iv.next.15 to i32
; CHECK-NEXT:   %div.udiv.16 = udiv i32 %32, 2
; CHECK-NEXT:   %idxprom.16 = sext i32 %div.udiv.16 to i64
; CHECK-NEXT:   %arrayidx.16 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.16
; CHECK-NEXT:   %33 = load i32, ptr %arrayidx.16, align 4
; CHECK-NEXT:   %arrayidx2.16 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.15
; CHECK-NEXT:   store i32 %33, ptr %arrayidx2.16, align 4
; CHECK-NEXT:   %indvars.iv.next.16 = add nuw nsw i64 %indvars.iv, 17
; CHECK-NEXT:   %34 = trunc i64 %indvars.iv.next.16 to i32
; CHECK-NEXT:   %div.udiv.17 = udiv i32 %34, 2
; CHECK-NEXT:   %idxprom.17 = sext i32 %div.udiv.17 to i64
; CHECK-NEXT:   %arrayidx.17 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.17
; CHECK-NEXT:   %35 = load i32, ptr %arrayidx.17, align 4
; CHECK-NEXT:   %add.17 = add nsw i32 1, %35
; CHECK-NEXT:   %arrayidx2.17 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.16
; CHECK-NEXT:   store i32 %add.17, ptr %arrayidx2.17, align 4
; CHECK-NEXT:   %indvars.iv.next.17 = add nuw nsw i64 %indvars.iv, 18
; CHECK-NEXT:   %36 = trunc i64 %indvars.iv.next.17 to i32
; CHECK-NEXT:   %div.udiv.18 = udiv i32 %36, 2
; CHECK-NEXT:   %idxprom.18 = sext i32 %div.udiv.18 to i64
; CHECK-NEXT:   %arrayidx.18 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.18
; CHECK-NEXT:   %37 = load i32, ptr %arrayidx.18, align 4
; CHECK-NEXT:   %arrayidx2.18 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.17
; CHECK-NEXT:   store i32 %37, ptr %arrayidx2.18, align 4
; CHECK-NEXT:   %indvars.iv.next.18 = add nuw nsw i64 %indvars.iv, 19
; CHECK-NEXT:   %38 = trunc i64 %indvars.iv.next.18 to i32
; CHECK-NEXT:   %div.udiv.19 = udiv i32 %38, 2
; CHECK-NEXT:   %idxprom.19 = sext i32 %div.udiv.19 to i64
; CHECK-NEXT:   %arrayidx.19 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.19
; CHECK-NEXT:   %39 = load i32, ptr %arrayidx.19, align 4
; CHECK-NEXT:   %add.19 = add nsw i32 1, %39
; CHECK-NEXT:   %arrayidx2.19 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.18
; CHECK-NEXT:   store i32 %add.19, ptr %arrayidx2.19, align 4
; CHECK-NEXT:   %indvars.iv.next.19 = add nuw nsw i64 %indvars.iv, 20
; CHECK-NEXT:   %40 = trunc i64 %indvars.iv.next.19 to i32
; CHECK-NEXT:   %div.udiv.20 = udiv i32 %40, 2
; CHECK-NEXT:   %idxprom.20 = sext i32 %div.udiv.20 to i64
; CHECK-NEXT:   %arrayidx.20 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.20
; CHECK-NEXT:   %41 = load i32, ptr %arrayidx.20, align 4
; CHECK-NEXT:   %arrayidx2.20 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.19
; CHECK-NEXT:   store i32 %41, ptr %arrayidx2.20, align 4
; CHECK-NEXT:   %indvars.iv.next.20 = add nuw nsw i64 %indvars.iv, 21
; CHECK-NEXT:   %42 = trunc i64 %indvars.iv.next.20 to i32
; CHECK-NEXT:   %div.udiv.21 = udiv i32 %42, 2
; CHECK-NEXT:   %idxprom.21 = sext i32 %div.udiv.21 to i64
; CHECK-NEXT:   %arrayidx.21 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.21
; CHECK-NEXT:   %43 = load i32, ptr %arrayidx.21, align 4
; CHECK-NEXT:   %add.21 = add nsw i32 1, %43
; CHECK-NEXT:   %arrayidx2.21 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.20
; CHECK-NEXT:   store i32 %add.21, ptr %arrayidx2.21, align 4
; CHECK-NEXT:   %indvars.iv.next.21 = add nuw nsw i64 %indvars.iv, 22
; CHECK-NEXT:   %44 = trunc i64 %indvars.iv.next.21 to i32
; CHECK-NEXT:   %div.udiv.22 = udiv i32 %44, 2
; CHECK-NEXT:   %idxprom.22 = sext i32 %div.udiv.22 to i64
; CHECK-NEXT:   %arrayidx.22 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.22
; CHECK-NEXT:   %45 = load i32, ptr %arrayidx.22, align 4
; CHECK-NEXT:   %arrayidx2.22 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.21
; CHECK-NEXT:   store i32 %45, ptr %arrayidx2.22, align 4
; CHECK-NEXT:   %indvars.iv.next.22 = add nuw nsw i64 %indvars.iv, 23
; CHECK-NEXT:   %46 = trunc i64 %indvars.iv.next.22 to i32
; CHECK-NEXT:   %div.udiv.23 = udiv i32 %46, 2
; CHECK-NEXT:   %idxprom.23 = sext i32 %div.udiv.23 to i64
; CHECK-NEXT:   %arrayidx.23 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.23
; CHECK-NEXT:   %47 = load i32, ptr %arrayidx.23, align 4
; CHECK-NEXT:   %add.23 = add nsw i32 1, %47
; CHECK-NEXT:   %arrayidx2.23 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.22
; CHECK-NEXT:   store i32 %add.23, ptr %arrayidx2.23, align 4
; CHECK-NEXT:   %indvars.iv.next.23 = add nuw nsw i64 %indvars.iv, 24
; CHECK-NEXT:   %48 = trunc i64 %indvars.iv.next.23 to i32
; CHECK-NEXT:   %div.udiv.24 = udiv i32 %48, 2
; CHECK-NEXT:   %idxprom.24 = sext i32 %div.udiv.24 to i64
; CHECK-NEXT:   %arrayidx.24 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.24
; CHECK-NEXT:   %49 = load i32, ptr %arrayidx.24, align 4
; CHECK-NEXT:   %arrayidx2.24 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.23
; CHECK-NEXT:   store i32 %49, ptr %arrayidx2.24, align 4
; CHECK-NEXT:   %indvars.iv.next.24 = add nuw nsw i64 %indvars.iv, 25
; CHECK-NEXT:   %50 = trunc i64 %indvars.iv.next.24 to i32
; CHECK-NEXT:   %div.udiv.25 = udiv i32 %50, 2
; CHECK-NEXT:   %idxprom.25 = sext i32 %div.udiv.25 to i64
; CHECK-NEXT:   %arrayidx.25 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.25
; CHECK-NEXT:   %51 = load i32, ptr %arrayidx.25, align 4
; CHECK-NEXT:   %add.25 = add nsw i32 1, %51
; CHECK-NEXT:   %arrayidx2.25 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.24
; CHECK-NEXT:   store i32 %add.25, ptr %arrayidx2.25, align 4
; CHECK-NEXT:   %indvars.iv.next.25 = add nuw nsw i64 %indvars.iv, 26
; CHECK-NEXT:   %52 = trunc i64 %indvars.iv.next.25 to i32
; CHECK-NEXT:   %div.udiv.26 = udiv i32 %52, 2
; CHECK-NEXT:   %idxprom.26 = sext i32 %div.udiv.26 to i64
; CHECK-NEXT:   %arrayidx.26 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.26
; CHECK-NEXT:   %53 = load i32, ptr %arrayidx.26, align 4
; CHECK-NEXT:   %arrayidx2.26 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.25
; CHECK-NEXT:   store i32 %53, ptr %arrayidx2.26, align 4
; CHECK-NEXT:   %indvars.iv.next.26 = add nuw nsw i64 %indvars.iv, 27
; CHECK-NEXT:   %54 = trunc i64 %indvars.iv.next.26 to i32
; CHECK-NEXT:   %div.udiv.27 = udiv i32 %54, 2
; CHECK-NEXT:   %idxprom.27 = sext i32 %div.udiv.27 to i64
; CHECK-NEXT:   %arrayidx.27 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.27
; CHECK-NEXT:   %55 = load i32, ptr %arrayidx.27, align 4
; CHECK-NEXT:   %add.27 = add nsw i32 1, %55
; CHECK-NEXT:   %arrayidx2.27 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.26
; CHECK-NEXT:   store i32 %add.27, ptr %arrayidx2.27, align 4
; CHECK-NEXT:   %indvars.iv.next.27 = add nuw nsw i64 %indvars.iv, 28
; CHECK-NEXT:   %56 = trunc i64 %indvars.iv.next.27 to i32
; CHECK-NEXT:   %div.udiv.28 = udiv i32 %56, 2
; CHECK-NEXT:   %idxprom.28 = sext i32 %div.udiv.28 to i64
; CHECK-NEXT:   %arrayidx.28 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.28
; CHECK-NEXT:   %57 = load i32, ptr %arrayidx.28, align 4
; CHECK-NEXT:   %arrayidx2.28 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.27
; CHECK-NEXT:   store i32 %57, ptr %arrayidx2.28, align 4
; CHECK-NEXT:   %indvars.iv.next.28 = add nuw nsw i64 %indvars.iv, 29
; CHECK-NEXT:   %58 = trunc i64 %indvars.iv.next.28 to i32
; CHECK-NEXT:   %div.udiv.29 = udiv i32 %58, 2
; CHECK-NEXT:   %idxprom.29 = sext i32 %div.udiv.29 to i64
; CHECK-NEXT:   %arrayidx.29 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.29
; CHECK-NEXT:   %59 = load i32, ptr %arrayidx.29, align 4
; CHECK-NEXT:   %add.29 = add nsw i32 1, %59
; CHECK-NEXT:   %arrayidx2.29 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.28
; CHECK-NEXT:   store i32 %add.29, ptr %arrayidx2.29, align 4
; CHECK-NEXT:   %indvars.iv.next.29 = add nuw nsw i64 %indvars.iv, 30
; CHECK-NEXT:   %60 = trunc i64 %indvars.iv.next.29 to i32
; CHECK-NEXT:   %div.udiv.30 = udiv i32 %60, 2
; CHECK-NEXT:   %idxprom.30 = sext i32 %div.udiv.30 to i64
; CHECK-NEXT:   %arrayidx.30 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.30
; CHECK-NEXT:   %61 = load i32, ptr %arrayidx.30, align 4
; CHECK-NEXT:   %arrayidx2.30 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.29
; CHECK-NEXT:   store i32 %61, ptr %arrayidx2.30, align 4
; CHECK-NEXT:   %indvars.iv.next.30 = add nuw nsw i64 %indvars.iv, 31
; CHECK-NEXT:   %62 = trunc i64 %indvars.iv.next.30 to i32
; CHECK-NEXT:   %div.udiv.31 = udiv i32 %62, 2
; CHECK-NEXT:   %idxprom.31 = sext i32 %div.udiv.31 to i64
; CHECK-NEXT:   %arrayidx.31 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom.31
; CHECK-NEXT:   %63 = load i32, ptr %arrayidx.31, align 4
; CHECK-NEXT:   %add.31 = add nsw i32 1, %63
; CHECK-NEXT:   %arrayidx2.31 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %indvars.iv.next.30
; CHECK-NEXT:   store i32 %add.31, ptr %arrayidx2.31, align 4
; CHECK-NEXT:   %indvars.iv.next.31 = add nuw nsw i64 %indvars.iv, 32
; CHECK-NEXT:   br label %for.cond, !llvm.loop !5
; CHECK: for.end:                                          ; preds = %for.cond
; CHECK-NEXT:   %call = call i64 (...) @read()
; CHECK-NEXT:   %conv = trunc i64 %call to i32
; CHECK-NEXT:   %call3 = call i32 @countSetBits(i32 noundef %conv)
; CHECK-NEXT:   %conv4 = sext i32 %call3 to i64
; CHECK-NEXT:   call void @write(i64 noundef %conv4)
; CHECK-NEXT:   ret i32 0
; CHECK-NEXT: }
entry:
  store i32 0, ptr @BitsSetTable256, align 16
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %cmp = icmp slt i32 %i.0, 256
  br i1 %cmp, label %for.body, label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond
  br label %for.end

for.body:                                         ; preds = %for.cond
  %and = and i32 %i.0, 1
  %div = sdiv i32 %i.0, 2
  %idxprom = sext i32 %div to i64
  %arrayidx = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom
  %0 = load i32, ptr %arrayidx, align 4
  %add = add nsw i32 %and, %0
  %idxprom1 = sext i32 %i.0 to i64
  %arrayidx2 = getelementptr inbounds [256 x i32], ptr @BitsSetTable256, i64 0, i64 %idxprom1
  store i32 %add, ptr %arrayidx2, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %i.0, 1
  br label %for.cond, !llvm.loop !5

for.end:                                          ; preds = %for.cond.cleanup
  %call = call i64 (...) @read()
  %conv = trunc i64 %call to i32
  %call3 = call i32 @countSetBits(i32 noundef %conv)
  %conv4 = sext i32 %call3 to i64
  call void @write(i64 noundef %conv4)
  ret i32 0
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

declare void @write(i64 noundef) #2

declare i64 @read(...) #2

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
