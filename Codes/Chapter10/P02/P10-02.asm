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
    MAX_STRING_SIZE EQU 100
    NULL EQU NULL
    
    NEWLINE db 10, NULL
    
    MSG_STRING1_INPUT db "Enter first string: ", NULL
    MSG_STRING2_INPUT db "Enter second string: ", NULL
    MSG_NUMBER_INPUT db "Enter maximum number of characters to compare: ", NULL
    
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

;-----------------------proc str_ncmp----------------------;
; Receives two string pointers If string2 is not a string, ;
; CF is set otherwise, compare at most the first num       ;
; characters of the two strings and returns a value in EAX ;
; with CF = 0 as shown below:                              ;
; EAX = negative value if string1 < string2                ;
; EAX = zero if string1 = string2                          ;
; EAX = positive value if string1 > string2                ;
;-----------------------------------------------------------
str_ncmp:
    %define string2 DWORD [EBP+8]
    %define string1 DWORD [EBP+12]
    %define num DWORD [EBP+16]
    enter 0, 0
    push ECX
    push EDI
    push ESI
    
    mov EDI, string1              ; copy string1 pointer to EDI
    mov ESI, string2              ; copy string2 pointer to ESI
    push ESI
    call str_len                  ; string2 length
    jc str_ncmp_no_string
                                  ; ECX = min(num, string2_length)
    cmp num, EAX
    jle str_ncmp_num_lower
    jmp str_ncmp_length_lower
str_ncmp_num_lower:
    mov ECX, num
    jmp str_ncmp_continue
str_ncmp_length_lower:
    mov ECX, EAX
    inc ECX                       ; add 1 to include NULL
    jmp str_ncmp_continue
str_ncmp_continue:
    cld                           ; forward direction
    repe cmpsb                    ; compare first ECX characters of string2 and string1
    je same
    ja above
    jmp below
below:
    mov EAX, -1                   ; EAX = -1 => string1 < string2
    clc                           ; clear carry to indicate no error
    jmp SHORT str_ncmp_done
same:
    xor EAX, EAX                  ; EAX = 0 => string match
    clc                           ; clear carry to indicate no error
    jmp SHORT str_ncmp_done
above:
    mov EAX, 1                    ; EAX = 1 => string1 > string2
    clc                           ; clear carry to indicate no error
    jmp SHORT str_ncmp_done
str_ncmp_no_string:
    stc                           ; carry set => no string 
str_ncmp_done:
    pop ESI
    pop EDI
    pop ECX
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