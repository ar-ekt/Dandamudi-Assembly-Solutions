;xlat is used to select an index of a given table
;in this problem, we need to map a specific character to the appropriate index of the encryption table
;so the xlatb instruction is used with the digit minus 48, as crypt_table's index


global _start
extern ExitProcess
%include "lib.h"

section .data
    crypt_table db "4695031872"
    in_MSG db "enter a string (len<100): ", 0
    out_MSG db "encrypted: ", 0
    query_msg db "terminate the program? (Y/y to terminate, anything else to continue): ", 0
    nwln db 10, 0

section .bss
    inBuffer resb 105
    outBuffer resb 5

section .code
_start:
    puts in_MSG
    fgets inBuffer, 105
    puts out_MSG
    xor ESI, ESI
char_loop:
    mov AL, [inBuffer+ESI]
    cmp AL, 0
    je finish
    cmp AL, 48
    jge upper_interval
    jmp non_digit
upper_interval:
    cmp AL, 57
    jg non_digit
    jmp encrypt
non_digit:
    mov [outBuffer], AL
    xor AL, AL
    mov [outBuffer+1], AL             ;terminating character
    puts outBuffer
    inc ESI
    jmp char_loop
encrypt:
    mov EBX, crypt_table
    sub AL, 48                        ;turning the digit ascii value to an index of crypt_table
    xlatb                             ;using xlatb to select the encrypted character from crypt_table
    mov [outBuffer], AL
    xor AL, AL
    mov [outBuffer+1], AL
    puts outBuffer
    inc ESI
    jmp char_loop
finish:
    puts nwln
query:
    puts query_msg                    ;query user whether to terminate
    fgets inBuffer, 10
    cmp [inBuffer], BYTE 'Y'
    je is_yes
    cmp [inBuffer], BYTE 'y'
    je is_yes
    jmp _start
is_yes:
    cmp [inBuffer+1], BYTE 0
    je terminate
    jmp _start
terminate:
    push 0
    call ExitProcess