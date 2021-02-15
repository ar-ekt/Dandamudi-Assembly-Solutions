global _start
extern ExitProcess
%include "lib.h"

section .data
;test1
    test_arrayX1 dw 2, 3, 5, 7, 7, 11, 19, 20, 20
    test_arrayY1 dw 3, 3, 4, 6, 8, 11, 11, 19, 21, 23, 25, 27
    test_sizeX1 db 9
    test_sizeY1 db 12
;test2
    test_arrayX2 dw 1, 3, 5, 7, 9, 11, 13, 15, 17, 19
    test_arrayY2 dw 2, 4, 6, 8, 10, 12, 14, 16, 18, 20
    test_sizeX2 db 10
    test_sizeY2 db 10

    test_msg1 db "test1: ", 0
    test_msg2 db "test2: ", 0
    space db 32, 0
    nwln db 10, 0

section .bss
    arrayZ resw 200
    outBuffer resb 20

section .code
_start:

test1:
    puts test_msg1
    push test_sizeY1
    push test_sizeX1
    push test_arrayY1
    push test_arrayX1
    push arrayZ
    call merge_sort
print_test1:
    xor ax, ax
    add al, [test_sizeX1]
    add al, [test_sizeY1]
    push ax                         ;size(Z) = size(X) + size(Y)
    push arrayZ
    call print_array

test2:
    puts test_msg2
    push test_sizeY2
    push test_sizeX2
    push test_arrayY2
    push test_arrayX2
    push arrayZ
    call merge_sort
print_test2:
    xor ax, ax
    add al, [test_sizeX2]
    add al, [test_sizeY2]
    push ax
    push arrayZ
    call print_array

finish_prog:
    push 0
    call ExitProcess
    
;proc merge_sort -> receives pointer to arrays X and Y, and their sizes m, and n,
;and merges these two into sorted array Z of size m+n

%define indexX WORD [ebp-2]
%define indexY WORD [ebp-4]

merge_sort:
    enter 4, 0
    pusha
set_sizes:
    mov eax, [ebp+20]
    mov cl, [eax]                   ;CL holds size of X
    mov eax, [ebp+24]
    mov ch, [eax]                   ;CH holds size of Y
set_indices:
    xor ax, ax                      ;initialize index of X and Y to 0
    mov indexX, ax
    mov indexY, ax
    xor esi, esi                    ;ESI holds index of Z, initialized to 0
merge_loop:
    xor edi, edi
    xor ax, ax
    mov al, cl
    mov di, indexX
    cmp di, ax                      ;if arrayX has reached the end
    je copy_rest
    mov eax, [ebp+12]               ;address of arrayX
    mov ax, [eax+edi*2]             ;arrayX entry
    xor bx, bx
    mov bl, ch
    mov di, indexY
    cmp di, bx                      ;if arrayY has reached the end
    je copy_rest
    mov ebx, [ebp+16]               ;address of arrayY
    mov bx, [ebx+edi*2]             ;arrayY entry
    cmp ax, bx
    jle x_smaller
    jmp y_smaller
x_smaller:
    mov ebx, [ebp+8]
    mov [ebx+esi*2], ax             ;move entry of X into the appropriate index of Z
    inc esi
    mov ax, indexX
    inc ax
    mov indexX, ax
    jmp merge_loop
y_smaller:
    mov eax, [ebp+8]
    mov [eax+esi*2], bx             ;move entry of Y into the appropriate index of Z
    inc esi
    mov ax, indexY
    inc ax
    mov indexY, ax
    jmp merge_loop
copy_rest:
    xor ax, ax
    mov al, cl
    mov di, indexX
    cmp di, ax                      ;if arrayX has reached the end, copy the rest of X directly into Z; otherwise, do this for Y
    jl copy_x
    mov al, ch
    mov di, indexY
    jmp copy_y
copy_x:
    cmp di, ax                      ;if index reaches the end, the sort procedure has finished
    jge finish_sort
    mov ebx, [ebp+12]
    mov dx, [ebx+edi*2]
    mov ebx, [ebp+8]
    mov [ebx+esi*2], dx
    inc esi
    inc di
    jmp copy_x
copy_y:
    cmp di, ax
    jge finish_sort
    mov ebx, [ebp+16]
    mov dx, [ebx+edi*2]
    mov ebx, [ebp+8]
    mov [ebx+esi*2], dx
    inc esi
    inc di
    jmp copy_y
finish_sort:
    popa
    leave
    ret 20

;proc print_array -> prints an integer array with integers of size WORD (2 BYTES)
print_array:
    enter 0, 0
    pusha
    xor esi, esi
    mov ebx, [ebp+8]
print_loop:
    cmp si, [ebp+12]
    je finish_print
    xor eax, eax
    mov ax, [ebx+esi*2]
    i2a eax, outBuffer
    puts outBuffer
    puts space
    inc esi
    jmp print_loop
finish_print:
    puts nwln
    popa
    leave
    ret 6
