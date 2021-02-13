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
    
    MSG_STRING_INPUT db "Enter string: ", 0
    
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb 100
    string1 resb 100
    string2 resb 100

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string2, 100
    
    push string1
    push string2
    call str_cln_leading_blnks
    
    puts MSG_OUTPUT
    puts string1
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

str_cln_leading_blnks:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    enter 0,0
    push ECX
    push EDI
    push ESI
    push DS
    push ES
    mov ESI, string2
    push DS
    push ESI
    call str_frst_non_blank
    jc str_cln_leading_blnks_no_string
    add ESI, EAX
    push DS
    push ESI
    call str_len
    jc str_cln_leading_blnks_no_string
    mov ECX, EAX
    mov EDI, string1
    cld
    rep movsb
    mov EAX, string1
    clc
    jmp SHORT str_cln_leading_blnks_done
str_cln_leading_blnks_no_string:
    stc
str_cln_leading_blnks_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 12

str_frst_non_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    mov ECX, 100
    cld
    mov AL, 32
    repe scasb
    jcxz str_frst_non_blank_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    clc
    jmp SHORT str_frst_non_blank_done
str_frst_non_blank_no_string:
    stc
str_frst_non_blank_done:
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
    pop ES
    pop EDI
    pop ECX
    leave
    ret 4
