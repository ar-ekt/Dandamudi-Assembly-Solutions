global _start
extern ExitProcess
%include "lib.h"

section .data
    in_MSG db "Please input a positive number (<65,535): ", 0
    outMSG db "/4 = ", 0
    query_MSG db "Do you want to terminate the program (Y/N): ", 0
    nwln db 10, 0

section .bss
    inBuffer resb 8
    outBuffer resb 8

section .code
_start:
    puts in_MSG
    fgets inBuffer, 8
    xor ESI, ESI
    xor EAX, EAX                ;holds the number
conversion_loop:
    xor EBX, EBX
    mov BL, [inBuffer+ESI]
    cmp BL, 0
    je divide_by_4
    sub BL, 48
    mov EDX, EAX
    shl EDX, 1                  ;python: (n << 3) + (n << 1) = 8n + 2n = 10n
    shl EAX, 3
    add EAX, EDX
    add EAX, EBX                ;XY = 10X + Y
    inc ESI
    jmp conversion_loop
divide_by_4:
    shr EAX, 2                  ;result is in EAX
print_and_finish:
    puts inBuffer
    puts outMSG
    i2a EAX, outBuffer
    puts outBuffer
    puts nwln
query:
    puts query_MSG              ;query user whether to terminate
    fgets inBuffer, 10
    cmp [inBuffer], BYTE 'Y'
    je is_yes
    cmp [inBuffer], BYTE 'N'
    je is_no
    jmp query
is_yes:
    cmp [inBuffer+1], BYTE 0
    je done
    jmp query
is_no:
    cmp [inBuffer+1], BYTE 0
    je _start
    jmp query
done:
    push 0
    call ExitProcess
    