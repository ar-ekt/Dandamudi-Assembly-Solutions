global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro geti 0
    fgets buffer, 12
    a2i 12, buffer
%endmacro

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_COL EQU 10
    MAX_ROW EQU 10

    NEWLINE db 10, 0
    TAB db 9, 0
    
    MSG_MAT1_ROW_INPUT db "Enter first matrix number of rows: ", 0
    MSG_MAT1_COL_INPUT db "Enter first matrix number of columns: ", 0
    
    MSG_MAT2_ROW_INPUT db "Second matrix number of rows = ", 0
    MSG_MAT2_COL_INPUT db "Enter second matrix number of columns: ", 0
    
    MSG_CELL_INPUT1 db "matrix", 0
    MSG_CELL_INPUT2 db "[", 0
    MSG_CELL_INPUT3 db "][", 0
    MSG_CELL_INPUT4 db "] = ", 0
    
    RESULT db "Result: ", 10, 0
    
section .bss
    buffer resb 100
    matrix1 resd (MAX_COL*MAX_ROW)+1
    matrix2 resd (MAX_COL*MAX_ROW)+1
    matrix3 resd (MAX_COL*MAX_ROW)+1

section .code
_start:
    push DWORD 1
    push DWORD 0
    push DWORD 0
    push matrix1
    call matrixInput
    pop ECX
    pop EBX
    
    puts NEWLINE
    
    push DWORD 2
    push ECX
    push DWORD 0
    push matrix2
    call matrixInput
    pop EDX
    
    push EDX
    push EBX
    push ECX
    push matrix3
    push matrix2
    push matrix1
    call matrixMultiply
    
    push EBX
    push EDX
    push matrix3
    call matrixPrint
    
_end:
    push DWORD 0
    call ExitProcess

matrixInput:
    %define matrix DWORD [EBP+8]
    %define numCol DWORD [EBP+12]
    %define numRow DWORD [EBP+16]
    %define firstOrSecond DWORD [EBP+20]
    enter 0, 0
    pushad
    
    cmp firstOrSecond, DWORD 1
    je mat1SizeInput
    jne mat2SizeInput
    
mat1SizeInput:
mat1RowInput:
    puts MSG_MAT1_ROW_INPUT
    geti
    cmp EAX, MAX_ROW
    jg mat1RowInput
    cmp EAX, 1
    jl mat1RowInput
    mov numRow, EAX

mat1ColInput:
    puts MSG_MAT1_COL_INPUT
    geti
    cmp EAX, MAX_COL
    jg mat1ColInput
    cmp EAX, 1
    jl mat1ColInput
    mov numCol, EAX
    jmp cellsInput
        
mat2SizeInput:
mat2RowInput:
    puts MSG_MAT2_ROW_INPUT
    puti numRow
    puts NEWLINE
    
mat2ColInput:
    puts MSG_MAT2_COL_INPUT
    geti
    cmp EAX, MAX_COL
    jg mat2ColInput
    cmp EAX, 1
    jl mat2ColInput
    mov numCol, EAX
    
cellsInput:
    mov ESI, matrix
    mov ECX, 0-1
    
rowsInput:
    inc ECX
    cmp ECX, numRow
    jge matrixInput_done
    mov EBX, 0-1
    
columnsInput:
    inc EBX
    cmp EBX, numCol
    jge rowsInput
    
    puts MSG_CELL_INPUT1
    puti firstOrSecond
    puts MSG_CELL_INPUT2
    puti ECX
    puts MSG_CELL_INPUT3
    puti EBX
    puts MSG_CELL_INPUT4
    geti
    
    mov EDI, EAX
    mov EAX, EBX
    mul numRow
    add EAX, ECX
    shl EAX, 2
    mov [ESI+EAX], EDI
    
    jmp columnsInput
    
matrixInput_done:
    popad
    leave
    ret 12-8
    %undef numRow
    %undef numCol
    %undef matrix


matrixMultiply:
    %define matrix1 DWORD [EBP+8]
    %define matrix2 DWORD [EBP+12]
    %define result DWORD [EBP+16]
    %define numCol1 DWORD [EBP+20]
    %define numRow1 DWORD [EBP+24]
    %define numCol2 DWORD [EBP+28]
    
    %define cellSum DWORD [EBP-4]
    %define cellTemp DWORD [EBP-8]
    enter 8, 0
    pushad
    
    mov EDI, result
    xor ESI, ESI
    
mat1RowLoop:
    xor ECX, ECX
    
mat2ColLoop:
    mov cellSum, DWORD 0
    xor EBX, EBX
    
cellLoop:
    mov EAX, EBX
    mul numRow1
    add EAX, ESI
    shl EAX, 2
    add EAX, matrix1
    mov EDX, [EAX]
    mov cellTemp, EDX
    
    mov EAX, ECX
    mul numCol1
    add EAX, EBX
    shl EAX, 2
    add EAX, matrix2
    mov EDX, EAX
    mov EAX, [EDX]
    
    mul cellTemp
    add cellSum, EAX
    
    inc EBX
    cmp EBX, numCol1
    jne cellLoop
    
nextCol:
    mov EAX, ECX
    mul numCol2
    add EAX, ESI
    shl EAX, 2
    mov EDX, cellSum
    mov [EDI+EAX], EDX
    
    inc ECX
    cmp ECX, numCol2
    jne mat2ColLoop

nextRow:
    inc ESI
    cmp ESI, numRow1
    jne mat1RowLoop
        
matrixMultiply_done:
    popad
    leave
    ret 24
    %undef matrix1
    %undef matrix2
    %undef result
    %undef numCol1
    %undef numRow1
    %undef numCol2

matrixPrint:
    %define matrix DWORD [EBP+8]
    %define numCol DWORD [EBP+12]
    %define numRow DWORD [EBP+16]
    enter 0,0
    pushad
    
    puts NEWLINE
    puts RESULT
    
    mov ESI, matrix
    mov ECX, 0
    
rowsPrint:
    cmp ECX, numRow
    jge matrixPrint_done
    mov EBX, 0-1
    
columnsPrint:
    inc EBX
    cmp EBX, numCol
    jge cols_done
    
    mov EAX, EBX
    mul numRow
    add EAX, ECX
    shl EAX, 2
    puti [ESI+EAX]
    puts TAB
    jmp columnsPrint

cols_done:
    puts NEWLINE
    inc ECX
    ja rowsPrint

matrixPrint_done:    
    popad
    leave
    ret 12
    %undef numRow
    %undef numCol
    %undef matrix
