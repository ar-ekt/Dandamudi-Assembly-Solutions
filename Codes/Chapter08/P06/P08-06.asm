
;the use of xlat alongside the indirect jump instruction provides a more compact and readable method of performing conditional jumps
;the indirect jump instruction can be used as an alternative for high level languages' switch case statement

global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG db "enter a string: ", 0
    outMSG1 db " Vowel  Count", 0
    outMSG2 db "   A:     ", 0
    outMSG3 db "   E:     ", 0
    outMSG4 db "   I:     ", 0
    outMSG5 db "   O:     ", 0
    outMSG6 db "   U:     ", 0
    outMSG7 db "   a:     ", 0
    outMSG8 db "   e:     ", 0
    outMSG9 db "   i:     ", 0
    outMSG10 db "   o:     ", 0
    outMSG11 db "   u:     ", 0
    nwln db 10, 0
    char_table db 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0              ;starting with 'A' and ending with 'z'
               db 0, 0, 0, 0, 0, 0
               db 6, 0, 0, 0, 7, 0, 0, 0, 8, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0
    jump_table dd continue_loop
               dd vowel_A
               dd vowel_E
               dd vowel_I
               dd vowel_O
               dd vowel_U
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
    vowela resb 1
    vowele resb 1
    voweli resb 1
    vowelo resb 1
    vowelu resb 1
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
    mov edi, eax
    jmp [jump_table+edi*4]          ;jump to the index of jump_table pointed to by AL
vowel_a:
    mov cl, [vowela]
    inc cl
    mov [vowela], cl
    jmp continue_loop
vowel_e:
    mov cl, [vowele]
    inc cl
    mov [vowele], cl
    jmp continue_loop
vowel_i:
    mov cl, [voweli]
    inc cl
    mov [voweli], cl
    jmp continue_loop
vowel_o:
    mov cl, [vowelo]
    inc cl
    mov [vowelo], cl
    jmp continue_loop
vowel_u:
    mov cl, [vowelu]
    inc cl
    mov [vowelu], cl
    jmp continue_loop
vowel_A:
    mov cl, [vowelA]
    inc cl
    mov [vowelA], cl
    jmp continue_loop
vowel_E:
    mov cl, [vowelE]
    inc cl
    mov [vowelE], cl
    jmp continue_loop
vowel_I:
    mov cl, [vowelI]
    inc cl
    mov [vowelI], cl
    jmp continue_loop
vowel_O:
    mov cl, [vowelO]
    inc cl
    mov [vowelO], cl
    jmp continue_loop
vowel_U:
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
    puts outMSG7
    xor eax, eax
    mov al, [vowela]
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
    puts outMSG8
    xor eax, eax
    mov al, [vowele]
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
    puts outMSG9
    xor eax, eax
    mov al, [voweli]
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
    puts outMSG10
    xor eax, eax
    mov al, [vowelo]
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
    puts outMSG11
    xor eax, eax
    mov al, [vowelu]
    i2a eax, outBuffer
    puts outBuffer
    puts nwln
finish_prog:
    push 0
    call ExitProcess
