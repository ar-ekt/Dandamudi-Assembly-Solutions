%INCLUDE "lib.h"
global _start

section .data
    input_prompt db "Please input an octal number: ", 0
    out_msg1 db "The decimal value is: ", 0
    query_msg db "Do you want to quit (Y/N): ", 0
    error_msg db "Non-octal input!", 10, 0
    endl db 10, 0

section .bss
    octal_number resb 41    ; to store octal number
    buffer resb 41

section .code
_start:
    puts input_prompt       ; request an octal number
    fgets octal_number, 41  ; read input number
    mov ebx, octal_number   ; pass octal # pointer
    call to_binary          ; returns binary value in AX
    cmp eax, 0              ; if return value is negative
    jl put_error_msg        ; show error msg and terminate program
    puts out_msg1
    i2a eax, buffer
    puts buffer             ; otherwise display the result
    puts endl
    puts query_msg          ; query user whether to terminate
    fgets buffer, 41        ; read response
    cmp [buffer], byte 'Y'  ; if response is not 'Y'
    jne _start              ; read another number
    jmp done                ; otherwise terminate program
put_error_msg:
    puts error_msg
done:
    mov eax, 1
    mov ebx, 0
    int 0x80

;----------------------proc to_binary-----------------------;
; to_binary receives a pointer to an octal number string in ;
; EBX register and returns the binary equivalent in EAX. in ;
; case of error for non-octal input, it returns a negative  ;
; value. uses SHL for multiplication by 8. preserves all    ;
; registers, except EAX.                                    ;
;-----------------------------------------------------------;

to_binary:
    push ebx                ; save registers
    push cx
    push dx
    xor dx, dx              ; clear dx to make sure its upper half is clear
    xor eax, eax            ; result = 0
    mov cx, 3               ; max. number of octal digits
repeat1:                    ; loop iterates a maximum of 3 times; but a NULL can terminate it early
    mov dl, [ebx]           ; read the octal digit
    cmp dl, 0               ; is it NULL?
    je finished             ; if so, terminate loop
    cmp dl, '0'             ; is it less than '0'?
    jl error                ; if so, set eax with a negative value and return
    cmp dl, '8'             ; is it greater than or equal to '8'?
    jge error               ; if so, set eax with a negative value and return
    and dl, 0Fh             ; else, convert char. to numeric
    shl ax, 3               ; multiply by 8
    add ax, dx              ; and add to binary
    inc ebx                 ; move to next octal digit
    dec cx                  ; and repeat
    jnz repeat1
    jmp finished
error:
    mov eax, -1
finished:
    pop dx                 ; restore registers
    pop cx
    pop ebx
    ret