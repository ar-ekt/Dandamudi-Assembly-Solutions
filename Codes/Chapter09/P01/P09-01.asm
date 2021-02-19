%INCLUDE "lib.h"
global _start

section .data
    input_prompt db "Please input a hex number: ", 0
    out_msg db "The decimal value is: ", 0
    endl db 10, 0

section .bss
    hex_number resb 41      ; to store hex number
    buffer resb 41

section .code
_start:
    puts input_prompt       ; request an hex number
    fgets hex_number, 41    ; read input number
    mov ebx, hex_number     ; pass hex # pointer
    call to_binary          ; returns binary value in EAX
    puts out_msg
    i2a eax, buffer
    puts buffer             ; display the result (use <i2a> and <puts> instead of <PutLInt>)
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

;------------------------proc to_binary-------------------------;
; to_binary receives a pointer to a hex number string in EBX    ;
; register and returns the binary equivalent in EAX. uses SHL   ;
; for multiplication by 16. preserves all registers except EAX. ;
;---------------------------------------------------------------;

to_binary:
    push ebx                ; save registers
    push ecx
    push edx
    xor edx, edx
    xor eax, eax            ; result = 0
    mov ecx, 8              ; max. number of hex digits
repeat:                     ; loop iterates a maximum of 8 times; but a NULL can terminate it early
    mov dl, [ebx]           ; read the hex digit
    cmp dl, 0               ; is it NULL?
    je finished             ; if so, terminate loop
    cmp dl, '9'             ; is it letter?
    jg letter_to_number     ; if so, convert letter to its numeric equivalent
    and dl, 0Fh             ; convert char. (digit) to numeric
    jmp continue
letter_to_number:
    add dl, 10 - 'A'        ; convert char. (capital letter) to numeric
continue:
    shl eax, 4              ; multiply by 16
    add eax, edx            ; and add to binary
    inc ebx                 ; move to next hex digit
    dec ecx                 ; and repeat
    jnz repeat
finished:
    pop edx                 ; restore registers
    pop ecx
    pop ebx
    ret