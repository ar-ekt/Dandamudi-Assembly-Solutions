%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input a set of integers: (input can be terminated by entering 0)", 10, 0
    open_parenthes db ") ", 0
    min_msg db "Minimum number is ", 0
    max_msg db "Maximum number is ", 0
    endl db 10, 0

section .bss
    inp_buffer resd 12
    min_int resd 12
    max_int resd 12

section .code
_start:
    puts prompt_msg
    puts endl
    xor edi, edi                    ; EDI will save size of integers
read_loop:
    mov eax, edi
    inc eax
    i2a eax, inp_buffer
    puts inp_buffer
    puts open_parenthes
    fgets inp_buffer, 41
    a2i 41, inp_buffer
    cmp eax, 0                      ; check if inputed integer is zero
    je read_loop_done
    push eax                        ; otherwise push it onto stack
    inc edi                         ; and inrease size of inputed integers
    jmp read_loop
read_loop_done:
    push edi                        ; push size of inputed integers onto stack
    push min_int                    ; push pointer to min_int onto stack
    push max_int                    ; push pointer to max_int onto stack
    call minmax
    puts endl
    puts min_msg
    i2a dword [min_int], inp_buffer
    puts inp_buffer                 ; display minimum number
    puts endl
    puts max_msg
    i2a dword [max_int], inp_buffer
    puts inp_buffer                 ; display maximum number
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE SIZE DWORD [EBP + 16]
%DEFINE MIN [EBP + 12]
%DEFINE MAX [EBP + 8]

;--------------------------------proc minmax---------------------------------;
; procedure minmax receives variable number of integers and their size along ;
; with two pointers to variables min_int and max_int via stack and returns   ;
; the minimum and the maximum of the integers in min_int and max_int.        ;
;----------------------------------------------------------------------------;

minmax:
    enter 0, 0
    push eax
    push ebx
    push ecx
    mov ecx, SIZE
    mov eax, [ebp + 20]         ; load EAX with first number (5 * 4 byte = 20 byte upper than EBP) and use it to save maximum number
    mov edi, 6                  ; use EDI to go through inputes (first one was at 5, so EDI starts from second number that is
                                ; in position 6 * 4 byte = 24 byte upper than EBP)
max_loop:
    dec ecx
    jz max_done
    cmp eax, [ebp + edi * 4]
    jge max_no_change
    mov eax, [ebp + edi * 4]    ; if current number was greater than current maximum, update maximum with it
max_no_change:
    inc edi                     ; increase EDI to access to next integer
    jmp max_loop
max_done:
    mov ebx, MAX                ; load EBX with pointer to max_int
    mov [ebx], eax              ; save maximum in max_int
    mov ecx, SIZE
    mov eax, [ebp + 20]         ; load EAX with first number (5 * 4 byte = 20 byte upper than EBP) and use it to save minimum number
    mov edi, 6                  ; use EDI to go through inputes (first one was at 5, so EDI starts from second number that is
                                ; in position 6 * 4 byte = 24 byte upper than EBP)
min_loop:
    dec ecx
    jz min_done
    cmp eax, [ebp + edi * 4]
    jle min_no_change
    mov eax, [ebp + edi * 4]    ; if current number was less than current minimum, update minimum with it
min_no_change:
    inc edi                     ; increase EDI to access to next integer
    jmp min_loop
min_done:
    mov ebx, MIN                ; load EBX with pointer to min_int
    mov [ebx], eax              ; save minimum in min_int
minmax_done:
    pop ecx
    pop ebx
    pop eax
    leave
    ret 16