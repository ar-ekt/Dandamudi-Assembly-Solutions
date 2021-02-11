global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG db "enter a positive integer: ", 0
    outMSG db "recursive product of all digits: ", 0
    errMSG db "error. negative number received", 0
    nwln db 10, 0

section .bss
    inBuffer resb 15
    tempBuffer resb 15
    outBuffer resb 5

section .code
_start:
    puts inMSG
    fgets inBuffer, 100
    mov EBX, inBuffer
    call sign_test
    cmp EBX, 0
    je terminate_with_error
    push inBuffer
    push tempBuffer
    call strcpy
    push outBuffer
    push tempBuffer
    call recursive_mult_digits
    puts outMSG
    puts outBuffer
    puts nwln
    jmp finish_prog
terminate_with_error:
    puts errMSG
    puts nwln
finish_prog:
    push 0
    call ExitProcess

;proc recursive_mult_digits -> recursively multiplies all digits of a number until the result fits in one digit
recursive_mult_digits:
    enter 0, 0
    pusha
    mov EBX, [EBP+8]                ;pointer to tempBuffer
    mov EAX, 1                      ;holds product
    xor ESI, ESI                    ;holds index
mult_loop:
    xor EDX, EDX
    mov DL, [EBX+ESI]
    cmp DL, 0
    je reached_end
    sub DL, 48
    mul EDX
    inc ESI
    jmp mult_loop
reached_end:
    i2a EAX, EBX
    mov CL, [EBX+1]
    cmp CL, 0
    je finish_mult
    mov EAX, 1
    xor ESI, ESI
    jmp mult_loop
finish_mult:
    mov EDX, [EBP+12]               ;pointer to outBuffer
    i2a EAX, EDX
    popa
    leave
    ret 8

;proc strcpy
strcpy:
    enter 0, 0
    pusha
    mov EAX, [EBP+8]                ;dest
    mov EBX, [EBP+12]               ;src
    xor ESI, ESI
copy_loop:
    mov DL, [EBX+ESI]
    cmp DL, 0
    je termiante_string
    mov [EAX+ESI], DL
    inc ESI
    jmp copy_loop
termiante_string:
    mov [EAX+ESI], BYTE 0
finish_copy:
    popa
    leave
    ret 8

;proc sign_test -> receives pointer to input buffer in EBX, returns result in EBX
sign_test:
    push AX
    mov AL, [EBX]
    cmp AL, '-'
    je negative_number
positive_number:
    mov EBX, 1
    jmp finish_test
negative_number:
    mov EBX, 0
finish_test:
    pop AX
    ret