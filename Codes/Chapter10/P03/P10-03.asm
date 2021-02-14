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
    call is_palindrome

    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

is_palindrome:
    %define string DWORD [EBP+8]
    enter 0,0
    push ECX
    push EDI
    push ESI
    push DS
    push ES
    
    push string
    call str_clean
    
    push string
    push buffer
    call str_reverse
    
    push string
    call str_len
    jc is_palindrome_no_string
    mov ECX, EAX
    
    mov ESI, string
    mov EDI, buffer
    cld
    repe cmpsb
    jne is_not_palindrome
    mov EAX, 1
    clc
    jmp SHORT is_palindrome_done
    
is_not_palindrome:
    mov EAX, 0
    clc
is_palindrome_no_string:
    stc
is_palindrome_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 12


str_clean:
    %define string DWORD [EBP+8]
    enter 0,0
    push EAX
    push EDI
    push ESI
    push DS
    push ES
    
    mov EDI, buffer
    mov ESI, string
    dec ESI
clean_loop:
    inc ESI
    cmp [ESI], BYTE 0
    je clean_loop_done
lower_check:
    cmp [ESI], BYTE 'a'
    jl digit_check
    cmp [ESI], BYTE 'z'
    jg digit_check
    mov EAX, [ESI]
    mov [EDI], EAX
    inc EDI
    jmp clean_loop
digit_check:
    cmp [ESI], BYTE '0'
    jl upper_check
    cmp [ESI], BYTE '9'
    jg upper_check
    mov EAX, [ESI]
    mov [EDI], EAX
    inc EDI
    jmp clean_loop
upper_check:
    cmp [ESI], BYTE 'A'
    jl clean_loop
    cmp [ESI], BYTE 'Z'
    jg clean_loop
    mov EAX, [ESI]
    add EAX, 32
    mov [EDI], EAX
    inc EDI
    jmp clean_loop
clean_loop_done:
    mov ESI, buffer
    push ESI
    call str_len
    mov ECX, EAX
    mov EDI, string
    cld
    rep movsb
    mov [EDI], BYTE 0
str_clean_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop EAX
    leave
    ret 4


str_reverse:
    %define string1 DWORD [EBP+8]
    %define string2 DWORD [EBP+12]
    enter 0, 0
    push ECX
    push EAX
    push EDI
    push ESI
    push DS
    push ES
    
    mov ESI, string1
    mov EDI, string2
    push ESI
    call str_len
    add ESI, EAX
    dec ESI
    mov ECX, EAX
reverse_loop:
    mov EAX, [ESI]
    mov [EDI], EAX
    inc EDI
    dec ESI
    loop reverse_loop
    mov [EDI], BYTE 0
str_reverse_done:
    pop ES
    pop DS
    pop ESI
    pop EDI
    pop EAX
    pop ECX
    leave
    ret 8


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
    
