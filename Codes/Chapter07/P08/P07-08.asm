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
    outMSG db "rounded average: ", 0
    percentage_sign db "%", 0
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
check_fractions:
    mov cx, ax                      ;temporarily hold quotient
    mov ax, dx
    mov bx, 100
    mul bx                          ;get remainder in fractions
    xor dx, dx
    mov bx, si
    div bx
    cmp ax, 50                      ;if the fractions part is bigger than or equal to 0.5, round up, else, round down
    jge round_to_higher
    jmp round_to_lower
round_to_higher:
    mov ax, cx
    inc ax
    jmp get_percentage
round_to_lower:
    mov ax, cx
get_percentage:
    mov bx, 100
    mul bx
    mov bx, [maximum_score]
    div bx                          ;x/a = (100x/a)%
print_result:
    puts outMSG
    i2a eax, outBuffer
    puts outBuffer
    puts percentage_sign
    puts nwln
finish_prog:
    push 0
    call ExitProcess