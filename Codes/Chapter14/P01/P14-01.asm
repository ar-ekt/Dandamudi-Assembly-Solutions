;   Must run in linux OS

%INCLUDE "lib.h"
global _start

%macro strlen 1
    push    ebx

    mov     ebx, %1         ; move the address of our message string into EBX
    mov     eax, ebx        ; move the address in EBX into EAX as well (Both now point to the same segment in memory)

nextchar:
    cmp     byte [eax], 0   ; compare the byte pointed to by EAX at this address against zero (Zero is an end of string delimiter)
    jz      finished        ; jump (if the zero flagged has been set) to the point in the code labeled 'finished'
    inc     eax             ; increment the address in EAX by one byte (if the zero flagged has NOT been set)
    jmp     nextchar        ; jump to the point in the code labeled 'nextchar'

finished:
    sub     eax, ebx        ; subtract the address in EBX from the address in EAX
                            ; remember both registers started pointing to the same address (see line 15)
                            ; but EAX has been incremented one byte for each character in the message string
                            ; when you subtract one memory address from another of the same type
                            ; the result is number of segments between them - in this case the number of bytes
    pop     ebx
%endmacro


SIZE equ 30                 ;Maximum string size

section .data
    enter_string_msg db "Please enter a string: ",0

section .bss
    string resb SIZE

section .code
_start:

    puts enter_string_msg
    fgets string, SIZE

    strlen string

    ;sys_write
    mov	edx,eax		; message length
    mov	ecx,string	; message to write
    mov	ebx,1		; file descriptor (stdout)
    mov	eax,4		; system call number (sys_write)
    int	0x80		; call kernel        

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80