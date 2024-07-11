; nested loops

@global_var = global i32 42, align 4  ; Define a global integer variable

define void @process_nested_loops() {
entry:
  br label %outer_loop_entry

outer_loop_entry:                        ; Outer loop entry point
  %i = phi i32 [0, %entry], [%i.next, %outer_loop_latch]
  br label %inner_loop_entry



;CHECK: inner_loop_entry:
;CHECK-NOT : load
inner_loop_entry:                        ; Inner loop entry point
  %j = phi i32 [0, %outer_loop_entry], [%j.next, %inner_loop_latch]
  %load_global = load i32, i32* @global_var
  %calc = add i32 %load_global, %j
  br label %inner_loop_latch

inner_loop_latch:                        ; Inner loop condition check and increment
  %j.next = add i32 %j, 1
  %inner_loop_cond = icmp slt i32 %j.next, 5
  br i1 %inner_loop_cond, label %inner_loop_entry, label %outer_loop_latch

outer_loop_latch:                        ; Outer loop condition check and increment
  %i.next = add i32 %i, 1
  %outer_loop_cond = icmp slt i32 %i.next, 10
  br i1 %outer_loop_cond, label %outer_loop_entry, label %exit

exit:                                    ; Function exit
  ret void
}
