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
    
    MSG_STRING_INPUT db "Enter name: ", 0
    MSG_OUTPUT db "Result: ", 0
    
section .bss
    buffer resb MAX_STRING_SIZE
    sentence resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets sentence, MAX_STRING_SIZE
    
    push sentence
    call reverse_sentence
    
    puts MSG_OUTPUT
    puts sentence
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

reverse_sentence:
    %define sentence DWORD [EBP+8]
    enter 0,0
    pushad
    
    mov ESI, sentence
    mov [ESI-1], BYTE 32
    push ESI
    call str_end
    add ESI, EAX
sentence_mov_loop:
    ; find first character that is not blank before the place ESI is pointing
    dec ESI
    push ESI
    call first_non_blank_backward
    sub ESI, EAX
    ; find first blank before the place ESI is pointing
    push ESI
    call first_blank_backward
    sub ESI, EAX
    inc ESI
    inc ESI
    ; move word
    push EAX
    push buffer
    push ESI
    call str_ncat
    ; check end of loop
    cmp ESI, sentence
    jle reverse_sentence_done
    ; add a space
    push BYTE 1
    push buffer
    push SPACE
    call str_ncat
    jmp sentence_mov_loop
reverse_sentence_done:
    mov ESI, buffer
    mov EDI, sentence
    push ESI
    call str_end
    push EAX
    push sentence
    push buffer
    call str_ncpy
    popad
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
    mov [EDI], BYTE 0
    mov EAX, string1
    clc
str_ncpy_done:
    popad
    leave
    ret 12

str_ncat:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0,0
    pushad
    mov ESI, string2
    mov EDI, string1
    push EDI
    call str_end
    add EDI, EAX
    mov ECX, num
    cld
    rep movsb
    mov [EDI], BYTE 0
    mov EAX, string1
    clc
str_ncat_done:
    popad
    leave
    ret 12

first_non_blank_backward:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    std
    mov AL, 32
    repe scasb
    mov EAX, string
    sub EAX, EDI
    clc
    jmp SHORT first_non_blank_backward_done
first_non_blank_backward_no_string:
    stc
first_non_blank_backward_done:
    pop ES
    pop EDI
    pop ECX
    leave
    ret 4

first_blank_backward:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    push ES
    mov EDI, string
    std
    mov AL, 32
    repne scasb
    mov EAX, string
    sub EAX, EDI
    clc
    jmp SHORT first_blank_backward_done
first_blank_backward_no_string:
    stc
first_blank_backward_done:
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
