global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    MAX_STRING_SIZE EQU 100
    NEWLINE db 10, 0
    COMMA db ",", 0
    SPACE db " ", 0
    
    MSG_STRING_INPUT db "Enter name: ", 0
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    name resb MAX_STRING_SIZE
    firstName resb MAX_STRING_SIZE
    MI resb MAX_STRING_SIZE
    lastName resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets name, MAX_STRING_SIZE
    
    push name
    call rearrange_name
    
    puts MSG_OUTPUT
    puts lastName
    puts COMMA
    puts SPACE
    puts firstName
    puts SPACE
    puts MI
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

rearrange_name:
    %define name DWORD [EBP+8]
    enter 0,0
    push ESI
    push EAX
    mov ESI, name
seprate_firstName:
    push ESI
    call first_blank
    push EAX
    push firstName
    push ESI
    call str_ncpy
    add ESI, EAX
    push ESI
    call first_non_blank
    add ESI, EAX
seprate_middleInitial:
    push ESI
    call first_blank
    push EAX
    push MI
    push ESI
    call str_ncpy
    add ESI, EAX
    push ESI
    call first_non_blank
    add ESI, EAX
seprate_lastName:
    push ESI
    call str_end
    push EAX
    push lastName
    push ESI
    call str_ncpy
    push lastName
    call str_upper
rearrange_name_done:
    pop EAX
    pop ESI
    leave
    ret 12

str_ncpy:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0,0
    pushad
    mov ESI, string2
    mov EDI, string1
    mov ECX, num
    cld
    rep movsb
    mov EAX, string1
    clc
str_ncpy_done:
    popad
    leave
    ret 12

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

first_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    mov ECX, MAX_STRING_SIZE
    cld
    mov AL, 32
    repne scasb
    jcxz first_blank_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    clc
    jmp SHORT first_blank_done
first_blank_no_string:
    stc
first_blank_done:
    pop ES
    pop EDI
    pop ECX
    leave
    ret 4

str_end:
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
    jcxz str_end_no_string
    dec EDI
    mov EAX, EDI
    sub EAX, string
    clc
    jmp SHORT str_end_done
str_end_no_string:
    stc
str_end_done:
    pop ES
    pop EDI
    pop ECX
    leave
    ret 4
