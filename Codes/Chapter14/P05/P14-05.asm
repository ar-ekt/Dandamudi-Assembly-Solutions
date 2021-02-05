%INCLUDE "lib.h"
global _start

section .data
    create_msg db ">> Directory Path (Create): ", 0
    remove_msg db ">> Directory Path (Remove): ", 0
    error_msg db ">> An Error Has Occurred, Its Code Is ", 0
    done_msg db ">> Done!", 0
    endl db 10, 0

section .bss
    inp_buffer resd 8
    inp_path resd 256

section .code
_start:
    puts create_msg
    fgets inp_path, 256
    push inp_path
    call create_dir
    puts remove_msg
    fgets inp_path, 256
    push inp_path
    call remove_dir
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE PATH DWORD [EBP + 8]

;---------------------------------proc create_dir------------------------------------;
; This procedure takes a path (i.e., pointer to directory path string) via the stack ;
; and creates given path. In case procedure fail, it will report error number.       ;
;------------------------------------------------------------------------------------;

create_dir:
    enter 0, 0
    push eax
    push ebx
    push ecx
    mov eax, 39         ; EAX = 39
    mov ebx, PATH       ; EBX = path
    mov ecx, 0700o      ; ECX = permissions
    int 0x80
check_create_error:
    cmp eax, 0          ; EAX = 0 if no error
        je create_successful
    puts error_msg
    i2a eax, inp_buffer ; EAX = error code
    puts inp_buffer
    puts endl
    jmp create_end
create_successful:
    puts done_msg
    puts endl
create_end:
    pop ecx
    pop ebx
    pop eax
    leave 
    ret 4

;---------------------------------proc remove_dir------------------------------------;
; This procedure takes a path (i.e., pointer to directory path string) via the stack ;
; and removes given path. In case procedure fail, it will report error number.       ;
;------------------------------------------------------------------------------------;

remove_dir:
    enter 0, 0
    push eax
    push ebx
    mov eax, 40         ; EAX = 40
    mov ebx, PATH       ; EBX = path
    int 0x80
    cmp eax, 0          ; EAX = 0 if no error
        je remove_successful
    puts error_msg
check_remove_error:
    i2a eax, inp_buffer ; EAX = error code
    puts inp_buffer
    puts endl
    jmp remove_end
remove_successful:
    puts done_msg
    puts endl
remove_end:
    pop ebx
    pop eax
    leave 
    ret 4