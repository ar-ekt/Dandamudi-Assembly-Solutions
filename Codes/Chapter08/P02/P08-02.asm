
;modified version of Program 8.1: Linear search of an integer array
;in this program, input is assumed to be given in a sorted manner (ascending order)

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