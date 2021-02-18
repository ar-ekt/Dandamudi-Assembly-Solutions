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
    
    MSG_STRING_INPUT db "Enter string: ", NULL
    MSG_SUBSTRING_INPUT db "Enter substring: ", NULL
    MSG_OUTPUT db "Result: ", NULL
    
section .bss
    buffer resb MAX_STRING_SIZE
    string resb MAX_STRING_SIZE
    substring resb MAX_STRING_SIZE

section .code
_start:
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    puts MSG_SUBSTRING_INPUT
    fgets substring, MAX_STRING_SIZE
    
    push substring
    push string
    call str_str
    
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess

;-----------------------proc str_str---------------------------;
; Receives two string pointers. If substring is not a string,  ;
; CF is set otherwise, search substring in string and if found ;
; return the starting position of the first match in EAX with  ;
; CF = 0 as shown below:                                       ;
;--------------------------------------------------------------;
str_str:
    %define string DWORD [EBP+8]
    %define substring DWORD [EBP+12]
    enter 0, 0
    push EBX
    push ECX
    push ESI
    push EDI
    mov EDI, substring            ; copy substring pointer to EDI
    mov ESI, string               ; copy string pointer to ESI
    push EDI
    call str_len                  ; substring length
    jc str_str_no_string
    mov ECX, EAX                  ; substring length in ECX
    xor EBX, EBX
    dec ESI
str_str_loop:
    inc EBX
    inc ESI
    cmp [ESI], BYTE NULL          ; if ESI is pointing to the end of string its mean is substring have not founded
    je substring_not_found
    push ECX
    push ESI
    push EDI
    call str_ncmp                 ; check if substring and ESI are equal, substring have founded
    cmp EAX, 0
    je substring_found
    jmp str_str_loop
substring_not_found:
    mov EAX, -1                   ; EAX = -1 => substring have not founded
    jmp str_str_done
substring_found:
    mov EAX, EBX                  ; EAX = EBX => substring have founded and EAX is pointing to the starting position of the first match
    jmp str_str_done
str_str_no_string:
    stc                           ; carry set => no string
str_str_done:
    pop EDI
    pop ESI
    pop ECX
    pop EBX
    leave
    ret 8                         ; clear stack and return

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