;modified version of the addigits.asm code of example 4.10

global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    nwln db 10, 0
    number_prompt db "Please type a string (<50 digits): ",0
    out_msg db "The sum of individual digits is: ",0

section .bss
    number resb 52
    buffer resb 10

section .code
_start:
    puts number_prompt ; request an input number
    fgets number,52 ; read input number as a string
    mov EBX,number ; EBX = address of number
    sub EDX,EDX ; EDX = 0 -- DL keeps the sum
repeat_add:
    mov AL,[EBX] ; move the digit to AL
    cmp AL,0 ; if it is the NULL character
    je done ; sum is done
    cmp AL,48
    jl skip
    cmp AL,57
    jg skip 
    and AL,0FH ; mask off the upper 4 bits
    add DL,AL ; add the digit to sum
    inc EBX ; update EBX to point to next digit
    jmp repeat_add
skip:
    inc EBX
    jmp repeat_add
done:
    puts out_msg
    i2a EDX, buffer
    puts buffer
    puts nwln
    push 0
    call ExitProcess
