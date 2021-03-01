; to test our procedure, we will use our written GetInt procedure
; to get two integers from user and display sum of two on screen

%INCLUDE "lib.h"
global _start

section .data
    num1_msg db "First Number: ", 0
    num2_msg db "Second Number: ", 0
    sum_msg db "Sum: ", 0
    endl db 10, 0

section .bss
    GetInt_buffer resb 10

section .code
_start:
    puts num1_msg
    call GetInt
    movsx edx, ax                   ; movsx == MOVe with Sign eXtend
    puts num2_msg
    call GetInt
    movsx ebx, ax
    add edx, ebx                    ; add numbers and store result in EDX
    puts sum_msg
    i2a edx, GetInt_buffer          ; convert integer to string
    puts GetInt_buffer              ; display string sum on screen
    puts endl
    mov eax, 1
    mov ebx, 0
    int 0x80

;---------------------------proc GetInt---------------------------;
; this procedure uses Linux system calls to read a 16-bit integer ;
; (-32,768 to 32,767) from keyboard and stores it in AX.          ;
;                                                                 ;
; note:                                                           ;
; this procedur require a 10 byte long buffer as GetInt_buffer to ;
; be reservrd in .bss section before any usage                    ;
;-----------------------------------------------------------------;

GetInt:
    push ebx
    push ecx
    push edx
    pushf
getstr:
    mov eax, 3                      ; file read service
    mov ebx, 0                      ; 0 = std input (keyboard)
    mov ecx, GetInt_buffer          ; pointer to buffer
    mov edx, 10                     ; input buffer size
    int 0x80
getstr_done:
    dec eax
    mov [GetInt_buffer+eax], byte 0 ; append NULL character
str_to_int:
    xor ax, ax                      ; clear AX to store our readed number in it
    mov ebx, GetInt_buffer
    cmp [ebx], byte '-'             ; is it a negative number?!
    jne loop_on_string
    inc ebx                         ; skip negative sign
loop_on_string:
    cmp [ebx], byte 0               ; is it NULL?!
    je str_to_int_done
    mov dx, 10
    mul dx                          ; AX = AX * 10
    xor dx, dx                      ; clear DX to make sure its upper half is clear
    mov dl, [ebx]                   ; read ASCII digit onto DL
    and dl, 0Fh                     ; mask off its upper half to get its numeric value
    add ax, dx                      ; AX = AX + DX (readed digit)
    inc ebx                         ; update EBX
    jmp loop_on_string
str_to_int_done:
    cmp [GetInt_buffer], byte '-'   ; is it a negative number?!
    jne GetInt_done
    neg ax                          ; negative the number stored in AX
GetInt_done:
    popf
    pop edx
    pop ecx
    pop ebx
    ret