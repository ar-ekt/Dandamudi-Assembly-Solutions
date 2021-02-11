
; the method used in the original PutInt8 is quite general and could be used with integers of any size
; this method on the other hand, is quite simple and straight-forward, but is not general at all

global _start
extern ExitProcess
%include "lib.h"

section .data
    newline db 10, 0
    negative_sign db "-", 0

section .bss
    outBuffer resb 10

section .code
_start:
    mov AL, -72                        ;enter your number here to test the procedure
    call PutInt8
    push 0
    call ExitProcess

;-----------------------------------------------------------
;PutInt8 procedure displays a signed 8-bit integer that is
;in AL register. All registers are preserved.
;-----------------------------------------------------------
PutInt8:
    push AX
    xor AH, AH
    test AL, 80H
    jz print_first_digit
negative_num:
    puts negative_sign
    neg AL
print_first_digit:
    mov BL, 100
    div BL
    xor EBX, EBX
    mov BL, AL
    cmp BL, 0
    je skip
    i2a EBX, outBuffer
    puts outBuffer
    jmp print_rest
skip:
    mov CL, 1                       ;set flag for not displaying beginning 0's
print_rest:
    mov BL, AH
    xor EAX, EAX
    mov AL, BL
    mov BL, 10
    div BL
print_second_digit:
    xor EBX, EBX
    mov BL, AL
    cmp BL, 0
    je check_and_skip
    i2a EBX, outBuffer
    puts outBuffer
    jmp print_third_digit
check_and_skip:
    cmp CL, 1
    je print_third_digit            ;if previous digit was 0, skip this 0 as well
    i2a EBX, outBuffer
    puts outBuffer
print_third_digit:
    xor EBX, EBX
    mov BL, AH
    i2a EBX, outBuffer
    puts outBuffer
    puts newline
finish_proc:
    ret