global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    nwln db 10, 0
    inMSG db "enter a number with less than 28 digits:", 0
    outMSG db "the sum of the individual digits is:", 0

section .bss
    buffer resb 30
    buffer2 resb 5

section .code
_start:
    puts inMSG
    puts nwln
    fgets buffer, 30
    mov EBX, buffer
    call sum_of_digits          ;returns the sum in EAX
    i2a EAX, buffer2
    puts buffer2
    puts nwln
    push 0
    call ExitProcess

;-----------proc sum_of_digits--------------;
;                                           ;
; adds up the individual digits of a number ;
;                                           ;
;-------------------------------------------;

sum_of_digits:
    xor EAX, EAX
    xor EDX, EDX
sum:
    mov DL, [EBX]
    cmp DL, 0
    je exitProc
    sub DL, 48
    add EAX, EDX
    inc EBX
    jmp sum
exitProc:
    ret
