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
    MAX_SIZE EQU 100

    MSG_ARRAY_INPUT db "Please enter input array: (negative number terminates input)", 10, 0
    MSG_MEMBER_INPUT1 db "Array[", 0
    MSG_MEMBER_INPUT2 db "] = ", 0
    
    MSG_ARRAY_OUTPUT1 db "SortedArray = [", 0
    MSG_COMMA db ", ", 0
    MSG_ARRAY_OUTPUT2 db "]", 10, 0

section .bss
    array resd MAX_SIZE
    buffer resb 100

section .code
_start:
    push array
    call inputArray
    pop ECX

    push ECX
    push array
    call insertionSort

    push ECX
    push array
    call printArray

_end:
    push 0
    call ExitProcess


inputArray:
    %define len DWORD [EBP+8]
    %define array DWORD [EBP+8]
    enter 0,0
    push EAX
    push ECX
    push ESI
    
    mov ESI, array
    xor ECX, ECX
    
    puts MSG_ARRAY_INPUT
    inputArray_loop:
        
        inputMember:
            puts MSG_MEMBER_INPUT1
            puti ECX
            puts MSG_MEMBER_INPUT2

            geti
            mov [ESI], EAX
        
        inputMember_done:
            cmp EAX, 0
            jl inputArray_done
            
            add ESI, 4
            inc ECX
            jmp inputArray_loop
        
    inputArray_done:
        mov len, ECX
        
        pop ESI
        pop ECX
        pop EAX
        leave
        ret 4-4

insertionSort:
    %define len DWORD [EBP+12]
    %define array DWORD [EBP+8]
    enter 0, 0
    push EBX
    push ECX
    push EDX
    push EDI
    push ESI
    
    mov ESI, array
    xor ECX, ECX
    
    insertionSort_loop1:
        inc ECX
        cmp ECX, len
        je insertionSort_done
        
        mov EBX, [ESI+ECX*4]
        mov EDX, ECX
        dec EDX
        
        insertionSort_loop2:
            cmp EDX, 0
            jl insertionSort_loop2_done
            
            mov EDI, [ESI+EDX*4]
            cmp EBX, EDI
            jle insertionSort_loop2_done
            
            shiftMemberRight:
                mov [ESI+EDX*4+4], EDI
                dec EDX
                jmp insertionSort_loop2
            
            insertionSort_loop2_done:
                mov [ESI+EDX*4+4], EBX
                jmp insertionSort_loop1
                
    insertionSort_done:
        pop ESI
        pop EDI
        pop EDX
        pop ECX
        pop EBX
        leave
        ret 8-0

printArray:
    %define len DWORD [EBP+12]
    %define array DWORD [EBP+8]
    enter 0, 0
    push ESI

    mov ESI, array
    
    puts MSG_ARRAY_OUTPUT1
    printArray_loop:
        printMember:
            puti [ESI]
            
            printMember_done:
                dec len
                jz printArray_done
                
                add ESI, 4
                puts MSG_COMMA
                jmp printArray_loop
            
    printArray_done:
        puts MSG_ARRAY_OUTPUT2
        
        pop ESI
        leave
        ret 8-0
