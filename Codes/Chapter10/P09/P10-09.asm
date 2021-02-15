global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_STRING_SIZE EQU 100
    NEWLINE db 10, 0
    SPACE db 32, 0
    
    MSG_STRING1_INPUT db "Enter first string: ", 0
    MSG_STRING2_INPUT db "Enter second string: ", 0
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb MAX_STRING_SIZE
    string1 resb MAX_STRING_SIZE
    string2 resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING1_INPUT
    fgets string1, MAX_STRING_SIZE
    puts MSG_STRING2_INPUT
    fgets string2, MAX_STRING_SIZE
    
    push string1
    push string2
    call str_match
    ; 0 if they match, 1 if not
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

str_match:
    %define string1 DWORD [EBP+8]
    %define string2 DWORD [EBP+12]
    enter 0,0
    
    push string1
    call str_upper
    
    push string2
    call str_upper
    
    push string1
    push string2
    call str_cmp
str_match_done:
    leave
    ret 8

str_cmp:
    %define string1 DWORD [EBP+8]
    %define string2 DWORD [EBP+12]
    enter 0, 0
    push ECX
    push EDI
    push ESI
    mov EDI, string2
    push EDI
    call str_len
    jc str_cmp_no_string
    mov ECX, EAX
    inc ECX
    mov ESI, string1
    cld
    repe cmpsb
    je same
not_same:
    mov EAX, 1
    clc
    jmp SHORT str_cmp_done
same:
    xor EAX, EAX
    clc
    jmp SHORT str_cmp_done
str_cmp_no_string:
    stc
str_cmp_done:
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 8

str_upper:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ESI
    push EBX
    mov ESI, string
    dec ESI
upper_loop:
    inc ESI
    cmp [ESI], BYTE 0
    je str_upper_done
    cmp [ESI], BYTE 'a'
    jl upper_loop
    cmp [ESI], BYTE 'z'
    jg upper_loop
is_lower:
    mov EBX, [ESI]
    sub EBX, 32
    mov [ESI], EBX
    jmp upper_loop
str_upper_done:
    pop EBX
    pop ESI
    leave
    ret 4

str_len:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    mov ECX, MAX_STRING_SIZE
    cld
    mov AL, 0
    repne scasb
    jcxz str_len_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    clc
    jmp SHORT str_len_done
str_len_no_string:
    stc
str_len_done:
    pop ES
    pop EDI
    pop ECX
    leave
    ret 4
