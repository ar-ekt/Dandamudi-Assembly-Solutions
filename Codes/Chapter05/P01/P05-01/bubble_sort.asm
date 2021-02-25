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

global bubble_sort
%include "lib.h"

section .code

;-----------------------------------------------------------
;This procedure receives a pointer to an array of integers
; and the size of the array via the stack. It sorts the
; array in ascending order using the bubble sort algorithm.
;-----------------------------------------------------------

SORTED EQU 0
UNSORTED EQU 1

bubble_sort:
    pushad
    mov EBP, ESP

; ECX serves the same purpose as the end_index variable
; in the C procedure. ECX keeps the number of comparisons
; to be done in each pass. Note that ECX is decremented
; by 1 after each pass.
    mov ECX, [EBP+40]               ; load array size into ECX

next_pass:
    dec ECX                         ; if # of comparisons is zero
    jz sort_done                    ; then we are done
    mov EDI, ECX                    ; else start another pass

;DL is used to keep SORTED/UNSORTED status
    mov DL, SORTED                  ; set status to SORTED
    mov ESI, [EBP+36]               ; load array address into ESI
; ESI points to element i and ESI+4 to the next element
pass:
; This loop represents one pass of the algorithm.
; Each iteration compares elements at [ESI] and [ESI+4]
; and swaps them if ([ESI]) < ([ESI+4]).

    mov EAX, [ESI]
    mov EBX, [ESI+4]
    cmp EAX, EBX
    jg swap

increment:
; Increment ESI by 4 to point to the next element
    add ESI, 4
    dec EDI
    jnz pass

    cmp EDX, SORTED                 ; if status remains SORTED
    je sort_done                    ; then sorting is done
    jmp next_pass                   ; else initiate another pass

swap:
; swap elements at [ESI] and [ESI+4]
    mov [ESI+4], EAX                ; copy [ESI] in EAX to [ESI+4]
    mov [ESI] ,EBX                  ; copy [ESI+4] in EBX to [ESI]
    mov EDX, UNSORTED               ; set status to UNSORTED
    jmp increment

sort_done:
    popad
    ret 8