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
    NULL EQU 0
    
    proc_ptr_table dd str_ncpy_call, str_ncmp_call, is_palindrome_call
                   dd remove_leading_blanks_call, remove_leading_and_duplicate_blanks_call
                   dd str_str_call, rearrange_name1_call, rearrange_name2_call
                   dd str_match_call, reverse_sentence_call
    FUNCTIONS_N EQU 10
    
    choice_prompt db "               >>> MENU <<<               ", 10
                  db ".Bounded string copy -------------------- 1", 10
                  db ".Bounded string compare ----------------- 2", 10
                  db ".Check being palindrome ----------------- 3", 10
                  db ".Remove leading blanks ------------------ 4", 10
                  db ".Remove leading and duplicate blanks ---- 5", 10
                  db ".Find substring ------------------------- 6", 10
                  db ".Rearrange person's name-1 -------------- 7", 10
                  db ".Rearrange person's name-2 -------------- 8", 10
                  db ".String match --------------------------- 9", 10
                  db ".Reverse sentence ----------------------- 10", 10
                  db "Invalid response terminates program.    ", 10
                  db "Please enter your choice >> ", NULL
    
    NEWLINE db 10, NULL
    SPACE db 32, NULL
    COMMA db ",", NULL
    
    MSG_INVALID_CHOICE db "Invalid choice", 10, NULL
    
    MSG_STRING_INPUT db "Enter string: ", NULL
    MSG_STRING1_INPUT db "Enter first string: ", NULL
    MSG_STRING2_INPUT db "Enter second string: ", NULL
    MSG_SUBSTRING_INPUT db "Enter substring: ", NULL
    MSG_NAME_INPUT db "Enter name: ", NULL
    MSG_SENTENCE_INPUT db "Enter sentence: ", NULL
    
    MSG_NUMBER_STRNCPY_INPUT db "Enter number of characters to be copied from source: ", NULL
    MSG_NUMBER_STRNCMP_INPUT db "Enter maximum number of characters to compare: ", NULL
    
    MSG_OUTPUT db "Result: ", NULL
    
section .bss
    buffer resb MAX_STRING_SIZE
    string resb MAX_STRING_SIZE
    string1 resb MAX_STRING_SIZE
    string2 resb MAX_STRING_SIZE
    substring resb MAX_STRING_SIZE
    name resb MAX_STRING_SIZE
    firstName resb MAX_STRING_SIZE
    MI resb MAX_STRING_SIZE
    lastName resb MAX_STRING_SIZE
    sentence resb MAX_STRING_SIZE

section .code
_start:
query_choice:
    puts choice_prompt
    geti
    puts NEWLINE
    cmp EAX, 1
    jl invalid_response
    cmp EAX, FUNCTIONS_N
    jg invalid_response
    dec EAX
    jmp response_ok
invalid_response:
    puts MSG_INVALID_CHOICE
    jmp _end
response_ok:
    shl EAX, 2
    call [proc_ptr_table+EAX]
    puts NEWLINE
    jmp query_choice
_end:
    push DWORD 0
    call ExitProcess

;-------------------------------call procedures--------------------------------;
; Input parameters from user, call the wanted procedure and output the result. ;
;------------------------------------------------------------------------------;
str_ncpy_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING_INPUT
    fgets string2, MAX_STRING_SIZE
    puts MSG_NUMBER_STRNCPY_INPUT
    geti
    ; CALL
    push EAX
    push string1
    push string2
    call str_ncpy
    ; OUTPUT
    puts MSG_OUTPUT
    puts string1
    puts NEWLINE
    pop EAX
    leave
    ret

str_ncmp_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING1_INPUT
    fgets string1, MAX_STRING_SIZE
    puts MSG_STRING2_INPUT
    fgets string2, MAX_STRING_SIZE
    puts MSG_NUMBER_STRNCMP_INPUT
    geti
    ; CALL
    push EAX
    push string2
    push string1
    call str_ncmp
    ; OUTPUT
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    pop EAX
    leave
    ret

is_palindrome_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    ; CALL
    push string
    call is_palindrome
    ; OUTPUT
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    pop EAX
    leave
    ret

remove_leading_blanks_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    ; CALL
    push string
    call remove_leading_blanks
    ; OUTPUT
    puts MSG_OUTPUT
    puts string
    puts NEWLINE
    pop EAX
    leave
    ret

remove_leading_and_duplicate_blanks_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    ; CALL
    push string
    call remove_leading_and_duplicate_blanks
    ; OUTPUT
    puts MSG_OUTPUT
    puts string
    puts NEWLINE
    pop EAX
    leave
    ret

str_str_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING_INPUT
    fgets string, MAX_STRING_SIZE
    puts MSG_SUBSTRING_INPUT
    fgets substring, MAX_STRING_SIZE
    ; CALL
    push substring
    push string
    call str_str
    ; OUTPUT
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    pop EAX
    leave
    ret

rearrange_name1_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_NAME_INPUT
    fgets name, MAX_STRING_SIZE
    ; CALL
    push name
    call rearrange_name1
    pop EAX
    leave
    ret

rearrange_name2_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_NAME_INPUT
    fgets name, MAX_STRING_SIZE
    ; CALL
    push name
    call rearrange_name2
    pop EAX
    leave
    ret

str_match_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_STRING1_INPUT
    fgets string1, MAX_STRING_SIZE
    puts MSG_STRING2_INPUT
    fgets string2, MAX_STRING_SIZE
    ; CALL
    push string1
    push string2
    call str_match
    ; OUTPUT
    puts MSG_OUTPUT
    puti EAX
    puts NEWLINE
    pop EAX
    leave
    ret

reverse_sentence_call:
    enter 0, 0
    push EAX
    ; INPUT
    puts MSG_SENTENCE_INPUT
    fgets sentence, MAX_STRING_SIZE
    ; CALL
    push sentence
    call reverse_sentence
    ; OUTPUT
    puts MSG_OUTPUT
    puts sentence
    puts NEWLINE
    pop EAX
    leave
    ret

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
    je str_ncmp_same
    ja str_ncmp_above
    jmp str_ncmp_below
str_ncmp_below:
    mov EAX, -1                   ; EAX = -1 => string1 < string2
    clc                           ; clear carry to indicate no error
    jmp SHORT str_ncmp_done
str_ncmp_same:
    xor EAX, EAX                  ; EAX = 0 => string match
    clc                           ; clear carry to indicate no error
    jmp SHORT str_ncmp_done
str_ncmp_above:
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
    je str_cmp_same
    ja str_cmp_above
    jmp str_cmp_below
str_cmp_below:
    mov EAX, -1                   ; EAX = -1 => string1 < string2
    clc                           ; clear carry to indicate no error
    jmp SHORT str_cmp_done
str_cmp_same:
    xor EAX, EAX                  ; EAX = 0 => string match
    clc                           ; clear carry to indicate no error
    jmp SHORT str_cmp_done
str_cmp_above:
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

;--------------------proc is_palindrome---------------------;
; Receives a string pointer. If not a string, CF is set     ;
; otherwise, returns 1 in EAX if the string is a palindrome ;
; otherwise, it returns 0 with CF = 0.                      ;
;-----------------------------------------------------------;
is_palindrome:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ESI
    push EDI
    mov EDI, buffer               ; copy buffer pointer to EDI
    mov ESI, string               ; copy string pointer to ESI
    push ESI
    call str_len                  ; called to check string
    jc is_palindrome_no_string
    push ESI
    call str_cln                  ; remove blanks punctuation marks and converts all uppercase characters to lowercase
    push ESI
    push EDI
    call str_rev                  ; puts reversed of string into buffer
    push ESI
    push EDI
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
    pop EDI
    pop ESI
    leave
    ret 4                         ; clear stack and return

;----------------proc remove_leading_blanks--------------;
; Receives a string pointer. If not a string, CF is set  ;
; otherwise, removes all leading blank characters in the ;
; string with CF = 0.                                    ;
;--------------------------------------------------------;
remove_leading_blanks:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ESI
    
    mov ESI, string               ; copy string pointer to ESI
    push ESI
    call first_non_blank          ; find place of first nonblank character in string
    jc remove_leading_blanks_no_string
    add ESI, EAX                  ; point to first nonblank character in string
    
    push string
    push ESI
    call str_cpy                  ; shift left the string from the place of first nonblank character
    
    clc
    jmp SHORT remove_leading_blanks_done
remove_leading_blanks_no_string:
    stc
remove_leading_blanks_done:
    pop ESI
    leave
    ret 4                         ; clear stack and return

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
    
    mov EDI, buffer               ; copy buffer pointer to EDI
    mov [EDI], BYTE NULL
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
    push EDI
    push ESI
    call str_ncat                 ; add string from where ESI is pointing to next blank character to the end of buffer
    add ESI, ECX                  ; point to next blank character
    
    cmp EBX, ESI
    jle remove_leading_and_duplicate_blanks_loop_done
    
    push BYTE 1
    push EDI
    push SPACE
    call str_ncat                ; add one space to the end of buffer
    jmp remove_leading_and_duplicate_blanks_loop
remove_leading_and_duplicate_blanks_loop_done:
    push string
    push EDI
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

;---------------------proc rearrange_name1---------------------;
; Receives a string representing a person’s name in the format ;
; first-name MI last-name                                      ;
; and displays the name in the format                          ;
; last-name, first-name MI                                     ;
;--------------------------------------------------------------;
rearrange_name1:
    %define name DWORD [EBP+8]
    enter 0,0
    push ESI
    push EAX
    mov ESI, name                         ; copy name pointer to ESI
rearrange_name1_seprate_firstName:        ; copy first part of name to firstName
    push ESI
    call first_blank
    push EAX
    push firstName
    push ESI
    call str_ncpy
    add ESI, EAX
    inc ESI
rearrange_name1_seprate_middleInitial:    ; copy second part of name to MI
    push ESI
    call first_blank
    push EAX
    push MI
    push ESI
    call str_ncpy
    add ESI, EAX
    inc ESI
rearrange_name1_seprate_lastName:         ; copy last part of name to lastName
    push ESI
    call str_len
    push EAX
    push lastName
    push ESI
    call str_ncpy
rearrange_name1_done:
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
    ret 4                                 ; clear stack and return

;---------------------proc rearrange_name2---------------------;
; Receives a string representing a person’s name in the format ;
; first-name MI last-name                                      ;
; that can contain multiple spaces between the names           ;
; and displays the name in the format                          ;
; last-name, first-name MI                                     ;
; with the last name in capital letters                        ;
;--------------------------------------------------------------;
rearrange_name2:
    %define name DWORD [EBP+8]
    enter 0,0
    push ESI
    push EAX
    mov ESI, name                        ; copy name pointer to ESI
rearrange_name2_seprate_firstName:       ; copy first part of name to firstName
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
rearrange_name2_seprate_middleInitial:   ; copy second part of name to MI
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
rearrange_name2_seprate_lastName:        ; copy last part of name to lastName
    push ESI
    call str_len
    push EAX
    push lastName
    push ESI
    call str_ncpy
    push lastName
    call str_upper
rearrange_name2_done:
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
    ret 4                               ; clear stack and return

;---------------------proc reverse_sentence-----------------------;
; Receives a string representing a sentence and reverse the words ;
;-----------------------------------------------------------------;
reverse_sentence:
    %define sentence DWORD [EBP+8]
    enter 0, 0
    push EAX
    push ESI
    mov EDI, buffer                 ; copy buffer pointer to EDI
    mov [EDI], BYTE NULL
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
    push EDI
    push ESI
    call str_ncat                   ; add founded word to the end of sentence
    cmp ESI, sentence               ; check end of loop
    jle reverse_sentence_done
    push BYTE 1
    push EDI
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