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
    MAX_ROW EQU 10
    MAX_COL EQU 15

    NEWLINE db 10, 0
    TAB db 9, 0
    
    MSG_ROW_INPUT db "Enter matrix number of rows: ", 0
    MSG_COL_INPUT db "Enter matrix number of columns: ", 0
    
    MSG_CELL_INPUT1 db "matrix[", 0
    MSG_CELL_INPUT2 db "][", 0
    MSG_CELL_INPUT3 db "] = ", 0
    
    MSG_OUTPUT1 db "The maximum element is at (", 0
    MSG_OUTPUT2 db ", ", 0
    MSG_OUTPUT3 db ")", 10, 0
    
section .bss
    buffer resb 100
    matrix resd (MAX_COL*MAX_ROW)+1

section .code
_start:
    call main
    
_end:
    push DWORD 0
    call ExitProcess

main:
    enter 0, 0
    pushad
    
    push DWORD 0
    push DWORD 0
    push matrix
    call matrixInput
    pop ECX
    pop EBX
    
    push EBX
    push ECX
    push matrix
    call mat_max
    
    push ECX
    push EBX
    call print_result

end_main:
    popad
    leave
    ret 0-0

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

mat_max:
    %define matrix DWORD [EBP+8]
    %define numCol DWORD [EBP+12]
    %define numRow DWORD [EBP+16]
    %define maxVal DWORD [EBP-4]
    %define maxX DWORD [EBP-8]
    %define maxY DWORD [EBP-12]
    enter 12, 0
    pushad
    
    mov maxVal, 0-2147483648
    
    mov ESI, matrix
    sub ESI, 4
    
    mov EBX, 0-1
rowLoop:
    inc EBX
    cmp EBX, numRow
    je mat_max_end
    mov ECX, 0-1
    
colLoop:
    inc ECX
    cmp ECX, numCol
    je rowLoop
    
    add ESI, 4
    mov EDX, maxVal
    cmp [ESI], EDX
    jng colLoop

is_bigger:
    mov EDX, [ESI]
    mov maxVal, EDX
    mov maxX, EBX
    mov maxY, ECX
    jmp colLoop
    
mat_max_end:
    popad
    mov EBX, maxX
    mov ECX, maxY
    leave
    ret 12-0

print_result:
    %define maxX DWORD [EBP+8]
    %define maxY DWORD [EBP+12]
    enter 0, 0
    
    puts MSG_OUTPUT1
    puti maxX
    puts MSG_OUTPUT2
    puti maxY
    puts MSG_OUTPUT3

print_result_end:
    leave
    ret 8-0
