%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input a set of integers: (input can be terminated by entering 0 or by entering 20 integers)", 10, 0
    open_parenthes db ") ", 0
    sum_msg db "Sum of integers is ", 0
    endl db 10, 0

section .bss
    int_array resd 20
    inp_buffer resb 41

section .code
_start:
    puts prompt_msg
    puts endl
    mov ebx, int_array
    mov ecx, 20         ; set loop counter to maximum size of array
    xor edi, edi        ; EDI will save size of integers
read_loop:
    mov eax, edi
    inc eax
    i2a eax, inp_buffer
    puts inp_buffer
    puts open_parenthes
    fgets inp_buffer, 41
    a2i 41, inp_buffer
    cmp eax, 0          ; check if inputed integer is zero
    je read_loop_done
    mov [ebx], eax      ; otherwise save it in array
    add ebx, 4          ; and increase pointer to point to next element of array (increased by 4 because each integer occupies 4 byte)
    inc edi             ; and inrease size of array
    loop read_loop
read_loop_done:
    push int_array      ; push pointer to array onto stack
    push edi            ; push size of array onto stack
    call sum
    puts endl
    puts sum_msg
    i2a eax, inp_buffer ; display EAX that now contains sum of array
    puts inp_buffer
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE ARRAY [EBP + 12]
%DEFINE SIZE DWORD [EBP + 8]

;---------------------------proc sum------------------------------;
; this procedure receives a pointer to an integer array and its   ;
; size via the stack, and returns sum of integer elements in EAX. ;
;-----------------------------------------------------------------;

sum:
    enter 0, 0
    push ebx
    push ecx
    mov ebx, ARRAY
    mov ecx, SIZE       ; set loop counter to size of array
    xor eax, eax        ; EAX will save sum of integers
loop_on_array:
    add eax, [ebx]
    add ebx, 4
    loop loop_on_array
    pop ecx
    pop ebx
    leave
    ret 8