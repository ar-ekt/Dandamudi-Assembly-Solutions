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
    LINE db "|", 0
    
    MSG_STRING_INPUT db "Enter string: ", 0
    MSG_SUBSTRING_INPUT db "Enter substring: ", 0
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb MAX_STRING_SIZE
    string resb MAX_STRING_SIZE
    substring resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    puts MSG_SUBSTRING_INPUT
    fgets substring, MAX_STRING_SIZE
    
    push substring
    push string
    call str_str
    
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

str_str:
    %define string DWORD [EBP+8]
    %define sub_string DWORD [EBP+12]
    enter 0,0
    push EBX
    push ESI
    push EDI
    mov EDI, sub_string
    mov ESI, string
    xor EBX, EBX
    dec ESI
find_loop:
    inc EBX
    inc ESI
    cmp [ESI], BYTE 0
    je sub_string_not_found
    push EDI
    push ESI
    call str_cmp
    cmp EAX, 0
    je sub_string_found
    jmp find_loop
sub_string_not_found:
    mov EAX, -1
    jmp str_str_done
sub_string_found:
    mov EAX, EBX
str_str_done:
    pop EDI
    pop ESI
    pop EBX
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
    dec ECX
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

str_len:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    mov EDI, string
    mov ECX, MAX_STRING_SIZE
    cld
    mov AL, 0
    repne scasb
    jcxz str_len_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    inc EAX
    clc
    jmp SHORT str_len_done
str_len_no_string:
    stc
str_len_done:
    pop EDI
    pop ECX
    leave
    ret 4
