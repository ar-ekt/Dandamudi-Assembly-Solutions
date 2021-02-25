;NOTE:
;in order for this to be assembled properly, do the following:

;if you're on windows:
;first, in asmw, comment all lines starting from line 10, because we only want the .obj file
;then, assemble bubble_sort.asm: ./asmw bubble_sort.asm
;then, uncomment the lines you just commented in asmw
;now modify line 13 of asmw to look like this:
;./GoLink.exe /console /entry _start /ni "${k}.obj" "bubble_sort.obj" "libw.obj" kernel32.dll
;then assemble main.asm: ./asmw main.asm
;roll back the changes so you can use asmw with other files

;if you're on linux:
;first, modify main.asm to run on linux (change exit method)
;now, in asm, comment all lines starting from line 8, because we only want the .o file
;then, assemble bubble_sort.asm: ./asm bubble_sort.asm
;then, uncomment the lines you just commented in asm
;now modify line 11 of asm to look like this:
;ld -m elf_i386 "${k}.o" "bubble_sort.o" "lib.o" -o "${k}"
;then assemble main.asm: ./asm main.asm
;roll back the changes so you can use asm with other files

;--------------------------------------------------------------------

;Bubble sort procedure BBLSORT.ASM
; Objective: To implement the bubble sort algorithm.
; Input: A set of nonzero integers to be sorted.
; Input is terminated by entering zero.
; Output: Outputs the numbers in ascending order.

global _start
extern bubble_sort, ExitProcess
%include "lib.h"

%define CRLF 0DH,0AH
MAX_SIZE EQU 20

section .data
    prompt_msg db "Enter nonzero integers to be sorted.",CRLF
               db "Enter zero to terminate the input.",0
    output_msg db "Input numbers in ascending order:",0
    nwln db 10, 0

section .bss
    array resd MAX_SIZE             ; input array for integers
    inBuffer resb 20
    outBuffer resb 20

section .code
_start:
    puts prompt_msg                 ; request input numbers
    puts nwln
    mov EBX, array                  ; EBX = array pointer
    mov ECX, MAX_SIZE               ; ECX = array size
    sub EDX, EDX                    ; number count = 0
read_loop:
    fgets inBuffer, 20
    a2i 20, inBuffer
    cmp EAX, 0                      ; if the number is zero
    je stop_reading                 ; no more numbers to read
    mov [EBX], EAX                  ; copy the number into array
    add EBX, 4                      ; EBX points to the next element
    inc EDX                         ; increment number count
    loop read_loop                  ; reads a max. of MAX_SIZE numbers
stop_reading:
    push EDX                        ; push array size onto stack
    push array                      ; place array pointer on stack
    call bubble_sort
    puts output_msg                 ; display sorted input numbers
    puts nwln
    mov EBX, array
    mov ECX, EDX                    ; ECX = number count
print_loop:
    mov EAX, [EBX]
    i2a EAX, outBuffer
    puts outBuffer
    puts nwln
    add EBX, 4
    loop print_loop
done:
    push 0
    call ExitProcess