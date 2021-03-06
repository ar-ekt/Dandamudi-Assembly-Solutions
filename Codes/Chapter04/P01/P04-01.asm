;modified version of the code in example 4.6

global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    nwln db 10, 0
    char_prompt db "Please input a character: ",0
    out_msg1 db "The ASCII code of ",0
    out_msg2 db " in binary is ",0
    query_msg db "Do you want to quit (Y/N): ",0

section .bss
    buffer resb 10
    buffer2 resb 10

section .code
_start:
read_char:
    puts char_prompt ; request a char. input
    fgets buffer, 10
    mov AL, [buffer]
    puts out_msg1
    mov [buffer2], AL
    mov [buffer2+1], BYTE 0
    puts buffer2
    puts out_msg2
    mov AH,80H ; mask byte = 80H
    mov ECX,8 ; loop count to print 8 bits
print_bit:
    test AL,AH ; test does not modify AL
    jz print_0 ; if tested bit is 0, print it
    mov [buffer2], BYTE 49
    mov [buffer2+1], BYTE 0
    puts buffer2
    jmp skip1
print_0:
    mov [buffer2], BYTE 48
    mov [buffer2+1], BYTE 0
    puts buffer2
skip1:
    shr AH,1 ; right-shift mask bit to test
    ; next bit of the ASCII code
    loop print_bit
    puts nwln
query:
    puts query_msg ; query user whether to terminate
    fgets buffer, 10
    cmp [buffer], BYTE 'Y'
    je is_yes
    cmp [buffer], BYTE 'y'
    je is_yes
    cmp [buffer], BYTE 'N'
    je is_no
    cmp [buffer], BYTE 'n'
    je is_no
    jmp query
is_yes:
    cmp [buffer+1], BYTE 0
    je done
    jmp query
is_no:
    cmp [buffer+1], BYTE 0
    je read_char
    jmp query
done: ; otherwise, terminate program
    push 0
    call ExitProcess
