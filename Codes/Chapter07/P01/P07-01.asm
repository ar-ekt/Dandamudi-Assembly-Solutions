global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG1 db "multiplicand (-128 <= n <= 127): ", 0
    inMSG2 db "multiplier (-128 <= n <= 127): ", 0
    outMSG db "result: ", 0
    negative_sign db "-", 0
    nwln db 10, 0

section .bss
    inBuffer resb 10
    multiplicand resb 1
    multiplier resb 1
    sign resb 1
    result resw 1
    outBuffer resb 10

section .code
_start:
    xor al, al
    mov [sign], al
input_multiplicand:
    puts inMSG1
    fgets inBuffer, 10
    mov ebx, inBuffer
    mov al, [inBuffer]
    cmp al, '-'
    je set_sign
    jmp set_multiplicand
set_sign:
    inc ebx
    mov al, 1
    mov [sign], al
set_multiplicand:
    a2i 10, ebx
    mov [multiplicand], al
input_multiplier:
    puts inMSG2
    fgets inBuffer, 10
    mov ebx, inBuffer
    mov al, [inBuffer]
    cmp al, '-'
    je check_and_reset_sign
    jmp set_multiplier
check_and_reset_sign:
    inc ebx
    mov al, [sign]
    cmp al, 1
    je reset_sign
    mov al, 1
    mov [sign], al
    jmp set_multiplier
reset_sign:
    xor al, al
    mov [sign], al
set_multiplier:
    a2i 10, ebx
    mov [multiplier], al
call_multi_proc:
    push result
    push multiplicand
    push multiplier
    call my_mult
add_sign_and_print:
    puts outMSG
    mov al, [sign]
    cmp al, 1
    je check_zero_1
    jmp print_result
check_zero_1:
    mov bl, [multiplicand]
    cmp bl, 0
    je print_result
check_zero_2:
    mov bl, [multiplier]
    cmp bl, 0
    je print_result
print_sign:
    puts negative_sign
print_result:
    xor eax, eax
    mov ax, [result]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
finish_prog:
    push 0
    call ExitProcess


;proc my_mult multiplies two 8 bit signed integers using only shift and add instructions
my_mult:
    enter 0, 0
    pusha
    xor dx, dx                      ;result
    mov ch, 1                       ;mask
    xor cl, cl                      ;shift count
mult_loop:
    cmp cl, 8
    je finish_mult
    mov edi, [ebp+12]
    mov al, [edi]                   ;multiplicand
    mov edi, [ebp+8]
    mov bl, [edi]                   ;multiplier
    and bl, ch
    cmp bl, ch
    je bit_is_1
    shl ch, 1
    inc cl
    jmp mult_loop
bit_is_1:
    xor ah, ah
    shl ax, cl
    add dx, ax
    shl ch, 1
    inc cl
    jmp mult_loop
finish_mult:
    mov edi, [ebp+16]
    mov [edi], dx
    popa
    leave
    ret 12
