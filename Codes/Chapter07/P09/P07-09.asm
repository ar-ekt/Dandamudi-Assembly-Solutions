global _start
extern ExitProcess
%include "lib.h"

    ; input format: maximum_score
    ;               test_score1
    ;               test_score2
    ;               test_score3
    ;                  ...
    ;               negative_value (end of input)

section .data
    inMSG db "enter the scores (negative value to terminate): ", 0
    outMSG db "average: ", 0
    point_sign db ".", 0
    zero db "0", 0
    nwln db 10, 0

section .bss
    inBuffer resb 10
    outBuffer resb 10
    maximum_score resw 1

section .code
_start:
    puts inMSG
    puts nwln
    fgets inBuffer, 10
    a2i 10, inBuffer
    mov [maximum_score], ax
    xor edx, edx                    ;holds sum
    xor esi, esi                    ;holds count
input_loop:
    fgets inBuffer, 10
    mov al, [inBuffer]
    cmp al, '-'
    je set_dividend
    a2i 10, inBuffer
    add edx, eax
    inc esi
    jmp input_loop
set_dividend:                       ;dividend = dx:ax
    mov ax, dx
    xor dx, dx
    rol edx, 16
get_average:
    div si                          ;quotient = ax
    mov cx, ax
    xor eax, eax
    mov ax, cx
print_average:
    i2a eax, outBuffer
    puts outBuffer                  ;print the quotient
    puts point_sign
get_fractions:
    mov ax, dx
    mov bx, 100
    mul bx                          ;get remainder in fractions
    xor dx, dx
    mov bx, si
    div bx
    mov cx, ax
    xor eax, eax
    mov ax, cx
    cmp ax, 10                      ;if the fractions part is less than 10, we need to manually print the beginning zero
    jl extra_zero
    jmp print_fractions
extra_zero:
    puts zero
print_fractions:
    i2a eax, outBuffer
    puts outBuffer                  ;print the remainder in fractions
finish_prog:
    puts nwln
    push 0
    call ExitProcess
