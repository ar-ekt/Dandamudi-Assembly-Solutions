global _start
extern ExitProcess
%include "lib.h"

section .data
    inMSG1 db "enter the first number: ", 0
    inMSG2 db "enter the second number: ", 0
    outMSG db "result of subtraction: ", 0
    negative_sign db "-", 0
    nwln db 10, 0

section .bss
    number1 resb 50
    number2 resb 50
    result resb 50
    temp_buffer resb 50
    reverse_num1 resb 50
    reverse_num2 resb 50
    reverse_res resb 50
    len_num1 resb 1
    len_num2 resb 1
    len_res resb 1
    sign_flag resb 1

section .code
_start:
    puts inMSG1
    fgets number1, 50
    puts inMSG2
    fgets number2, 50
reverse_strings:                    ;we temporarily reverse the strings so the subtraction is easier to handle
    push len_num1
    push number1
    push reverse_num1
    call strrev
    push len_num2
    push number2
    push reverse_num2
    call strrev
compare_numbers:                    ;compare the numbers and set/clear sign_flag
    push sign_flag
    push temp_buffer
    push len_num2
    push reverse_num2
    push len_num1
    push reverse_num1
    call compare
initialize:
    xor esi, esi                    ;index
    mov bl, [len_num1]
    mov bh, [len_num2]
    cmp bl, bh
    jl set_bigger_length
    jmp clear_carry
set_bigger_length:
    mov bl, bh                      ;BL will hold the bigger length of the two numbers to determine when exactly subtraction will be finished
clear_carry:
    clc                             ;carry flag should be cleared initially because we're using sbb (subtract with borrow)
sub_loop:
    pushf                           ;the following instructions change the carry flag, so we push flags to save it
    cmp bl, 0
    je reached_end
set_and_check_first:
    mov al, [reverse_num1+esi]      ;AL holds first digit
    xor cx, cx
    mov cl, [len_num1]
    cmp si, cx
    jge set_first_zero              ;if index is greater than length, then we set the digit to 0
    jmp set_and_check_second
set_first_zero:
    mov al, '0'
set_and_check_second:
    mov bh, [reverse_num2+esi]      ;BH holds second digit
    xor cx, cx
    mov cl, [len_num2]
    cmp si, cx
    jge set_second_zero
    jmp subtract
set_second_zero:
    mov bh, '0'
subtract:
    popf
    sbb al, bh                      ;subtract with borrow
    aas                             ;ascii adjust after subtraction
    pushf                           ;save the flags register because of the OR instruction
    or al, 30H                      ;convert to ascii
    popf
    mov [reverse_res+esi], al
    inc esi
    dec bl
    jmp sub_loop
reached_end:
    mov [reverse_res+esi], byte 0   ;terminating character
reverse_result:
    push len_res
    push reverse_res
    push result
    call strrev                     ;reverse reverse_res into result
check_sign:
    mov al, [sign_flag]
    cmp al, 1
    je print_sign                   ;print negative sign if sign_flag is set
    jmp print_result
print_sign:
    puts negative_sign
print_result:
    puts result
    puts nwln
finish_prog:
    push 0
    call ExitProcess


;proc compare -> compares the two numbers receives via stack
;places the bigger one in reverse_num1, and the smaller one in reverse_num2
;if initially number1 < number2, sign_flag will be set

%define sign DWORD [ebp+28]
%define temp DWORD [ebp+24]
%define num1 DWORD [ebp+8]
%define num2 DWORD [ebp+16]
%define len1 DWORD [ebp+12]
%define len2 DWORD [ebp+20]

compare:
    enter 0, 0
    pusha
clear_sign:
    mov ebx, sign
    xor al, al
    mov [ebx], al                   ;initialize sign_flag to 0, meaning the result is positive by default
compare_lengths:
    mov ebx, len1
    mov al, [ebx]
    mov ebx, len2
    mov ah, [ebx]
    cmp al, ah
    jl set_sign                     ;if len(num1) < len(num2), num1 < num2
    jg finish_cmp                   ;if len(num1) > len(num2), num1 < num2
equal_lengths:
    mov ebx, len1
    xor ecx, ecx
    mov cl, [ebx]
    dec cl                          ;index = length-1
compare_loop:
    mov ebx, num1
    mov al, [ebx+ecx]
    mov ebx, num2
    mov ah, [ebx+ecx]
    cmp al, ah                      ;compare digits
    jl set_sign                     ;if digit of number1 is smaller, then number1 is smaller
    jg finish_cmp                   ;if digit of number1 is bigger, then number1 is bigger
    dec cl
    cmp cl, 0
    jnl compare_loop                ;else, the numbers have been equal so far
    jmp finish_cmp                  ;numbers are equal
set_sign:
    mov ebx, sign
    mov al, 1
    mov [ebx], al
swap_numbers:
    push num2
    push temp
    call strcpy                     ;temp = num2
    push num1
    push num2
    call strcpy                     ;num2 = num1
    push temp
    push num1
    call strcpy                     ;num1 = temp
swap_lengths:
    mov ebx, len2
    mov al, [ebx]
    mov ebx, len1
    mov ah, [ebx]
    mov [ebx], al
    mov ebx, len2
    mov [ebx], ah
finish_cmp:
    popa
    leave
    ret 24


;proc strcpy -> copies src to dest

%define src DWORD [ebp+12]
%define dest DWORD [ebp+8]

strcpy:
    enter 0, 0
    pusha
    mov eax, dest
    mov ebx, src
    xor esi, esi
copy_loop:
    mov dl, [ebx+esi]
    cmp dl, 0
    je termiante_string
    mov [eax+esi], dl
    inc esi
    jmp copy_loop
termiante_string:
    mov [eax+esi], BYTE 0
finish_copy:
    popa
    leave
    ret 8


;proc strrev -> places the reverse of src into dest

%define length DWORD [ebp+16]
%define src DWORD [ebp+12]
%define dest DWORD [ebp+8]

strrev:
    enter 0, 0
    pusha
    xor ecx, ecx
    mov ebx, src
find_length:
    mov al, [ebx+ecx]
    cmp al, 0
    je set_length
    inc ecx
    jmp find_length
set_length:
    mov ebx, length
    mov [ebx], cl
    mov ebx, src
start_reverse:
    dec ecx
    mov edx, dest
    xor esi, esi
reverse_loop:
    mov al, [ebx+ecx]
    mov [edx+esi], al
    inc esi
    dec ecx
    cmp ecx, 0
    jge reverse_loop
finish_reverse:
    mov [edx+esi], byte 0
    popa
    leave
    ret 8