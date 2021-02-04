%INCLUDE "lib.h"
global _start

section .data
    inp_file1_msg db ">> File-1 name: ", 0
    inp_file2_msg db ">> File-2 name: ", 0
    error_msg db ">> File open error!", 10, 0
    done_msg db ">> Done!", 10, 0
    endl db 10, 0

section .bss
    file1_name resb 30
    file2_name resb 30
    fd_in1 resd 1
    fd_in2 resd 1
    inp_buffer resb 256

section .code
_start:
    puts inp_file1_msg
    fgets file1_name, 30
    puts inp_file2_msg
    fgets file2_name, 30
open_file1:
    mov eax, 5 ; file open
    mov ebx, file1_name ; pointer to file1 name
    mov ecx, 02001o ; file access bits (set file pointer at the end of the file for appending)
    mov edx, 0700o; file permissions
    int 0x80
    mov [fd_in1], eax ; store fd for use in write routine
check_open_error1:
    cmp eax, 0 ; open error if fd < 0
        jge open_file2
    puts error_msg
    jmp done
open_file2:
    mov eax, 5 ; file open
    mov ebx, file2_name ; pointer to file2 name
    mov ecx, 0 ; file access bits (0 = read only)
    mov edx, 0700o ; file permissions
    int 0x80
    mov [fd_in2], eax ; store fd for use in read routine
check_open_error2:
    cmp eax, 0 ; open error if fd < 0
        jge append_procces
    puts error_msg
    jmp close_file1
append_procces:
    ; read file2
    mov eax, 3 ; file read
    mov ebx, [fd_in2] ; file descriptor
    mov ecx, inp_buffer ; input buffer
    mov edx, 256 ; size
    int 0x80
    ; write (append) to file1
    mov edx, eax ; byte count
    mov eax, 4 ; file write
    mov ebx, [fd_in1] ; file descriptor
    mov ecx, inp_buffer
    int 0x80
    cmp edx, 256 ; EDX = # bytes read
        jl close_file2 ; EDX < BUF_SIZE
    ; indicates end-of-file
    jmp append_procces
close_file2:
puts done_msg
    mov eax, 6 ; close file2
    mov ebx, [fd_in2]
close_file1:
    mov eax, 6 ; close file1
    mov ebx, [fd_in1]
done:
    push 0
    mov eax, 1
    mov ebx, 0
    int 0x80