%INCLUDE "lib.h"
global _start

section .data
    change_msg db ">> Directory Path (Change): ", 0
    error_msg db ">> An Error Has Occurred, Its Code Is ", 0
    done_msg db ">> Directory Exists.", 0
    endl db 10, 0

section .bss
    inp_buffer resd 8
    inp_path resd 256

section .code
_start:
    puts change_msg
    fgets inp_path, 256
    push inp_path
    call change_dir
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE PATH DWORD [EBP + 8]

;----------------------------------proc change_dir------------------------------------;
; This procedure takes a path (i.e., pointer to directory path string) via the stack  ;
; and change current working directory to given path. In case procedure fail, it will ;
; report error number.                                                                ;
;-------------------------------------------------------------------------------------;

change_dir:
    enter 0, 0
    push eax
    push ebx
    mov eax, 12         ; EAX = 12
    mov ebx, PATH       ; EBX = path
    int 0x80
check_change_error:
    cmp eax, 0          ; EAX = 0 if no error
        je change_successful
    puts error_msg
    i2a eax, inp_buffer ; EAX = error code
    puts inp_buffer
    puts endl
    jmp change_end
change_successful:
    puts done_msg
    puts endl
change_end:
    pop ebx
    pop eax
    leave 
    ret 4