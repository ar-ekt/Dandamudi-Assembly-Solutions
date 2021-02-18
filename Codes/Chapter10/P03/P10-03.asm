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
    call is_palindrome

    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

;--------------------proc is_palindrome--------------------;
; Receives a string pointer. If not a string, CF is set    ;
; otherwise, remove blanks, punctuation marks and converts ;
; all uppercase characters to lowercase with CF = 0.       ;
;----------------------------------------------------------;
is_palindrome:
    %define string DWORD [EBP+8]
    enter 0, 0
    
    push string
    call str_len                  ; called to check string
    jc is_palindrome_no_string
    
    push string
    call str_cln                  ; remove blanks punctuation marks and converts all uppercase characters to lowercase
    push string
    push buffer
    call str_rev                  ; puts reversed of string into buffer
    
    push string
    push buffer
    call str_cmp                  ; compare string and buffer
    cmp EAX, 0
    je is_palindrome_true
    jmp is_palindrome_false
is_palindrome_true:
    mov EAX, 1                    ; EAX = 1 => string is palindrome
    clc                           ; clear carry to indicate no error
    jmp SHORT is_palindrome_done
is_palindrome_false:
    xor EAX, EAX                  ; EAX = 1 => string is not palindrome
    clc                           ; clear carry to indicate no error
    jmp SHORT is_palindrome_done
is_palindrome_no_string:
    stc
is_palindrome_done:
    leave
    ret 4                         ; clear stack and return

;-----------------------proc str_cln-----------------------;
; Receives a string pointer If not a string, CF is set     ;
; otherwise, remove blanks, punctuation marks and converts ;
; all uppercase characters to lowercase with CF = 0.       ;
;----------------------------------------------------------;
str_cln:
    %define string DWORD [EBP+8]
    enter 0,0
    push EAX
    push EDI
    push ESI
    mov EDI, buffer              ; copy buffer pointer to EDI
    mov ESI, string              ; copy string pointer to ESI
    dec ESI
clean_loop:                      ; iterate string while pointing character is not NULL
    inc ESI
    cmp [ESI], BYTE NULL
    je clean_loop_done
lower_check:                     ; check if the character is a lowercase alphabet
    cmp [ESI], BYTE 'a'
    jl digit_check
    cmp [ESI], BYTE 'z'
    jg digit_check
    mov EAX, [ESI]
    mov [EDI], EAX
    inc EDI
    jmp clean_loop
digit_check:                     ; check if the character is a digit
    cmp [ESI], BYTE '0'
    jl upper_check
    cmp [ESI], BYTE '9'
    jg upper_check
    mov EAX, [ESI]
    mov [EDI], EAX
    inc EDI
    jmp clean_loop
upper_check:                     ; check if the character is a uppercase alphabet
    cmp [ESI], BYTE 'A'
    jl clean_loop
    cmp [ESI], BYTE 'Z'
    jg clean_loop
    mov EAX, [ESI]
    add EAX, 32                  ; convert to lowercase
    mov [EDI], EAX
    inc EDI
    jmp clean_loop
clean_loop_done:
    mov [EDI], BYTE NULL         ; set NULL to end of buffer
    push string
    push buffer
    call str_cpy                 ; copy buffer to string
str_cln_done:
    pop ESI
    pop EDI
    pop EAX
    leave
    ret 4                         ; clear stack and return

;-----------------------proc str_cmp------------------------;
; Receives two string pointers. If string2 is not a string, ;
; CF is set otherwise, string1 and string2 are compared and ;
; returns a value in EAX with CF = 0 as shown below:        ;
; EAX = negative value if string1 < string2                 ;
; EAX = zero if string1 = string2                           ;
; EAX = positive value if string1 > string2                 ;
;-----------------------------------------------------------;
str_cmp:
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
    jc str_cmp_no_string
    mov ECX, EAX                  ; string2 length in ECX
    inc ECX                       ; add 1 to include NULL
    cld                           ; forward direction
    repe cmpsb                    ; compare first ECX characters of string2 and string1
    je same
    ja above
    jmp below
below:
    mov EAX, -1                   ; EAX = -1 => string1 < string2
    clc                           ; clear carry to indicate no error
    jmp SHORT str_cmp_done
same:
    xor EAX, EAX                  ; EAX = 0 => string match
    clc                           ; clear carry to indicate no error
    jmp SHORT str_cmp_done
above:
    mov EAX, 1                    ; EAX = 1 => string1 > string2
    clc                           ; clear carry to indicate no error
    jmp SHORT str_cmp_done
str_cmp_no_string:
    stc                           ; carry set => no string 
str_cmp_done:
    pop ESI
    pop EDI
    pop ECX
    leave
    ret 8                         ; clear stack and return

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

;-----------------------proc str_rev------------------------;
; Receives two string pointer If not a string, CF is set    ;
; otherwise, copy first string to second string in reverse. ;
;-----------------------------------------------------------;
str_rev:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    enter 0, 0
    push ECX
    push EAX
    push EDI
    push ESI
    mov EDI, string1              ; copy string1 pointer to EDI
    mov ESI, string2              ; copy string2 pointer to ESI
    push ESI
    call str_len                  ; string2 length
    jc str_rev_no_string
    mov ECX, EAX                  ; set loop counter
    add ESI, EAX                  ; point to the end of the string2
    dec ESI
str_rev_loop:                     ; loop to copy string2 to string1 in reverse
    mov EAX, [ESI]
    mov [EDI], EAX
    inc EDI
    dec ESI
    loop str_rev_loop
    mov [EDI], BYTE NULL          ; set NULL to end of string1
    clc                           ; clear carry to indicate no error
str_rev_no_string:
    stc                           ; carry set => no string 
str_rev_done:
    pop ESI
    pop EDI
    pop EAX
    pop ECX
    leave
    ret 8                         ; clear stack and return

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