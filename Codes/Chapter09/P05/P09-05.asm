%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input an integer: ", 0
    out_msg1 db "Its binary representation has an <", 0
    out_msg2 db "> number of 1's,", 10, 0
    odd_msg db "ODD", 0
    even_msg db "EVEN", 0
    out_msg3 db "The number of ones: ", 0
    endl db 10, 0

section .bss
    buffer resd 41

section .code
_start:
    puts prompt_msg
    fgets buffer, 41
    a2i 41, buffer          ; return inputed integer in EAX
    xor edi, edi            ; reset EDI to store the number of 1's
    mov dx, 8000h           ; load DX with 8000 hex to testing inputed integer bits starting from MSB
find_ones:
    test ax, dx             ; test bit
    jnz increase_counter    ; if it was 1, increse EDI by one
    jmp continue
increase_counter:
    inc edi
continue:
    shr dx, 1               ; shift right DX to test next bit of AX
    jnz find_ones
even_or_odd:
    puts out_msg1
    bt edi, 0               ; test LSB of EDI
    jc odd                  ; if it was 1, EDI contains an odd number and jump to display "ODD"
    puts even_msg           ; otherwise it contains an even number and display "EVEN"
    jmp skip_odd
odd:
    puts odd_msg
skip_odd:
    puts out_msg2
    i2a edi, buffer
    puts out_msg3
    puts buffer             ; display the number of 1's
    puts endl
end:
    mov eax, 1
    mov ebx, 0
    int 0x80