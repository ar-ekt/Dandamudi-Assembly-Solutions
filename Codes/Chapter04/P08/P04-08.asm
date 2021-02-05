global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    newline db 10, 0
    inputMSG db 'Please input a decimal number between 0 and 65,535: ', 0
    printResult db 'The octal equivalent of ', 0
    cont1 db ' is ', 0
    prompt db 'Do you want to terminate the program (Y/N): ', 0

section .bss
    inputBuffer resb 7
    resultBuffer resb 5

section .code
_start:
    puts inputMSG
    fgets inputBuffer, 7
    puts printResult
    puts inputBuffer
    puts cont1
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    a2i eax, inputBuffer
calc:
    cmp ax, 0
    je finish
    xor ch, ch
    mov cl, 8
    div cx
    cmp dl, 9
    add dl, '0'
skip1:
    xor dh, dh
    push dx
    add bl, 1
    xor dx, dx
    jmp calc
finish:
    cmp bl, 0
    je spcl
    mov ecx, ebx
    mov ebx, resultBuffer
lp:
    pop dx
    mov [ebx], dx
    inc ebx
    loop lp
    mov [ebx], DWORD 0
    puts resultBuffer
    jmp tprompt
spcl:
    mov ebx, resultBuffer
    mov ah, '0'
    mov [ebx], ah
    inc ebx
    mov ah, 0
    mov [ebx], ah
    puts resultBuffer
tprompt:
    puts newline
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