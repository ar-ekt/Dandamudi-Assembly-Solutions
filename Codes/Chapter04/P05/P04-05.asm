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
    mov ebx, inputBuffer+4          ;set ebx to point to the end of the input buffer
init_pointer:                       ;finding the size of the input
    dec ebx
    mov al, [ebx]
    cmp al, 0
    je init_pointer
    xor eax, eax
    xor cl, cl                      ;number of bits to shift for multiplication
    xor edx, edx                    ;sum or result
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
    add al, 10                      ;convert hex digit to decimal number
skip1:
    cmp cl, 0
    je least_significant_digit
    shl ax, cl                      ;left shift by N is equivalent to multiplication by 2^N
    add edx, eax
    jmp iterate
least_significant_digit:            ;the least significant digit will be multiplied by 1, so no need to shift it at all
    add edx, eax
iterate:
    add cl, 4                       ;multiplier *= 16
    dec ebx
    jmp calc
finish:
    i2a edx, resultBuffer           ;convert to ascii for printing
    puts resultBuffer
    puts newline
tprompt:                            ;prompt the user for termination
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
    