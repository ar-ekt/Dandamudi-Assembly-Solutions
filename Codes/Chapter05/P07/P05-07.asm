%INCLUDE "lib.h"
global _start

section .data
    str_prompt_msg db "Please input a string: ", 0
    char_prompt_msg db "Please input a character: ", 0
    out_msg db "First occurrence of <", 0
    out_msg1 db "> in <", 0
    out_msg2 db "> is at index ", 0
    no_match_msg db "There is no match!", 10, 0
    endl db 10, 0

section .bss
    string resb 41
    char resb 3
    position resb 41

section .code
_start:
    puts str_prompt_msg
    fgets string, 41
    push string             ; push pointer to string onto stack
    puts char_prompt_msg
    fgets char, 3
    push char               ; push pointer to character onto stack
    call locate
    cmp eax, 0              ; EAX < 0 if there is no match
    jl no_match
    puts out_msg
    puts char
    puts out_msg1
    puts string
    puts out_msg2
    i2a eax, position
    puts position
    puts endl
    jmp done
no_match:
    puts no_match_msg
done:
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE STRING [EBP + 12]
%DEFINE CHAR [EBP + 8]

;-------------------------------------proc locate---------------------------------------;
; this procedure locates a character in a given string. procedure receives a pointer to ;
; a NULL-terminated character string and the character to be located. when the first    ;
; occurrence of the character is located, its position is returned in EAX. if no match  ;
; is found, a negative value is returned.                                               ;
;---------------------------------------------------------------------------------------;

locate:
    enter 0, 0
    push ebx
    push ecx
    push edx
    xor eax, eax
    mov eax, -1             ; load EAX with -1, if there is no match this value doesn't change and will be returned
    mov ebx, STRING
    mov ecx, CHAR
    mov dl, [ecx]           ; DL holds the character that we are looking for
    xor ecx, ecx            ; ECX is our counter
loop_on_string:
    cmp [ebx], byte 0       ; check if we reached end of string
    je locate_done
    cmp [ebx], dl           ; check if current character is the character that we are looking for
    je char_found           ; goto char_found if it was
    inc ecx                 ; otherwise increase counter
    inc ebx                 ; and increase pointer to point to next character
    jmp loop_on_string
char_found:
    mov eax, ecx            ; change EAX value to index that character was found at
locate_done:
    pop edx
    pop ecx
    pop ebx
    leave
    ret 8