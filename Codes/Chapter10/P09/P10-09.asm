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
    
    MSG_STRING1_INPUT db "Enter first string: ", NULL
    MSG_STRING2_INPUT db "Enter second string: ", NULL
    MSG_OUTPUT db "Result: ", NULL
    
section .bss
    buffer resb MAX_STRING_SIZE
    string1 resb MAX_STRING_SIZE
    string2 resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING1_INPUT
    fgets string1, MAX_STRING_SIZE
    puts MSG_STRING2_INPUT
    fgets string2, MAX_STRING_SIZE
    
    push string1
    push string2
    call str_match
    ; 0 if they match, 1 if not
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

;----------------------proc str_match-----------------------;
; Receives two string pointers. string1 and string2 are     ;
; compared case-insensitive and returns a value in EAX      ;
; as shown below:                                           ;
; EAX = negative value if string1 < string2                 ;
; EAX = zero if string1 = string2                           ;
; EAX = positive value if string1 > string2                 ;
;-----------------------------------------------------------;
str_match:
    %define string1 DWORD [EBP+8]
    %define string2 DWORD [EBP+12]
    enter 0, 0
    
    push string1
    call str_upper
    push string2
    call str_upper
    push string1
    push string2
    call str_cmp
str_match_done:
    leave
    ret 8                         ; clear stack and return

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