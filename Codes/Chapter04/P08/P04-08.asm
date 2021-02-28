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
    mov dl, al
    and dl, 7                       ;remainder is the lower 3 bits so we AND the lower byte with 0000 0111
    shr ax, 3                       ;divide by 8
    cmp dl, 9
    add dl, '0'
skip1:
    xor dh, dh                      ;characters are supposed to be placed in the array backwards
    push dx                         ;so we push them here and pop them later
    add bl, 1                       ;number of characters in our result
    xor dx, dx
    jmp calc
finish:
    cmp bl, 0                       ;if BL == 0 then we have a special condition and the length of result is 0
    je length_zero
    mov ecx, ebx                    ;set counter in ecx
    mov ebx, resultBuffer           ;place the address of our array in ebx
place_in_array:
    pop dx                          ;pop characters so we can place them in the array in reverse order
    mov [ebx], dx
    inc ebx
    loop place_in_array
    mov [ebx], DWORD 0
    puts resultBuffer
    jmp tprompt
length_zero:
    mov ebx, resultBuffer
    mov ah, '0'                     ;set result to 0
    mov [ebx], ah
    inc ebx
    mov ah, 0                       ;terminate the result string
    mov [ebx], ah
    puts resultBuffer
tprompt:                            ;prompt the user for termination
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
