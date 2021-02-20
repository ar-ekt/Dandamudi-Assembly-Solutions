global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    MAX_STRING_SIZE EQU 100
    NULL EQU 0
    
    NEWLINE db 10, NULL
    SPACE db 32, NULL
    COMMA db ",", NULL
    
    MSG_STRING_INPUT db "Enter name: ", NULL
    MSG_OUTPUT db "Result: ", NULL
    
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
    
_end:
    push DWORD 0
    call ExitProcess

;---------------------proc rearrange_name----------------------;
; Receives a string representing a person’s name in the format ;
; first-name MI last-name                                      ;
; that can contain multiple spaces between the names           ;
; and displays the name in the format                          ;
; last-name, first-name MI                                     ;
; with the last name in capital letters                        ;
;--------------------------------------------------------------;
rearrange_name:
    %define name DWORD [EBP+8]
    enter 0,0
    push ESI
    push EAX
    mov ESI, name                 ; copy name pointer to ESI
seprate_firstName:                ; copy first part of name to firstName
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
seprate_middleInitial:            ; copy second part of name to MI
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
seprate_lastName:                 ; copy last part of name to lastName
    push ESI
    call str_len
    push EAX
    push lastName
    push ESI
    call str_ncpy
    push lastName
    call str_upper
rearrange_name_done:
    puts MSG_OUTPUT
    puts lastName
    puts COMMA
    puts SPACE
    puts firstName
    puts SPACE
    puts MI
    puts NEWLINE
    pop EAX
    pop ESI
    leave
    ret 4                         ; clear stack and return

;------------------proc str_upper-------------------;
; Receives a string pointer. Converts all lowercase ;
; characters to uppercase.                          ;
;---------------------------------------------------;
str_upper:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ESI
    push EBX
    mov ESI, string               ; copy string pointer to ESI
    dec ESI
str_upper_loop:
    inc ESI
    cmp [ESI], BYTE NULL          ; check end of string
    je str_upper_done
    cmp [ESI], BYTE 'a'
    jl str_upper_loop
    cmp [ESI], BYTE 'z'
    jg str_upper_loop
    mov EBX, [ESI]
    sub EBX, 32                   ; convert to uppercase
    mov [ESI], EBX
    jmp str_upper_loop
str_upper_done:
    pop EBX
    pop ESI
    leave
    ret 4                         ; clear stack and return

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

;--------------------proc first_blank---------------------;
; Receives a string pointer If not a string, CF is set    ;
; otherwise, return place of first blank character in EAX ;
; with CF = 0.                                            ;
;---------------------------------------------------------;
first_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    
    mov EDI, string                  ; copy string pointer to EDI
    mov ECX, MAX_STRING_SIZE         ; need to terminate loop if EDI is not pointing to a string
    cld                              ; forward search
    mov AL, 32                       ; space character
    repne scasb
    jcxz first_blank_no_string       ; if ECX = 0, not a string
    dec EDI                          ; back up to point to blank
    mov EAX, EDI
    sub EAX, string                  ; blank place in EAX
    clc                              ; clear carry to indicate no error
    jmp SHORT first_blank_done
first_blank_no_string:
    stc                              ; carry set => no string
first_blank_done:
    pop EDI
    pop ECX
    leave
    ret 4                            ; clear stack and return

;-------------------proc first_non_blank-----------------;
; Receives a string pointer If not a string, CF is set   ;
; otherwise, return place of first character that is not ;
; blank in EAX with CF = 0.                              ;
;--------------------------------------------------------;
first_non_blank:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    
    mov EDI, string                  ; copy string pointer to EDI
    mov ECX, MAX_STRING_SIZE         ; need to terminate loop if EDI is not pointing to a string
    cld                              ; forward search
    mov AL, 32                       ; space character
    repe scasb
    jcxz first_non_blank_no_string   ; if ECX = 0, not a string
    dec EDI                          ; back up to point to blank
    mov EAX, EDI
    sub EAX, string                  ; nonblank place in EAX
    clc                              ; clear carry to indicate no error
    jmp SHORT first_non_blank_done
first_non_blank_no_string:
    stc                              ; carry set => no string
first_non_blank_done:
    pop EDI
    pop ECX
    leave
    ret 4                            ; clear stack and return

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