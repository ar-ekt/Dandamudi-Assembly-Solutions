%INCLUDE "lib.h"
global _start

section .code
_start:
    mov eax, 1
    mov ebx, 0
    int 0x80

;--------------------------------proc abs_--------------------------------;
; this procedure receives an 8-bit signed number in the AL register and   ;
; returns its absolute value back in the same register. (negative numbers ;
; are stored in 2’s complement representation)                            ;
;-------------------------------------------------------------------------;

abs_:
    push ecx
    push edx
    rcl al, 1       ; move MSB (sign bit) into CF and check it to see if the signed number is negative or not
    jc negative     ; if it is, goto negative part
    rcr al, 1       ; otherwise move back sign bit into its position (MSB) and restore CF original value
    jmp done
negative:
    rcr al, 1       ; move back sign bit into its position (MSB)
    dec al          ; subtract 1 from the number
    mov edx, 0      ; clear DL to store new number
    mov ecx, 8
not_number:         ; turns 1's into 0's and vice versa
    shl dl, 1       ; insert 0 in LSB of DL
    shl al, 1       ; move MSB of AL into CF
    jnc insert_one  ; if it was 0, add 1 to LSB of DL (currently occupied with 0)
    jmp continue
insert_one:
    inc dl
continue:
    loop not_number
    mov eax, edx    ; move new number back to AL
done:
    pop edx
    pop ecx
    ret