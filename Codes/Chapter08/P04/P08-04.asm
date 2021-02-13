global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG db "enter a string: ", 0
    outMSG1 db " Vowel  Count", 0
    outMSG2 db "a or A:   ", 0
    outMSG3 db "e or E:   ", 0
    outMSG4 db "i or I:   ", 0
    outMSG5 db "o or O:   ", 0
    outMSG6 db "u or U:   ", 0
    nwln db 10, 0

section .bss
    vowelA resb 1
    vowelE resb 1
    vowelI resb 1
    vowelO resb 1
    vowelU resb 1
    outBuffer resb 10
    inBuffer resb 250

section .code
_start:
    puts inMSG
    fgets inBuffer, 250
    xor esi, esi                    ;index for input string
char_loop:
    mov al, [inBuffer+esi]
    cmp al, 0
    je print_results
lower_case:
    cmp al, 'a'
    je vowel_a
    cmp al, 'e'
    je vowel_e
    cmp al, 'i'
    je vowel_i
    cmp al, 'o'
    je vowel_o
    cmp al, 'u'
    je vowel_u
upper_case:
    cmp al, 'A'
    je vowel_a
    cmp al, 'E'
    je vowel_e
    cmp al, 'I'
    je vowel_i
    cmp al, 'O'
    je vowel_o
    cmp al, 'U'
    je vowel_u
    jmp continue_loop
vowel_a:
    mov cl, [vowelA]
    inc cl
    mov [vowelA], cl
    jmp continue_loop
vowel_e:
    mov cl, [vowelE]
    inc cl
    mov [vowelE], cl
    jmp continue_loop
vowel_i:
    mov cl, [vowelI]
    inc cl
    mov [vowelI], cl
    jmp continue_loop
vowel_o:
    mov cl, [vowelO]
    inc cl
    mov [vowelO], cl
    jmp continue_loop
vowel_u:
    mov cl, [vowelU]
    inc cl
    mov [vowelU], cl
continue_loop:
    inc esi
    jmp char_loop
print_results:
    puts outMSG1
    puts nwln
print_a:
    puts outMSG2
    xor eax, eax
    mov al, [vowelA]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
print_e:
    puts outMSG3
    xor eax, eax
    mov al, [vowelE]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
print_i:
    puts outMSG4
    xor eax, eax
    mov al, [vowelI]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
print_o:
    puts outMSG5
    xor eax, eax
    mov al, [vowelO]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
print_u:
    puts outMSG6
    xor eax, eax
    mov al, [vowelU]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
finish_prog:
    push 0
    call ExitProcess