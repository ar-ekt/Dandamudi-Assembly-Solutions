global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    newline db 10, 0
    inputMSG db 'Please input a positive number in hex (CAPS ON, 4 digits max): ', 0
    printResult db 'The decimal equivalent of ', 0
    cont1 db ' is ', 0
    prompt db 'Do you want to terminate the program (Y/N): ', 0

section .bss
    inputBuffer resb 6
    resultBuffer resb 6

section .code
_start:
    puts inputMSG
    fgets inputBuffer, 6
    puts printResult
    puts inputBuffer
    puts cont1
    mov ebx, 0
    mov ebx, inputBuffer+4
init_pointer:
    dec ebx
    mov al, [ebx]
    cmp al, 0
    je init_pointer
    mov eax, 0
    mov cl, 0
    mov edx, 0
calc:
    mov al, [ebx]
    cmp al, 0
    je finish
    cmp al, '9'
    jg a_to_f
    mov al, [ebx]
    sub al, '0'
    jmp skip1
a_to_f:
    mov al, [ebx]
    sub al, 'A'
    add al, 10
skip1:
    cmp cl, 0
    je LS
    shl ax, cl
    add edx, eax
    jmp iterate
LS:
    add edx, eax
iterate:
    add cl, 4
    dec ebx
    jmp calc
finish:
    i2a edx, resultBuffer
    puts resultBuffer
    puts newline
tprompt:
    puts prompt
    fgets inputBuffer, 6
    mov ebx, 0
    mov ebx, inputBuffer
    mov ah, [ebx]
    cmp ah, 'Y'
    je end
    cmp ah, 'N'
    je _start
    jmp tprompt
end:
    push 0
    call ExitProcess