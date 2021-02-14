global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    MAX_STRING_SIZE EQU 100
    SPACE EQU 32
    NEWLINE db 10, 0
    
    MSG_STRING_INPUT db "Enter string: ", 0
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb MAX_STRING_SIZE
    string resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    
    push string
    call str_cln_blnks
    
    puts MSG_OUTPUT
    puts string
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

str_cln_blnks:
    %define string DWORD [EBP+8]
    enter 0,0
    push ECX
    push EDI
    push ESI
    push DS
    push ES
    
    mov ESI, string
    
    push ESI
    call str_len
    jc str_cln_blnks_no_string
    mov EBX, EAX
    add EBX, ESI
    mov [EBX], BYTE SPACE
    
    mov EDI, buffer
    
mov_loop:
    push ESI
    call str_frst_non_blank
    cmp EAX, 0
    je mov_loop_done
    add ESI, EAX
    
    push ESI
    call str_frst_blank
    mov ECX, EAX
    cld
    rep movsb
    
    cmp EBX, ESI
    je mov_loop_done
    
    mov [EDI], BYTE SPACE
    inc EDI
    jmp mov_loop
    
mov_loop_done:
    mov ESI, buffer
    push ESI
    call str_len
    mov ECX, EAX
    mov EDI, string
    cld
    rep movsb
    mov [EDI], BYTE 0
    mov EAX, string
    clc
    jmp SHORT str_cln_blnks_done
str_cln_blnks_no_string:
    stc
str_cln_blnks_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 12

str_frst_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push EDI
    push ES
    mov EDI, string
    mov ECX, MAX_STRING_SIZE
    cld
    mov AL, SPACE
    repne scasb
    jcxz str_frst_blank_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    clc
    jmp SHORT str_frst_blank_done
str_frst_blank_no_string:
    stc
str_frst_blank_done:
    pop ES
    pop EDI
    leave
    ret 4

str_frst_non_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    mov ECX, MAX_STRING_SIZE
    cld
    mov AL, SPACE
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
