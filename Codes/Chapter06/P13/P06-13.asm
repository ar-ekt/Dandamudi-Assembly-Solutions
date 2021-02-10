global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro geti 0
    fgets buffer, 15
    a2i 15, buffer
%endmacro

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_ROW_COL EQU 15

    NEWLINE db 10, 0
    TAB db 9, 0
    
    MSG_ROW_COL_INPUT db "Enter matrix number of rows(=columns): ", 0
    
    MSG_CELL_INPUT1 db "matrix[", 0
    MSG_CELL_INPUT2 db "][", 0
    MSG_CELL_INPUT3 db "] = ", 0
    
    MSG_DIAGONAL_OUTPUT db "Matrix is diagonal", 10, 0
    MSG_UPPERTRIANGULAR_OUTPUT db "Matrix is upper triangular", 10, 0
    MSG_LOWERTRIANGULAR_OUTPUT db "Matrix is lower triangular", 10, 0
    MSG_NOONE_OUTPUT db "Matrix doesn't have any specific type", 10, 0
    
section .bss
    buffer resb 100
    matrix resd (MAX_ROW_COL*MAX_ROW_COL)+1

section .code
_start:
    push DWORD 0
    push matrix
    call matrixInput
    pop EBX
    
    push EBX
    push matrix
    call isLowerTriangularMatrix
    
    push EBX
    push matrix
    call isUpperTriangularMatrix
    
    push ESI
    push EDI
    call matrixTypeOutput
    
_end:
    push DWORD 0
    call ExitProcess


matrixInput:
    %define matrix DWORD [EBP+8]
    %define numColRow DWORD [EBP+12]
    enter 0, 0
    pushad
    
matRowColInput:
    puts MSG_ROW_COL_INPUT
    geti
    cmp EAX, MAX_ROW_COL
    jg matRowColInput
    cmp EAX, 1
    jl matRowColInput
    mov numColRow, EAX
    
cellsInput:
    mov ESI, matrix
    mov ECX, 0-1
    
rowsInput:
    inc ECX
    cmp ECX, numColRow
    jge matrixInput_done
    mov EDX, 0-1
    
columnsInput:
    inc EDX
    cmp EDX, numColRow
    jge rowsInput
    
    puts MSG_CELL_INPUT1
    puti ECX
    puts MSG_CELL_INPUT2
    puti EDX
    puts MSG_CELL_INPUT3
    geti
    mov [ESI], EAX
    add ESI, 4
    
    jmp columnsInput
    
matrixInput_done:
    popad
    leave
    ret 8-4

isUpperTriangularMatrix:
    %define matrix DWORD [EBP+8]
    %define numColRow DWORD [EBP+12]
    enter 0, 0
    push EAX
    push EBX
    push ECX
    
    mov ECX, 0-1
    
rowUpperLoop:
    inc ECX
    cmp ECX, numColRow
    je UpperTriangular_allZero
    mov EBX, 0-1
    
colUpperLoop:
    inc EBX
    cmp EBX, ECX
    jge rowUpperLoop
    
    mov EAX, ECX
    mul numColRow
    add EAX, EBX
    shl EAX, 2
    add EAX, matrix
    cmp [EAX], DWORD 0
    jne UpperTriangular_nonZero
    jmp colUpperLoop

UpperTriangular_allZero:
    mov EDI, 1
    jmp isUpperTriangularMatrix_end
    
UpperTriangular_nonZero:
    mov EDI, 0
    
isUpperTriangularMatrix_end:
    pop ECX
    pop EBX
    pop EAX
    leave
    ret 8


isLowerTriangularMatrix:
    %define matrix DWORD [EBP+8]
    %define numColRow DWORD [EBP+12]
    enter 0, 0
    push EAX
    push EBX
    push ECX
    
    mov ECX, 0-1
    
rowLowerLoop:
    inc ECX
    cmp ECX, numColRow
    je LowerTriangular_allZero
    mov EBX, ECX
    
colLowerLoop:
    inc EBX
    cmp EBX, numColRow
    jge rowLowerLoop
    
    mov EAX, ECX
    mul numColRow
    add EAX, EBX
    shl EAX, 2
    add EAX, matrix
    cmp [EAX], DWORD 0
    jne LowerTriangular_nonZero
    jmp colLowerLoop

LowerTriangular_allZero:
    mov ESI, 1
    jmp isLowerTriangularMatrix_end
    
LowerTriangular_nonZero:
    mov ESI, 0
    
isLowerTriangularMatrix_end:
    pop ECX
    pop EBX
    pop EAX
    leave
    ret 8

matrixTypeOutput:
    %define isUpperTriangular DWORD [EBP+8]
    %define isLowerTriangular DWORD [EBP+12]
    enter 0, 0
    
    cmp isUpperTriangular, 1
    je isUpperOutput
    
    cmp isLowerTriangular, 1
    je isLowerOutput
    
    puts MSG_NOONE_OUTPUT
    jmp matrixTypeOutput_end
    
isLowerOutput:
    puts MSG_LOWERTRIANGULAR_OUTPUT
    jmp matrixTypeOutput_end

isUpperOutput:
    cmp isLowerTriangular, 1
    je isDiagonalOutput
    
    puts MSG_UPPERTRIANGULAR_OUTPUT
    jmp matrixTypeOutput_end

isDiagonalOutput:
    puts MSG_DIAGONAL_OUTPUT

matrixTypeOutput_end:
    leave
    ret 8
