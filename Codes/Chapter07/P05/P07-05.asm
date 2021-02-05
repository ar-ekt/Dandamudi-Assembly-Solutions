global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    newline db 10, 0
    tab db 9, 0
    sep db "-------", 0
    inMSG1 db "enter the matrix size:", 0
    inMSG2 db "rows (<=10): ", 0
    inMSG3 db "columns (<=10): ", 0
    inMSG4 db "enter the matrix entries row by row (one in every line, and each between -128 and 127):", 0
    errMSG db "***invalid entry. must be between -128 and 127***"
    outMSG db "new matrix:", 0

section .bss
    buffer resb 20
    newbuffer resb 30
    rows resw 1
    columns resw 1
    matrix resw 10*10

section .code
_start:
    puts inMSG1
    puts newline
get_rows:
    puts inMSG2
    fgets buffer, 5
    a2i 5, buffer
    cmp AL, 10
    jg get_rows
    cmp AL, 0
    jle get_rows
    mov [rows], AL
get_cols:
    puts inMSG3
    fgets buffer, 5
    a2i 5, buffer
    cmp AL, 10
    jg get_cols
    cmp AL, 0
    jle get_cols
    mov [columns], AL
matrix_input:
    call read_matrix
matrix_mult_and_print:
    puts outMSG
    puts newline
    call mult_matrix
finish_program:
    push 0
    call ExitProcess

;---------------------------------

;proc read_matrix -> reads the matrix with the given size
;has access to the global pointers to col, row and matrix
read_matrix:
    pushad
    xor ECX, ECX
    xor ESI, ESI
    mov BL, [rows]
    puts inMSG4
    puts newline
read_row:
    mov CL, [columns]
read_col:
    fgets buffer, 6
    a2i 6, buffer
    cmp AX, 127
    jg invalid_entry
    cmp AX, -128
    jl invalid_entry
    mov [matrix+ESI], AX
    add ESI, 2
    loop read_col
    puts sep
    puts newline
    dec BL
    cmp BL, 0
    je finish_input
    jmp read_row
invalid_entry:
    puts errMSG
    puts newline
    jmp read_col
finish_input:
    popad
    ret

;---------------------------------
%define temp_rows [EBP-4]
%define temp_cols [EBP-8]

;proc mult_matrix -> multiplies every row by i*(-1)**i
;then prints the matrix entry by entry
mult_matrix:
    enter 8, 0
    pushad
    xor ECX, ECX
    xor ESI, ESI
    xor EAX, EAX
    xor EBX, EBX
    xor EDX, EDX
    mov EAX, [rows]
    mov temp_rows, EAX
    xor EAX, EAX
    mov EAX, [columns]
    mov temp_cols, EAX
    xor EAX, EAX
    mov BL, 1
mult_row:
    mov CL, temp_cols
mult_col:
    xor EAX, EAX
    xor DX, DX
    xor BH, BH
    mov AX, BX
    mov DL, 2
    div DL
    cmp AH, 1
    je odd
even:
    mov AL, BL
    jmp start_mult
odd:
    mov BH, BL
    neg BL
    mov AL, BL
    mov BL, BH
start_mult:
    mov DX, [matrix+ESI]
    imul DL
    movsx EAX, AX                       ;apparently it works when we push eax, so lets sign extend ax into eax
    i2a EAX, newbuffer                  ;changed the output buffer, apparently it has to be different from the input buffer
    puts newbuffer
    puts tab
    add ESI, 2
    loop mult_col
    puts newline
    inc BL
    cmp BL, temp_rows
    jg finish_mult
    jmp mult_row
finish_mult:
    popad
    leave
    ret