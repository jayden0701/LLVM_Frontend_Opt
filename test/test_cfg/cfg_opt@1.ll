; CHECK-LABEL: @test1(
; CHECK: entry:
; CHECK-NEXT: %x = and i64 %a, %b
; CHECK-NEXT: %y = or i64 %a, %b
; CHECK-NEXT: %z = xor i64 %a, %b
; CHECK-NEXT: ret i64 %z
define i64 @test1(i64 %a, i64 %b){   
    entry:
    %x = and i64 %a, %b
    br label %uncond

    uncond:
    %y = or i64 %a, %b
    br label %end

    end:
    %z = xor i64 %a, %b
    ret i64 %z
}