global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    nwln db 10, 0
    htab db 9, 0
    sep db "-----------", 0
    inMSG1 db "enter the size of the matrices:", 0
    inMSG2 db "rows (<=10): ", 0
    inMSG3 db "columns (<=10): ", 0
    inMSG4 db "enter matrix A's entries row by row (each entry must be in one line):", 0
    inMSG5 db "enter matrix B's entries row by row (each entry must be in one line):", 0
    outMSG db "the sum of matrices A and B is:", 0

section .bss
    buffer resb 30
    rows resb 1
    columns resb 1
    mtxA resd 10*10
    mtxB resd 10*10
    mtxC resd 10*10

section .code
_start:
get_size:
    puts inMSG1
    puts nwln
    puts inMSG2
    fgets buffer, 4
    a2i 4, buffer
    mov [rows], eax
    puts inMSG3
    fgets buffer, 4
    a2i 4, buffer
    mov [columns], eax
read_matrices:
    push mtxA
    call read_matrix_ROWMAJOR
    push mtxB
    call read_matrix_ROWMAJOR
add_matrices:
    push mtxA
    push mtxB
    push mtxC
    call matrix_add
print_result:
    push mtxC
    call print_matrix
finish:
    push 0
    call ExitProcess

;---------------------------------------------------
;read matrices A and B in row major mode

read_matrix_ROWMAJOR:
    enter 0, 0
    pushad
    xor ECX, ECX
    mov DL, [rows]
    mov EBX, DWORD [EBP+8]
    puts inMSG4
    puts nwln
read_row:
    mov CL, [columns]
read_col:
    fgets buffer, 11
    a2i 11, buffer
    mov [EBX], EAX
    add EBX, 4
    loop read_col
    puts sep
    puts nwln
    dec DL
    cmp DL, 0
    jne read_row
    popad
    leave
    ret 4

;----------------------------------------------
;add A and B and save the result in C (row major)

matrix_add:
    enter 0, 0
    pushad
    xor EBX, EBX
row_loop:
    xor ECX, ECX
col_loop:
    xor EDI, EDI
    xor ESI, ESI
mtxA_index:
    xor EAX, EAX
    mov AL, [columns]
    mul BL
    add AX, CX
    mov ESI, EAX
    mov EAX, DWORD [EBP+16]
    add EDI, [EAX+ESI*4]
mtxB_index:
    mov EAX, DWORD [EBP+12]
    add EDI, [EAX+ESI*4]
mtxC_index:
    xor EAX, EAX
    mov AL, [columns]
    mul BL
    add AX, CX
    mov ESI, EAX
    mov EAX, DWORD [EBP+8]
    mov [EAX+ESI*4], EDI
loop_conditions:
    inc CL
    cmp CL, [columns]
    je new_row
    jmp col_loop
new_row:
    inc BL
    cmp BL, [rows]
    je return
    jmp row_loop
return:
    popad
    leave
    ret 12

;-------------------------------------------------
;printing matrix C as the sum of matrices A and B

print_matrix:
    enter 0, 0
    pushad
    xor ECX, ECX
    mov DL, [rows]
    mov EBX, DWORD [EBP+8]
    puts outMSG
    puts nwln
print_row:
    mov CL, [columns]
print_col:
    mov EAX, [EBX]
    i2a EAX, buffer
    puts buffer
    puts htab
    add EBX, 4
    loop print_col
    puts nwln
    dec DL
    cmp DL, 0
    jne print_row
    popad
    leave
    ret 4