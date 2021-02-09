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
    MAX_ROW EQU 12
    MAX_COL EQU 15

    NEWLINE db 10, 0
    TAB db 9, 0
    
    MSG_ROW_INPUT db "Enter matrix number of rows: ", 0
    MSG_COL_INPUT db "Enter matrix number of columns: ", 0
    
    MSG_CELL_INPUT1 db "matrix[", 0
    MSG_CELL_INPUT2 db "][", 0
    MSG_CELL_INPUT3 db "] = ", 0
    
    MSG_CYCLEN_INPUT db "Enter number of cycles(0<=): ", 0
    
    RESULT db "Result: ", 10, 0
    
section .bss
    buffer resb 100
    matrix resd (MAX_COL*MAX_ROW)+1
    result resd (MAX_COL*MAX_ROW)+1

section .code
_start:
    push DWORD 0
    push DWORD 0
    push matrix
    call matrixInput
    pop ECX
    pop EBX
    
    puts NEWLINE
cycleN_input_loop:
    puts MSG_CYCLEN_INPUT
    geti
    cmp EAX, 0
    jl cycleN_input_loop
    
    push EAX
    push EBX
    push ECX
    push result
    push matrix
    call matrixCyclicPermutation
    
    push EBX
    push ECX
    push result
    call matrixPrint
    
_end:
    push DWORD 0
    call ExitProcess

matrixInput:
    %define matrix DWORD [EBP+8]
    %define numCol DWORD [EBP+12]
    %define numRow DWORD [EBP+16]
    enter 0, 0
    pushad
    
matRowInput:
    puts MSG_ROW_INPUT
    geti
    cmp EAX, MAX_ROW
    jg matRowInput
    cmp EAX, 1
    jl matRowInput
    mov numRow, EAX

matColInput:
    puts MSG_COL_INPUT
    geti
    cmp EAX, MAX_COL
    jg matColInput
    cmp EAX, 1
    jl matColInput
    mov numCol, EAX
    
cellsInput:
    mov ESI, matrix
    mov ECX, 0-1
    
rowsInput:
    inc ECX
    cmp ECX, numRow
    jge matrixInput_done
    mov EDX, 0-1
    
columnsInput:
    inc EDX
    cmp EDX, numCol
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
    ret 12-8

matrixCyclicPermutation:
    %define matrix DWORD [EBP+8]
    %define result DWORD [EBP+12]
    %define numCol DWORD [EBP+16]
    %define numRow DWORD [EBP+20]
    %define cycleN DWORD [EBP+24]
    %define colMinusCycle DWORD [EBP-4]
    enter 4, 0
    pushad
    
    mov EAX, cycleN
    cmp EAX, numCol
    jl permute
cycleLoop:
    sub EAX, numCol
    cmp EAX, numCol
    jnl cycleLoop

permute:
    mov cycleN, EAX
    mov EAX, numCol
    sub EAX, cycleN
    mov colMinusCycle, EAX
    mov ECX, 0-1
    
rowLoop:
    inc ECX
    cmp ECX, numRow
    je matrixCyclicPermutation_end
    mov EBX, cycleN

colLoop1:
    mov EAX, ECX
    mul numCol
    add EAX, EBX
    shl EAX, 2
    add EAX, matrix
    mov EDI, [EAX]
    
    mov EAX, ECX
    mul numCol
    add EAX, EBX
    sub EAX, cycleN
    shl EAX, 2
    add EAX, result
    mov [EAX], EDI
    
    inc EBX
    cmp EBX, numCol
    jne colLoop1
    
    mov EBX, 0-1
    
colLoop2:
    inc EBX
    cmp EBX, cycleN
    je rowLoop
    
    mov EAX, ECX
    mul numCol
    add EAX, EBX
    shl EAX, 2
    add EAX, matrix
    mov EDI, [EAX]
    
    mov EAX, ECX
    mul numCol
    add EAX, EBX
    add EAX, numCol
    sub EAx, cycleN
    shl EAX, 2
    add EAX, result
    mov [EAX], EDI
    
    jmp colLoop2
    
matrixCyclicPermutation_end:
    popad
    leave
    ret 20-0


matrixPrint:
    %define matrix DWORD [EBP+8]
    %define numCol DWORD [EBP+12]
    %define numRow DWORD [EBP+16]
    enter 0, 0
    push ESI
    push EDX
    push ECX
    
    puts NEWLINE
    puts RESULT
    
    mov ESI, matrix
    mov ECX, numRow
    
rowsPrint:
    mov EDX, numCol
    
colsPrint:
    puti [ESI]
    add ESI, 4
    puts TAB
    sub EDX, 1
    ja colsPrint
    
cols_done:
    puts NEWLINE
    sub ECX, 1
    ja rowsPrint

matrixPrint_end:    
    pop ECX
    pop EDX
    pop ESI
    leave
    ret 12
