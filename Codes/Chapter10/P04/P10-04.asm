global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    MAX_STRING_SIZE EQU 100
    NEWLINE db 10, 0
    
    MSG_STRING_INPUT db "Enter string: ", 0
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    string resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    
    push string
    call remove_leading_blanks
    
    puts MSG_OUTPUT
    puts string
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

remove_leading_blanks:
    %define string DWORD [EBP+8]
    enter 0,0
    push ECX
    push EDI
    push ESI
    push DS
    push ES
    
    mov ESI, string
    push ESI
    call first_non_blank
    jc remove_leading_blanks_no_string
    add ESI, EAX
    
    push ESI
    call str_len
    jc remove_leading_blanks_no_string
    mov ECX, EAX
    mov EDI, string
    cld
    rep movsb
    
    mov [EDI], BYTE 0
    mov EAX, string
    clc
    jmp SHORT remove_leading_blanks_done
remove_leading_blanks_no_string:
    stc
remove_leading_blanks_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 12

first_non_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    mov ECX, MAX_STRING_SIZE
    cld
    mov AL, 32
    repe scasb
    jcxz first_non_blank_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    clc
    jmp SHORT first_non_blank_done
first_non_blank_no_string:
    stc
first_non_blank_done:
    pop ES
    pop EDI
    pop ECX
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
