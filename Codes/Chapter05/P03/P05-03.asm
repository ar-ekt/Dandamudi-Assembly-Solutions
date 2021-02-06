%INCLUDE "lib.h"
global _start

section .data
    num1_msg db "First number:  ", 0
    num2_msg db "Second number: ", 0
    num3_msg db "Third number:  ", 0
    max_msg db "Maximum number is ", 0
    endl db 10, 0

section .bss
    inp_buffer resb 12

section .code
_start:
    puts num1_msg
    fgets inp_buffer, 12
    a2i 12, inp_buffer
    push eax        ; push first number onto stack
    puts num2_msg
    fgets inp_buffer, 12
    a2i 12, inp_buffer
    push eax        ; push second number onto stack
    puts num3_msg
    fgets inp_buffer, 12
    a2i 12, inp_buffer
    push eax        ; push third number onto stack
    call max
    puts endl
    puts max_msg
    i2a eax, inp_buffer
    puts inp_buffer ; display maximum number returned in EAX
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE NUM1 DWORD [EBP + 16]
%DEFINE NUM2 DWORD [EBP + 12]
%DEFINE NUM3 DWORD [EBP + 8]

;--------------------------proc max---------------------------;
; procedure max receives three integers via stack and returns ;
; the maximum of the three in EAX.                            ;
;-------------------------------------------------------------;

max:
    enter 0, 0
    mov eax, NUM1    ; load EAX with first number
    cmp eax, NUM2
    jg next_cmp
    mov eax, NUM2    ; if second number is greater than first number, load EAX with it
next_cmp:
    cmp eax, NUM3
    jg max_done
    mov eax, NUM3    ; if third number is greater than other two, load EAX with it
max_done:
    leave
    ret 12