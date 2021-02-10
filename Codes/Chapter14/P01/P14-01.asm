; Should run in linux, add ExitProcess in windows-os
%INCLUDE "lib.h" ; no usage
global _start

%macro PutStr 1
    pushad
    xor ecx, ecx
    mov esi, %1
    %%_strlen:
        inc ecx
        lodsb
        cmp al, 0
        jne %%_strlen
    dec ecx

    ; sys_write
    mov	edx, ecx    ; message length
    mov	ecx, %1 	; message to write
    mov	ebx, 1		; file descriptor (stdout)
    mov	eax, 4		; system call number (sys_write)
    int	0x80		; call kernel  

    popad
%endmacro

SIZE equ 30 ; Maximum string size

section .data
    enter_string_msg db "Please enter a string: ",0
    enter_string_msg_len equ $- enter_string_msg

section .bss
    string resb SIZE

section .code
_start:

    ; sys_write     ; puts enter_string_msg
    mov edx, enter_string_msg_len
    mov ecx, enter_string_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ; sys_read      ; fgets string, SIZE
    mov ebx, 2
    mov ecx, string  
    mov edx, SIZE
    mov eax, 3
    int 80h

    PutStr string  

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80