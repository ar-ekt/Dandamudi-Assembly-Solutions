global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    MAX_STRING_SIZE EQU 100
    NULL EQU 0
    
    NEWLINE db 10, NULL
    SPACE db 32, NULL
    
    MSG_STRING_INPUT db "Enter string: ", NULL
    MSG_OUTPUT db "Result: ", NULL
    
section .bss
    buffer resb MAX_STRING_SIZE
    string resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    
    push string
    call remove_leading_and_duplicate_blanks
    
    puts MSG_OUTPUT
    puts string
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

;------------remove_leading_and_duplicate_blanks-------------;
; Receives a string pointer. If not a string, CF is set      ;
; otherwise, remove leading and duplicate blanks of string   ;
; and the offeset of string1 is returned in EAX with CF = 0. ;
;------------------------------------------------------------;
remove_leading_and_duplicate_blanks:
    %define string DWORD [EBP+8]
    enter 0,0
    push EBX
    push ECX
    push EDI
    push ESI
    
    mov ESI, string               ; copy string pointer to ESI
    push ESI
    call str_len                  ; string length
    jc remove_leading_and_duplicate_blanks_no_string
    mov EBX, EAX
    add EBX, ESI
    mov [EBX], BYTE 32            ; add an extra blank to the end of string
remove_leading_and_duplicate_blanks_loop:
    push ESI
    call first_non_blank          ; find next nonblank character
    add ESI, EAX                  ; point to next nonblank character
    
    push ESI
    call first_blank              ; find next blank character
    mov ECX, EAX
    push ECX
    push buffer
    push ESI
    call str_ncat                 ; add string from where ESI is pointing to next blank character to the end of buffer
    add ESI, ECX                  ; point to next blank character
    
    cmp EBX, ESI
    jle remove_leading_and_duplicate_blanks_loop_done
    
    push BYTE 1
    push buffer
    push SPACE
    call str_ncat                ; add one space to the end of buffer
    jmp remove_leading_and_duplicate_blanks_loop
remove_leading_and_duplicate_blanks_loop_done:
    push string
    push buffer
    call str_cpy                 ; copy buffer to string
    mov EAX, string
    clc
    jmp SHORT remove_leading_and_duplicate_blanks_done
remove_leading_and_duplicate_blanks_no_string:
    stc
remove_leading_and_duplicate_blanks_done:
    pop ESI
    pop EDI
    pop ECX
    pop EBX
    leave
    ret 12

;---------------------proc str_ncat----------------------;
; Receives two string pointers and a number. If string1  ;
; is not a string, CF is set otherwise, string2 will be  ;
; added to the end of string1 and the offeset of string1 ;
; is returned in EAX with CF = 0.                        ;
;--------------------------------------------------------;
str_ncat:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0,0
    push ECX
    push ESI
    push EDI
    mov ESI, string2              ; copy string2 pointer to ESI
    mov EDI, string1              ; copy string1 pointer to EDI
    push EDI
    call str_len                  ; string1 length
    jc str_ncat_no_string
    add EDI, EAX                  ; point to end of string1
    mov ECX, num
    cld                           ; forward direction
    rep movsb
    mov [EDI], BYTE NULL          ; add NULL character to the end of string1
    mov EAX, string1
    clc
    jmp str_ncat_done
str_ncat_no_string:
    stc                           ; carry set => no string
str_ncat_done:
    pop EDI
    pop ESI
    pop ECX
    leave
    ret 12

;--------------------proc str_cpy-------------------;
; Receives two string pointers. If string2 is not a ;
; string, CF is set otherwise, string2 is copied to ;
; string1 and the offeset of string1 is returned in ;
; EAX with CF = 0.                                  ;
;---------------------------------------------------;
str_cpy:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    enter 0, 0
    push ECX
    push EDI
    push ESI
    mov EDI, string1              ; copy string1 pointer to EDI
    mov ESI, string2              ; copy string2 pointer to ESI
    push ESI
    call str_len                  ; string2 length
    jc str_cpy_no_string
    mov ECX, EAX                  ; string2 length in ECX
    inc ECX
    cld                           ; forward direction
    rep movsb                     ; move first ECX characters from string2 to string1
    mov EAX, string1
    clc                           ; clear carry to indicate no error
    jmp SHORT str_cpy_done     
str_cpy_no_string:
    stc                           ; carry set => no string
str_cpy_done:
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 8                         ; clear stack and return

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
    jcxz first_blank_no_string   ; if ECX = 0, not a string
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