%INCLUDE "lib.h"
global _start

section .data
    cf_msg db "CF=", 0
    pf_msg db "PF=", 0
    zf_msg db "ZF=", 0
    sf_msg db "SF=", 0
    zero db "0", 0
    one db "1", 0
    endl db 10, 0

section .code
_start:
    pushf       ; push FLAGS register onto stack
    pop ax      ; pop FLAGS register into AX register
                ; above instructions do something like <mov ax, flags>
CF_status:
    puts cf_msg
    btc ax, 0   ; test carry flag bit and Complements it (btc copies bit's value into CF before complementing)
    jc CF_one
CF_zero:
    puts zero
    puts endl
    jmp PF_status
CF_one:
    puts one
    puts endl
PF_status:
    puts pf_msg
    btc ax, 2   ; test parity flag bit and Complement it
    jc PF_one
PF_zero:
    puts zero
    puts endl
    jmp ZF_status
PF_one:
    puts one
    puts endl
ZF_status:
    puts zf_msg
    btc ax, 6   ; test zero flag bit and Complement it
    jc ZF_one
ZF_zero:
    puts zero
    puts endl
    jmp SF_status
ZF_one:
    puts one
    puts endl
SF_status:
    puts sf_msg
    btc ax, 7   ; test sign flag bit and Complement it
    jc SF_one
SF_zero:
    puts zero
    puts endl
    jmp end
SF_one:
    puts one
    puts endl
end:
    push ax     ; push AX register onto stack
    popf        ; pop AX register into FLAGS register
                ; above instructions do something like <mov flags, ax>
    mov eax, 1
    mov ebx, 0
    int 0x80