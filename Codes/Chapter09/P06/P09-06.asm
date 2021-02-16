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
    test al, 80h    ; test MSB to see if the signed number is negative or not
    jnz negative
    jmp done
negative:
    dec al          ; subtract 1 from the number
    not al          ; turns 1's into 0's and vice versa
done:
    ret