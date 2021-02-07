%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input a string: ", 10, 0
    out_msg db "String without leadinng blanks: " , 10, 0
    endl db 10, 0

section .bss
    string resb 41

section .code
_start:
    puts prompt_msg
    fgets string, 41
    push string         ; push pointer to string onto stack
    call remove_leading_blanks
    puts out_msg
    puts string         ; display string that is without leading blanks now
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE STRING [EBP + 8]

;---------------------------proc remove_leading_blanks-------------------------------;
; this procedure receives a string via the stack (i.e., the string pointer is passed ;
; to the procedure) and removes all leading blank characters in the string.          ;
;------------------------------------------------------------------------------------;

remove_leading_blanks:
    enter 0, 0
    push eax
    push ebx
    push ecx
    mov ebx, STRING     ; use EBX to skip blanks and find the start of modified string
    mov eax, STRING     ; use EAX to overwrite result (EBX) to given string
find_start:
    cmp [ebx], byte 0   ; check if we reached end of string
    je overwrite_string
    cmp [ebx], byte ' '
    jne overwrite_string
    inc ebx
    jmp find_start
overwrite_string:
    cmp [ebx], byte 0   ; check if we reached end of string
    je remove_leading_blanks_done
    mov cl, [ebx]
    mov [eax], cl
    inc eax
    inc ebx
    jmp overwrite_string
remove_leading_blanks_done:
    mov [eax], byte 0   ; specify end of new string
    pop ecx
    pop ebx
    pop eax
    leave
    ret 4