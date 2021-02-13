global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro geti 0
    fgets buffer, 15
    a2i 15, buffer
%endmacro

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    NEWLINE db 10, 0
    
    MSG_STRING_INPUT db "Enter string to be copied: ", 0
    MSG_NUM_INPUT db "Enter number of characters to be copied from source: ", 0
    
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb 100
    string1 resb 100
    string2 resb 100

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string1, 100
    puts MSG_NUM_INPUT
    geti
    
    push EAX
    push string1
    push string2
    call str_ncpy
    
    puts MSG_OUTPUT
    puts string2
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

str_ncpy:
    %define string1 DWORD [EBP+8]
    %define string2 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0,0
    push ECX
    push EDI
    push ESI
    push DS
    push ES
    mov ESI, string2
    push DS
    push ESI
    call str_len
    jc str_ncpy_no_string
    cmp num, EAX
    jl num_lower
    mov ECX, EAX
    jmp str_ncpy_continue
num_lower:
    mov ECX, num
str_ncpy_continue:
    mov EDI, string1
    cld
    rep movsb
    mov EAX, string1
    clc
    jmp SHORT str_ncpy_done
str_ncpy_no_string:
    stc
str_ncpy_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 12

str_len:
    %define string DWORD [EBP+8]
    enter 0, 0
    mov EDI, string
    mov ECX, 100
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
    leave
    ret 4
