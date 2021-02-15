
;modified version of Program 8.1: Linear search of an integer array
;this program uses the selection sort procedure from Program 8.2

global _start
extern ExitProcess
%include "lib.h"

MAX_SIZE EQU 100

section .data
    input_prompt db "Please enter input array (negative number terminates input):", 0
    query_number db "Enter the number to be searched: ", 0
    out_msg db "The number is at position ", 0
    not_found_msg db "Number not in the array!", 0
    query_msg db "Do you want to quit (Y/N): ", 0
    nwln db 10, 0

section .bss
    int_array resw MAX_SIZE
    array_copy resw MAX_SIZE
    size resd 1
    inBuffer resb 20
    outBuffer resb 20

section .code
_start:
    puts input_prompt
    puts nwln
    mov EBX, int_array
    mov ECX, MAX_SIZE
array_loop:
    fgets inBuffer, 20
    a2i 20, inBuffer
    cmp AX,0                        ;negative number?
    jl exit_loop                    ;if so, stop reading numbers
    mov [EBX], AX                   ;otherwise, copy into array
    inc EBX                         ;increment array address
    inc EBX
    loop array_loop                 ;iterates a maximum of MAX_SIZE
exit_loop:
    mov EDX, EBX                    ;EDX keeps the actual array size
    sub EDX, int_array              ;EDX = array size in bytes
    sar EDX, 1                      ;divide by 2 to get array size
    mov [size], EDX
save_copy:
    push EDX
    push int_array                  ;save a copy of the exact input array to print correct indices at the end
    push array_copy
    call copy_array
sort_array:
    push EDX
    push int_array
    call selection_sort
read_input:
    puts query_number               ;request number to be searched for
    fgets inBuffer, 20              ;read the number
    a2i 20, inBuffer
    push AX                         ;push number, size & array pointer
    mov EDX, [size]
    push EDX
    push int_array
    call linear_search
    
;linear_search returns in AX the position of the number
;in the array; if not found, it returns 0.

    cmp AX, 0                       ;number found?
    je not_found                    ;if not, display number not found
    puts out_msg                    ;else, display number position
fix_index:
    push AX
    push int_array
    push array_copy
    call find_index                 ;find the correct index according to input array, result will be in AX
print_result:
    xor EBX, EBX
    mov BX, AX
    i2a EBX, outBuffer
    puts outBuffer
    jmp SHORT user_query
not_found:
    puts not_found_msg
user_query:
    puts nwln
    puts query_msg                  ;query user whether to terminate
    fgets inBuffer, 20              ;read response
    mov AL, [inBuffer]
    cmp AL, 'Y'                     ;if response is not 'Y'
    jne read_input                  ;repeat the loop
done:                               ;otherwise, terminate program
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
    push EBX                        ;save registers
    push ECX
    push EDX
    mov EBX, [EBP+8]                ;copy array pointer
    mov ECX, [EBP+12]               ;copy array size
    mov AX, [EBP+16]                ;copy number to be searched
    sub EBX, 2                      ;adjust index to enter loop
search_loop:
    add EBX, 2                      ;update array index
    xor DL, DL                      ;flag used for decision making in recheck
    cmp AX, [EBX]                   ;compare the numbers
    jl recheck
    je set_flag
    loop search_loop
    jmp recheck
set_flag:
    mov DL, 1                       ;flag is set if we break out of loop for finding an equal number
recheck:
    dec ECX
    mov AX, 0                       ;set return value to zero
    cmp DL, 1
    jne number_not_found            ;modify it if number found
    mov EAX, [EBP+12]               ;copy array size
    sub EAX, ECX                    ;compute array index of number
number_not_found:
    pop EDX
    pop ECX                         ;restore registers
    pop EBX
    leave
    ret 10

;-----------------------------------------------------------
; This procedure receives a pointer to an array of integers
; and the array size via the stack. The array is sorted by
; using the selection sort. All registers are preserved.
;-----------------------------------------------------------

%define SORT_ARRAY EBX

selection_sort:
    enter 0, 0
    pusha                           ;save registers
    mov EBX, [EBP+8]                ;copy array pointer
    mov ECX, [EBP+12]               ;copy array size
    sub ESI, ESI                    ;array left of ESI is sorted
sort_outer_loop:
    mov EDI, ESI

;DX is used to maintain the minimum value and AX
;stores the pointer to the minimum value
    
    mov DX, [SORT_ARRAY+ESI]        ;min. value is in DX
    mov EAX, ESI                    ;EAX = pointer to min. value
    push ECX
    dec ECX                         ;size of array left of ESI
sort_inner_loop:
    add EDI, 2                      ;move to next element
    cmp DX, [SORT_ARRAY+EDI]        ;less than min. value?
    jle skip1                       ;if not, no change to min. value
    mov DX, [SORT_ARRAY+EDI]        ;else, update min. value (DX)
    mov EAX, EDI                    ;& its pointer (EAX)
skip1:
    loop sort_inner_loop
    pop ECX
    cmp EAX, ESI                    ;EAX = ESI?
    je skip2                        ;if so, element at ESI is its place
    mov EDI, EAX                    ;otherwise, exchange
    mov AX, [SORT_ARRAY+ESI]        ;exchange min. value
    xchg AX, [SORT_ARRAY+EDI]       ;& element at ESI
    mov [SORT_ARRAY+ESI], AX
skip2:
    add ESI, 2                      ;move ESI to next element
    dec ECX
    cmp ECX, 1                      ;if ECX = 1, we are done
    jne sort_outer_loop
finish_sort:
    popa                            ;restore registers
    leave
    ret 8

;-------------------------------------------------------------
;This procedure copies a WORD int array from src to dest
;-------------------------------------------------------------
copy_array:
    enter 0, 0
    pusha
    mov EDX, [EBP+16]               ;size
    mov EAX, [EBP+12]               ;src array
    mov EBX, [EBP+8]                ;dest array
    xor ESI, ESI
copy_loop:
    cmp ESI, EDX
    je finish_copy
    mov CX, [EAX+ESI*2]
    mov [EBX+ESI*2], CX
    inc ESI
    jmp copy_loop
finish_copy:
    popa
    leave
    ret 12

;----------------------------------------------------------------
;This procedure, using the given index of the sorted array,
;finds the correct index according to the original input array.
;receives the index via stack and returns the correct index in AX
;-----------------------------------------------------------------
find_index:
    enter 0, 0
    push EBX
    push ECX
    push EDX
    push EDI
    xor EDI, EDI
    mov CX, [EBP+16]                ;position of the sorted array
    dec CX                          ;index = position-1
    mov DI, CX
    mov EBX, [EBP+12]               ;pointer to the sorted array
    mov DX, [EBX+EDI*2]             ;result number (number we were searching for)
    mov EBX, [EBP+8]                ;pointer to the original input array
    xor EDI, EDI
find_loop:
    mov CX, [EBX+EDI*2]
    cmp CX, DX
    je number_found
    inc EDI
    jmp find_loop
number_found:
    inc EDI                         ;position = index+1
    mov AX, DI                      ;return index in AX
finish_find:
    pop EDI
    pop EDX
    pop ECX
    pop EBX
    leave
    ret 10
