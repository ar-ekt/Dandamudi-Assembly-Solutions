global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    nwln db 10, 0
    inMSG db "enter a string less than 100 characters long:", 0
    outMSG db "leading and duplicate blanks removed:", 0

section .bss
    buffer1 resb 102
    buffer2 resb 102

section .code
_start:
    puts inMSG
    puts nwln
    fgets buffer1, 102
    push buffer1
    push buffer2
    call clean_string
    puts outMSG
    puts nwln
    puts buffer2
    puts nwln
    push 0
    call ExitProcess

;-------------proc clean_string------------;
;                                          ;
; removes all leading and duplicate blanks ;
;   *removes only the space characters*    ;
;                                          ;
;------------------------------------------;

%define str1 DWORD [EBP+12]
%define str2 DWORD [EBP+8]

clean_string:
    enter 0, 0
    push EAX                ;preserving the values of EAX, EBX, and DX
    push EBX
    push DX
    mov EAX, str1
    mov EBX, str2
    xor DX, DX              ;using DL as a flag for duplicates, and DH to hold temp characters
leading_blanks:
    mov DH, [EAX]
    cmp DH, 32              ;ascii 32 is the space character
    je continue
    mov [EBX], DH
    inc EBX
    inc EAX
    jmp duplicates
continue:
    inc EAX
    jmp leading_blanks
duplicates:
    mov DH, [EAX]
    cmp DH, 0
    je end
    cmp DH, 32
    je space
    cmp DL, 1
    je insert_space
    mov [EBX], DH
    inc EBX
    inc EAX
    jmp duplicates
space:
    cmp DL, 1
    je skip
    mov DL, 1
skip:
    inc EAX
    jmp duplicates
insert_space:
    mov DL, 0
    mov [EBX], BYTE 32
    inc EBX
    mov [EBX], DH
    inc EBX
    inc EAX
    jmp duplicates
end:
    cmp DL, 1
    je last_space
    mov [EBX], BYTE 0
    jmp finish
last_space:
    mov [EBX], BYTE 32
    inc EBX
    mov [EBX], BYTE 0
finish:
    pop DX
    pop EBX
    pop EAX
    leave
    ret 8