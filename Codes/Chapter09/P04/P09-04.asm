%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db 'Hex number in capital: ', 0
    sign_msg db 'sign = ', 0
    mant_msg db 'mantissa = 1.', 0
    expo_msg db 'exponent = ', 0
    endl db 10, 0

section .bss
    binary resd 71
    buffer resd 71

section .code
_start:
    puts prompt_msg
    fgets buffer, 71
    puts endl
    push buffer
    push binary
    call hex_to_binary
    push buffer
    push binary
    call display_sign
    push buffer
    push binary
    call display_mantissa
    push buffer
    push binary
    call display_exponent
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE BUFFER DWORD [EBP + 12]
%DEFINE BINARY DWORD [EBP + 8]

hex_to_binary:
    enter 0, 0
    push eax
    push ebx
    push ecx
    push edx
    xor eax, eax
    mov ebx, BUFFER
    mov edx, BINARY
hex_to_decimal:
    mov al, [ebx]
    cmp al, 0
    je hex_to_binary_done
    cmp al, '9'
    jle hex_to_decimal_continue
    add al, 10 - 'A'
hex_to_decimal_continue:
    shl al, 4
    mov ecx, 4
decimal_to_binary:
    shl al, 1
    jnc set_zero
    mov [edx], byte 1
    jmp skip_set_zero
set_zero:
    mov [edx], byte 0
skip_set_zero:
    inc edx
    loop decimal_to_binary
    inc ebx
    jmp hex_to_decimal
hex_to_binary_done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret 8


display_sign:
    enter 0, 0
    push eax
    push ebx
    puts sign_msg
    mov ebx, BINARY
    movzx eax, byte [ebx]
    i2a eax, BUFFER
    puts BUFFER
    puts endl
    pop ebx
    pop eax
    leave
    ret 8


display_mantissa:
    enter 0, 0
    push eax
    push ebx
    push ecx
    puts mant_msg
    mov ebx, BINARY
    mov ecx, 64
find_last_non_zero:
    dec ecx
    cmp ecx, 12
    je find_last_non_zero_done
    cmp [ebx + ecx], byte 0
    jne find_last_non_zero_done
    jmp find_last_non_zero
find_last_non_zero_done:
    add ebx, 11
    sub ecx, 11
display_mantissa_loop:
    inc ebx
    movzx eax, byte [ebx]
    i2a eax, BUFFER
    puts BUFFER
    loop display_mantissa_loop
    puts endl
    pop ecx
    pop ebx
    pop eax
    leave
    ret 8


display_exponent:
    enter 0, 0
    push eax
    push ebx
    push ecx
    push edx
    puts expo_msg
    mov ebx, BINARY
    inc ebx
    xor dx, dx
    mov ecx, 10
get_exponent:
    movzx eax, byte [ebx]
    shl ax, cl
    add dx, ax
    inc ebx
    loop get_exponent
    movzx eax, byte [ebx]
    add dx, ax
    sub dx, 1023
    mov ax, 0400h
    mov ebx, BUFFER
convert_exponent_to_binary:
    test ax, dx
    jnz set_one
    mov [ebx], byte '0'
    jmp skip_set_one
set_one:
    mov [ebx], byte '1'
skip_set_one:
    inc ebx
    shr ax, 1
    jnz convert_exponent_to_binary
    mov [ebx], byte 0
    mov ebx, BUFFER
    dec ebx
remove_leading_zeroes:
    inc ebx
    cmp [ebx], byte '0'
    je remove_leading_zeroes
    cmp [ebx], byte 0
    je zero_exponent
    jmp display_exponent_done
zero_exponent:
    dec ebx
display_exponent_done:
    puts ebx
    puts endl
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret 8