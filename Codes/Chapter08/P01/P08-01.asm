;modified version of Program 8.1: Linear search of an integer array

global _start
extern ExitProcess
%include "lib.h"

MAX_SIZE EQU 100

section .data
    inMSG1 db "Enter the integer array (first entry is the array size): ", 0
    inMSG2 db "Enter the number to be searched: ", 0
    outMSG db "The number is at position ",0
    notFoundMSG db "Number not in the array!",0
    queryMSG db "Do you want to quit (Y/N): ",0
    testing db "testing ", 10, 0
    nwln db 10, 0

section .bss
    outBuffer resb 10
    tempBuffer resb 20
    inBuffer resb 500
    int_array resw MAX_SIZE
    size resd 1

section .code
_start:
    puts inMSG1
    puts nwln
    fgets inBuffer, 500
    xor esi, esi
get_size:
    mov al, [inBuffer+esi]
    cmp al, ' '
    je set_size
    mov [tempBuffer+esi], al
    inc esi
    jmp get_size
set_size:
    mov [tempBuffer+esi], byte 0
    a2i 20, tempBuffer              ;array size is placed in eax
    mov [size], eax
    inc esi
    xor ecx, ecx                    ;count, max is [size]
    xor edi, edi                    ;index for tempBuffer
get_entries:
    mov al, [inBuffer+esi]
    cmp al, ' '
    je place_num_in_array
    cmp al, 0                       ;ascii code for newline character
    je place_num_in_array
    mov [tempBuffer+edi], al
    inc edi
    inc esi
    jmp get_entries
place_num_in_array:
    mov [tempBuffer+edi], byte 0
    a2i 20, tempBuffer              ;number is placed in eax, but we only need ax
    mov [int_array+ecx*2], ax
    xor edi, edi
    inc esi
    inc ecx
    mov ebx, [size]
    cmp ecx, ebx                    ;if ecx reached size, terminate the loop
    je get_target
    jmp get_entries
get_target:
    puts inMSG2
    fgets inBuffer, 20
    a2i 20, inBuffer                ;target is placed in eax, but we only need ax
call_search_proc:
    push ax
    mov edx, [size]
    push edx
    push int_array
    call linear_search
print_result:
    cmp ax, 0                       ;if ax is 0, the number wasn't found in the array
    je not_found
    puts outMSG
    xor ebx, ebx
    mov bx, ax
    i2a ebx, outBuffer
    puts outBuffer
    puts nwln
    jmp query_user
not_found:
    puts notFoundMSG
    puts nwln
query_user:                         ;query user whether to terminate the program
    puts queryMSG
    fgets inBuffer, 20
    mov al, [inBuffer]
    cmp al, 'Y'
    jne get_target                  ;if input is anything but 'Y', get another number to search for
finish_prog:                        ;else, terminate the program
    push 0
    call ExitProcess

;-----------------------------------------------------------
; This procedure receives a pointer to an array of integers,
; the array size, and a number to be searched via the stack.
; If found, it returns in AX the position of the number in
; the array; otherwise, returns 0.
; All registers, except EAX, are preserved.
;-----------------------------------------------------------
linear_search:
    enter 0,0
    push ebx                        ;save registers
    push ecx
    mov ebx, [ebp+8]                ;copy array pointer
    mov ecx, [ebp+12]               ;copy array size
    mov ax, [ebp+16]                ;copy number to be searched
    sub ebx, 2                      ;adjust index to enter loop
search_loop:
    add ebx, 2                      ;update array index
    cmp ax, [ebx]                   ;compare the numbers
    loopne search_loop
    mov ax, 0                       ;set return value to zero
    jne number_not_found            ;modify it if number found
    mov eax, [ebp+12]               ;copy array size
    sub eax, ecx                    ;compute array index of number
number_not_found:
    pop ecx                         ;restore registers
    pop ebx
    leave
    ret 10