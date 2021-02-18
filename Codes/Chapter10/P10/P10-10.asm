global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_STRING_SIZE EQU 100
    NULL EQU 0
    
    NEWLINE db 10, NULL
    SPACE db 32, NULL
    
    MSG_STRING_INPUT db "Enter sentence: ", NULL
    MSG_OUTPUT db "Result: ", NULL
    
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

;---------------------proc reverse_sentence-----------------------;
; Receives a string representing a sentence and reverse the words ;
;-----------------------------------------------------------------;
reverse_sentence:
    %define sentence DWORD [EBP+8]
    enter 0, 0
    push EAX
    push ESI
    mov ESI, sentence               ; copy sentence pointer to ESI
    mov [ESI-1], BYTE 32            ; add one space to the start of sentence
    push ESI
    call str_len
    add ESI, EAX                    ; point to the end of sentence
sentence_mov_loop:
    dec ESI
    push ESI
    call first_non_blank_backward
    sub ESI, EAX                    ; point to first character that is not blank before the place ESI is pointing to
    push ESI
    call first_blank_backward
    sub ESI, EAX
    add ESI, 2                      ; point to next character of first blank character before the place ESI is pointing to
    push EAX
    push buffer
    push ESI
    call str_ncat                   ; add founded word to the end of sentence
    cmp ESI, sentence               ; check end of loop
    jle reverse_sentence_done
    push BYTE 1
    push buffer
    push SPACE
    call str_ncat                   ; add a space the end of sentence for seprating words
    jmp sentence_mov_loop
reverse_sentence_done:
    push sentence
    push buffer
    call str_cpy                    ; copy buffer to sentence
    pop ESI
    pop EAX
    leave
    ret 12                          ; clear stack and return

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
    push EAX
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
    pop EAX
    leave
    ret 8                         ; clear stack and return

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
    enter 0, 0
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

;--------------proc first_non_blank_backward--------------;
; Receives a string pointer If not a string, CF is set    ;
; otherwise, return place of first character that is not  ;
; blank in backward direction in EAX with CF = 0.         ;
;---------------------------------------------------------;
first_non_blank_backward:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    
    mov EDI, string                           ; copy string pointer to EDI
    mov ECX, MAX_STRING_SIZE                  ; need to terminate loop if EDI is not pointing to a string
    std                                       ; backward search
    mov AL, 32                                ; space character
    repe scasb
    jcxz first_non_blank_backward_no_string   ; if ECX = 0, not a string
    mov EAX, string
    sub EAX, EDI                              ; blank place in EAX
    clc                                       ; clear carry to indicate no error
    jmp SHORT first_non_blank_backward_done
first_non_blank_backward_no_string:
    stc                                       ; carry set => no string
first_non_blank_backward_done:
    pop EDI
    pop ECX
    leave
    ret 4                                     ; clear stack and return

;----------------proc first_blank_backward----------------;
; Receives a string pointer If not a string, CF is set    ;
; otherwise, return place of first blank character        ;
; in backward direction in EAX with CF = 0.               ;
;---------------------------------------------------------;
first_blank_backward:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ECX
    push EDI
    
    mov EDI, string                           ; copy string pointer to EDI
    mov ECX, MAX_STRING_SIZE                  ; need to terminate loop if EDI is not pointing to a string
    std                                       ; backward search
    mov AL, 32                                ; space character
    repne scasb
    jcxz first_blank_backward_no_string       ; if ECX = 0, not a string
    mov EAX, string
    sub EAX, EDI                              ; blank place in EAX
    clc                                       ; clear carry to indicate no error
    jmp SHORT first_blank_backward_done
first_blank_backward_no_string:
    stc                                       ; carry set => no string
first_blank_backward_done:
    pop EDI
    pop ECX
    leave
    ret 4                                     ; clear stack and return

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
