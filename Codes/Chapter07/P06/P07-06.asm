global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG db "N (0 < N < 53105): ", 0
    outMSG1 db "lhs: ", 0
    outMSG2 db "rhs: ", 0
    outMSG3 db "equal", 0
    nwln db 10, 0

section .bss
    inBuffer resb 20
    tempBuffer resw 1
    leftHandSide resd 1
    rightHandSide resd 1
    outBuffer resb 20

section .code
_start:
    puts inMSG
    fgets inBuffer, 20
    a2i 20, inBuffer
    mov [tempBuffer], ax
    mov ecx, eax
    xor edx, edx
add_loop:
    add edx, ecx
    loop add_loop
    mov [leftHandSide], edx
formula:
    mov ax, [tempBuffer]
    mov bx, ax
    inc bx
    mul bx
    shl edx, 16
    mov dx, ax
    shr edx, 1
    mov [rightHandSide], edx
print_results:
    mov edx, [leftHandSide]
    i2a edx, outBuffer
    puts outMSG1
    puts outBuffer
    puts nwln
    mov eax, [rightHandSide]
    i2a eax, outBuffer
    puts outMSG2
    puts outBuffer
    puts nwln
    cmp eax, edx
    je print_equal
    jmp finish
print_equal:
    puts outMSG3
    puts nwln
finish:
    push 0
    call ExitProcess
