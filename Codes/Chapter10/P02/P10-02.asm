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
    
    MSG_STRING1_INPUT db "Enter first string: ", 0
    MSG_STRING2_INPUT db "Enter second string: ", 0
    MSG_NUMBER_INPUT db "Enter maximum number of characters to compare: ", 0
    
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb 100
    string1 resb 100
    string2 resb 100

section .code
_start:
    puts MSG_STRING1_INPUT
    fgets string1, 100
    puts MSG_STRING2_INPUT
    fgets string2, 100
    puts MSG_NUMBER_INPUT
    geti
    
    push EAX
    push string2
    push string1
    call str_ncmp
    
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

str_ncmp:
    %define string1 DWORD [EBP+8]
    %define string2 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0, 0
    push ECX
    push EDI
    push ESI
    push DS
    push ES
    mov EDI, string2
    push ES
    push EDI
    call str_len
    jc str_ncmp_no_string
    cmp num, EAX
    jl num_lower
    mov ECX, EAX
    inc ECX
    jmp str_ncmp_continue
num_lower:
    mov ECX, num
str_ncmp_continue:
    mov ESI, string1
    cld
    repe cmpsb
    je same
    ja above
below:
    mov EAX, -1
    clc
    jmp SHORT str_ncmp_done
same:
    xor EAX, EAX
    clc
    jmp SHORT str_ncmp_done
above:
    mov EAX, 1
    clc
    jmp SHORT str_ncmp_done
str_ncmp_no_string:
    stc
str_ncmp_done:
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
