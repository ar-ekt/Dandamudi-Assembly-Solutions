%INCLUDE "lib.h"
global _start

section .data
    num1_msg db "First number:  ", 0
    num2_msg db "Second number: ", 0
    num3_msg db "Third number:  ", 0
    min_msg db "Minimum number is ", 0
    max_msg db "Maximum number is ", 0
    endl db 10, 0

section .bss
    inp_buffer resb 12
    min_int resd 12
    max_int resd 12

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
    push min_int    ; push pointer to min_int onto stack
    push max_int    ; push pointer to max_int onto stack
    call minmax
    puts endl
    puts min_msg
    i2a dword [min_int], inp_buffer
    puts inp_buffer ; display minimum number
    puts endl
    puts max_msg
    i2a dword [max_int], inp_buffer
    puts inp_buffer ; display maximum number
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE NUM1 DWORD [EBP + 24]
%DEFINE NUM2 DWORD [EBP + 20]
%DEFINE NUM3 DWORD [EBP + 16]
%DEFINE MIN [EBP + 12]
%DEFINE MAX [EBP + 8]

;-------------------------------proc minmax--------------------------------;
; procedure minmax receives three integers and two pointers to variables   ;
; min_int and max_int via stack and returns the minimum and the maximum of ;
; the three in min_int and max_int.                                        ;
;--------------------------------------------------------------------------;

minmax:
    enter 0, 0
    push eax
    push ebx
max:
    mov eax, NUM1    ; load EAX with first number
    cmp eax, NUM2
        jg max_next_cmp
    mov eax, NUM2    ; if second number is greater than first number, load EAX with it
max_next_cmp:
    cmp eax, NUM3
        jg max_done
    mov eax, NUM3    ; if third number is greater than other two, load EAX with it
max_done:
    mov ebx, MAX     ; load EBX with pointer to max_int
    mov [ebx], eax   ; save maximum in max_int
min:
    mov eax, NUM1    ; load EAX with first number
    cmp eax, NUM2
        jl min_next_cmp
    mov eax, NUM2    ; if second number is less than first number, load EAX with it
min_next_cmp:
    cmp eax, NUM3
        jl min_done
    mov eax, NUM3    ; if third number is less than other two, load EAX with it
min_done:
    mov ebx, MIN     ; load EBX with pointer to min_int
    mov [ebx], eax   ; save minimum in min_int
minmax_done:
    pop ebx
    pop eax
    leave
    ret 20