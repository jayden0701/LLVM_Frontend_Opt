; multiple global variables

@global_var1 = global i32 100, align 4  ; Define the first global integer variable
@global_var2 = global i32 200, align 4  ; Define the second global integer variable

define void @process_dual_globals() {

;CHECK: entry:
;CHECK-NEXT: %0 = load i32, ptr @global_var1, align 4
;CHECK-NEXT: %1 = load i32, ptr @global_var2, align 4
entry:
  br label %loop_entry

loop_entry:                              ; Loop entry point
  %i = phi i32 [0, %entry], [%i_next, %loop_latch]
  %load_global1 = load i32, i32* @global_var1  ; Load from the first global variable
  %load_global2 = load i32, i32* @global_var2  ; Load from the second global variable
  %sum = add i32 %load_global1, %load_global2  ; Sum the values of both global variables
  %store_sum = add i32 %sum, %i                 ; Add the loop index to the sum
  br label %loop_latch

loop_latch:                              ; Loop condition check and increment
  %i_next = add i32 %i, 1
  %loop_cond = icmp slt i32 %i_next, 10
  br i1 %loop_cond, label %loop_entry, label %exit

exit:                                     ; Function exit
  ret void
}
