global _start
extern ExitProcess
%INCLUDE "lib.h"

section .data
    enterLen db 'Enter Length of a box : ',0
    enterWidth db 'Enter Width of a box : ',0
    enterHeight db 'Enter Height of a box : ',0
    volumeMsg db 'Volume = ',0
    surfaceVolumeMsg db 'Surface volume = ',0
    newline db 10,0
section .bss
    len resd 3
    width resd 3
    height resd 3
    resVolume resd 3
    surfaceVolume resd 3
    res1 resd 3
    res2 resd 3
    res3 resd 3

section .code
_start:
    puts enterLen
    fgets len,12
    a2i 12,len                      ;stores length in EAX
    mov EBX,EAX                     ;move length to EBX
    puts enterWidth
    fgets width,12
    a2i 12,width                    ;stores width in EAX
    mov EDX,EAX                     ;move width to EDX
    puts enterHeight
    fgets height,12
    a2i 12,height                   ;stores height in EAX
cal_volume:
    mul EDX                         ;(height * width) and stores result in EAX
    mul EBX                         ;(EAX * length) and stores result in EAX
    i2a EAX,resVolume               ;move result to resVolume
cal_surfaceVolume:
    a2i 12,len                      ;stores length in EAX
    mov EBX,EAX                     ;move length to EBX
    a2i 12,height                   ;stores height in EAX
    mul EBX                         ;(height * length) and stores result in EAX
    i2a EAX,res1                    ;move result to res1

    a2i 12,width                    ;stores width in EAX
    mov EDX,EAX                     ;move width to EDX
    a2i 12,height                   ;stores height in EAX
    mul EDX                         ;(height * width) and stores result in EAX
    i2a EAX,res2                    ;move result to res2

    a2i 12,len                      ;stores length in EAX
    mov EBX,EAX                     ;move length to EBX
    a2i 12,width                    ;stores width in EAX
    mul EBX                         ;(length * width) and stores result in EAX
    i2a EAX,res3                    ;move result to res3

    a2i 12,res1
    mov EBX,EAX                     ;stores res1 in EBX

    a2i 12,res2
    mov EDX,EAX                     ;stores res2 in EDX

    a2i 12,res3                     ;stores res3 in EAX

    add EAX,EBX
    add EAX,EDX                     ;(res1 + res2 + res3) and stores result in EAX

    mov EBX,2                       ;put 2 in source operand , to multiply EAX by it

    mul EBX                         ;(EAX * EBX) and stores result in EAX
    i2a EAX,surfaceVolume           ;move result to surfaceVolume
print:
    puts volumeMsg
    puts resVolume
    puts newline
    puts surfaceVolumeMsg
    puts surfaceVolume
done:
    push 0
    call ExitProcess
