global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro geti 0
    fgets buffer, 15
    a2i 15, buffer
%endmacro

section .data
    MAX_STRING_SIZE EQU 100
    NULL EQU NULL
    
    NEWLINE db 10, NULL
    
    MSG_STRING_INPUT db "Enter string to be copied: ", NULL
    MSG_NUM_INPUT db "Enter number of characters to be copied from source: ", NULL
    
    MSG_OUTPUT db "Result: ", NULL
    
section .bss
    buffer resb MAX_STRING_SIZE
    string1 resb MAX_STRING_SIZE
    string2 resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string2, MAX_STRING_SIZE
    puts MSG_NUM_INPUT
    geti
    
    push EAX
    push string1
    push string2
    call str_ncpy
    
    puts MSG_OUTPUT
    puts string1
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess
 
;--------------------proc str_ncpy--------------------;
; Receives two string pointers. If string2 is not a   ;
; string, CF is set otherwise, at most the first num  ;
; characters of string2 is copied to string1 and the  ;
; offeset of string1 is returned in EAX with CF = 0.  ;
;-----------------------------------------------------;
str_ncpy:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0, 0
    push EAX
    push ECX
    push EDI
    push ESI
    
    mov EDI, string1              ; copy string1 pointer to EDI
    mov ESI, string2              ; copy string2 pointer to ESI
    push ESI
    call str_len                  ; string2 length
    jc str_ncpy_no_string
                                  ; ECX = min(num, string2_length)
    cmp num, EAX
    jl str_ncpy_num_lower
    jmp str_ncpy_length_lower
str_ncpy_num_lower:
    mov ECX, num
    jmp str_ncpy_continue
str_ncpy_length_lower:
    mov ECX, EAX
    jmp str_ncpy_continue
str_ncpy_continue:
    cld                           ; forward direction
    rep movsb                     ; move first ECX characters from string2 to string1
    mov EDI, NULL                 ; set NULL to end of string1
    mov EAX, string1
    clc                           ; clear carry to indicate no error
    jmp SHORT str_ncpy_done     
str_ncpy_no_string:
    stc                           ; carry set => no string
str_ncpy_done:
    pop ESI
    pop EDI
    pop ECX
    pop EAX
    leave
    ret 12                        ; clear stack and return

;-----------------------proc str_len-----------------------;
; Receives a string pointer. If not a string, CF is set    ;
; otherwise, string length is returned in EAX with CF = 0. ;
;----------------------------------------------------------;
str_len:
    %define string1 DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    mov EDI, string1              ; copy string pointer to EDI
    mov ECX, MAX_STRING_SIZE      ; need to terminate loop if EDI is not pointing to a string
    cld                           ; forward search
    mov AL, NULL                  ; NULL character
    repne scasb
    jcxz str_len_no_string        ; if ECX = 0, not a string
    dec EDI                       ; back up to point to NULL
    mov EAX, EDI
    sub EAX, string1              ; string length in EAX
    clc                           ; clear carry to indicate no error
    jmp SHORT str_len_done 
str_len_no_string:
    stc                           ; carry set => no string
str_len_done:
    pop EDI
    pop ECX
    leave
    ret 4                         ; clear stack and return