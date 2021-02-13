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
    char_table db "1000200030000040000050000000000010002000300000400000500000", 0           ;starting with 'A' and ending with 'z'
    jump_table dd continue_loop
               dd vowel_a
               dd vowel_e
               dd vowel_i
               dd vowel_o
               dd vowel_u

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
    xor eax, eax
    mov al, [inBuffer+esi]
    cmp al, 0
    je print_results
    cmp al, 65                      ;smaller than 65 does not fit in our table
    jl continue_loop
    cmp al, 122                     ;bigger than 122 does not fit either
    jg continue_loop
    mov EBX, char_table
    sub al, 65                      ;'A' - 65 = 0  -> beginning index
    xlatb
    sub al, 48                      ;convert the printable digit to an actualy number
    mov edi, eax
    jmp [jump_table+edi*4]          ;jump to the index of jump_table pointed to by AL
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