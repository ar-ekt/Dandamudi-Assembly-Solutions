global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    newline db 10, 0
    htab db 9, 0
    sep db "----------------", 0
    inMSG1 db "enter the matrix size:", 0
    inMSG2 db "rows (<=10): ", 0
    inMSG3 db "columns (<=10): ", 0


section .bss
    buffer resb 15
    rows resb 1
    columns resb 1
    matrix1 resd 10*10
    matrix2 resd 10*10

section .code
_start:

input_row_col:
    puts inMSG1
    puts newline
    puts inMSG2
    fgets buffer, 4
    a2i 4, buffer
    mov [rows], AL
    puts inMSG3
    fgets buffer, 4
    a2i 4, buffer
    mov [columns], AL

get_matrix:
    xor ESI, ESI
    xor ECX, ECX
    mov BL, [rows]
read_row:
    mov CL, [columns]
read_col:
    fgets buffer, 12
    a2i 12, buffer
    mov [matrix1+ESI], EAX
    add ESI, 4
    loop read_col
    puts sep
    puts newline
    dec BL
    cmp BL, 0
    je transpose
    jmp read_row

transpose:
    xor BX, BX
move_row:
    xor CX, CX
move_col:
read_mtx1_entry:
    xor EAX, EAX
    mov AL, [columns]
    mul BL
    add AX, CX
    mov ESI, EAX
    mov EDI, [matrix1+ESI*4]
enter_mtx2_entry:
    xor EAX, EAX
    mov AL, [columns]
    mul CL
    add AX, BX
    mov ESI, EAX
    mov [matrix2+ESI*4], EDI
loop_conditions:
    inc CL
    cmp CL, [columns]
    je next_row
    jmp move_col
next_row:
    inc BL
    cmp BL, [rows]
    je print_mtx2
    jmp move_row

print_mtx2:
    xor ESI, ESI
    mov BL, [rows]
    mov DL, [columns]
print_row:
    xor ECX, ECX
    mov CL, DL
print_col:
    mov EDI, [matrix2+ESI]
    i2a EDI, buffer
    puts buffer
    puts htab
print_loop_conditions:
    add ESI, 4
    loop print_col
    puts newline
    dec BL
    cmp BL, 0
    jne print_row
finish:
    push 0
    call ExitProcess