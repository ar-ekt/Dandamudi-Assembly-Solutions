global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG db "enter the temperature in Celsius: ", 0
    outMSG db "the temperature in Fahrenheit: ", 0
    point_sign db ".", 0
    nwln db 10, 0

section .bss
    inBuffer resb 10
    outBuffer resb 10

section .code
_start:
    puts inMSG
    fgets inBuffer, 10
    a2i 10, inBuffer                ;temperature is in eax
    puts outMSG
mult_by_9:
    mov ebx, 9
    mul ebx                         ;result is in edx:eax
div_by_5:
    mov ebx, 5
    div ebx                         ;quotient is in eax, remainder is in edx
print_quotient:
    add eax, 32
    i2a eax, outBuffer
    puts outBuffer
    puts point_sign
get_fractions:
    xor eax, eax
    mov al, dl                      ;remainder is smaller than 5 and it fits in AL register
    mov bl, 10
    mul bl                          ;result is in ax
    mov bl, 5
    div bl                          ;quotient is in AL, and since the number is already multiplied by 10, there is no remainder, so AH is 0
print_fractions:
    i2a eax, outBuffer
    puts outBuffer
finish_prog:
    puts nwln
    push 0
    call ExitProcess