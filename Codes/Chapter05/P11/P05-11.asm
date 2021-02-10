%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input a name in the format <first-name MI last-name>: ", 10, 0
    result_msg db "The name in the format <last-name, first-name MI>: ", 10, 0
    comma_space db ', ', 0
    endl db 10, 0

section .bss
    string resb 41

section .code
_start:
    puts prompt_msg
    fgets string, 41
    push string
    puts result_msg
    call rearrange
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE STRING DWORD [EBP + 8]
%DEFINE BUFFER DWORD [EBP - 100]

;-------------------------proc rearrange--------------------------;
; this procedure takes a string pointer, representing a person's  ;
; name, in the format first-name⊔MI⊔last-name via the stack and  ;
; displays the name in the format last-name,⊔first-name⊔MI where ;
; ⊔ indicates a blank character.                                  ;
;-----------------------------------------------------------------;

rearrange:
    enter 100, 0
    push eax
    push ebx
    push edx
    mov ebx, STRING
    mov edx, BUFFER
find_lastname_p1:
    inc ebx
    cmp [ebx], byte ' '
    je find_lastname_p2
    jmp find_lastname_p1
find_lastname_p2:
    inc ebx
    cmp [ebx], byte ' '
    je cut_lastname
    jmp find_lastname_p2
cut_lastname:
    inc ebx
    cmp [ebx], byte 0
    je display_lastname
    mov eax, [ebx]
    mov [edx], eax
    inc edx
    jmp cut_lastname
display_lastname:
    mov [edx], byte 0
    puts BUFFER
    puts comma_space
    mov ebx, STRING
    mov edx, BUFFER
    dec ebx
cut_firstname_mi_p1:
    inc ebx
    cmp [ebx], byte ' '
    je cut_firstname_mi_p1_done
    mov eax, [ebx]
    mov [edx], eax
    inc edx
    jmp cut_firstname_mi_p1
cut_firstname_mi_p1_done:
    mov [edx], byte ' '
    inc edx
cut_firstname_mi_p2:
    inc ebx
    cmp [ebx], byte ' '
    je display_firstname_mi
    mov eax, [ebx]
    mov [edx], eax
    inc edx
    jmp cut_firstname_mi_p2
display_firstname_mi:
    mov [edx], byte 0
    puts BUFFER
    puts endl
    pop edx
    pop ebx
    pop eax
    leave
    ret 4