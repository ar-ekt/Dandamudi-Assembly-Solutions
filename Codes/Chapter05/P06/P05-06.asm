%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input a string: ", 10, 0
    reverse_msg db "String in reverse order: ", 10, 0
    endl db 10, 0

section .bss
    string resb 41

section .code
_start:
    puts prompt_msg
    fgets string, 41
    push string         ; push pointer to string onto stack
    call reverse
    puts reverse_msg
    puts string         ; display string that it is in reverse order now
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE STRING [EBP + 8]

;-----------------------proc reverse-------------------------;
; reverse procedure receives a pointer to a character string ;
; (terminated by a NULL character) and reverses the string.  ;
;------------------------------------------------------------;

reverse:
    enter 0, 0
    push eax
    push ebx
    mov ebx, STRING
push_characters:
    cmp [ebx], byte 0   ; check if we reached end of string
    je push_done
    xor ax, ax
    mov al, [ebx]       ; load AL with current character
    push ax             ; push character onto stack to be recived later
    inc ebx             ; increase pointer to point to next character
    jmp push_characters
push_done:
    mov ebx, STRING
pop_charactes:
    cmp [ebx], byte 0   ; check if we reached end of string
    je reverse_done
    pop ax              ; recive characters in backward order
    mov [ebx], al       ; and place them in original string in forward order
                        ; its logic: string[0] <- string[last_index + 0], string[1] <- string[last_index - 1] and so on ... 
    inc ebx             ; increase pointer to point to next character
    jmp pop_charactes
reverse_done:
    pop ebx
    pop eax
    leave
    ret 4