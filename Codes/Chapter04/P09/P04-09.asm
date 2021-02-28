global _start
extern ExitProcess
%INCLUDE "lib.h"
    
section .data
    MAX_ADDRESS_SIZE EQU 100
    NULL EQU 0
    NEWLINE db 10, NULL
    
    MSG_LOGICALADDRESS_INPUT db "Enter the hexadecimal logical address in segment:offset format(e.g. 1000:3A4): ", NULL
    MSG_PHYSICALADDRESS_OUTPUT db "Equivalent physical address: ", NULL
    
section .bss
    logicalAddress resb MAX_ADDRESS_SIZE
    physicalAddress resb MAX_ADDRESS_SIZE

section .code
_start:
    puts MSG_LOGICALADDRESS_INPUT
    fgets logicalAddress, MAX_ADDRESS_SIZE
    mov ESI, logicalAddress                  ; copy logical-address pointer to ESI
    
    xor EBX, EBX                             ; segment-value as decimal
segmentToDecLoop:                            ; convert segment-value from hexadecimal to decimal
    mov AL, [ESI]                            ; 
    cmp AL, BYTE ":"                         ; end of segment part
    je offsetToDec
    cmp AL, BYTE "9"
    jg segmentToDecLoop_isLetter
segmentToDecLoop_isDigit:                    ; 0 <= digit <= 9
    sub AL, BYTE "0"                         ; convert digit to equal value in decimal
    jmp segmentToDecLoop_continue
segmentToDecLoop_isLetter:                   ; A <= digit <= F
    sub AL, BYTE "A"-10                      ; convert digit to equal value in decimal
segmentToDecLoop_continue:
    shl EBX, 4
    add BL, AL
    inc ESI
    jmp segmentToDecLoop
    
offsetToDec:                                 ; convert offset-value from hexadecimal to decimal
    inc ESI                                  ; point to start of offset part
    xor ECX, ECX                             ; offset-value as decimal
offsetToDecLoop:
    mov AL, [ESI]
    cmp AL, BYTE NULL                        ; end of offset part
    je physicalAddressCalc
    cmp AL, BYTE "9"
    jg offsetToDecLoop_isLetter
offsetToDecLoop_isDigit:                     ; 0 <= digit <= 9
    sub AL, BYTE "0"                         ; convert digit to equal value in decimal
    jmp offsetToDecLoop_continue
offsetToDecLoop_isLetter:                    ; A <= digit <= F
    sub AL, BYTE "A"-10                      ; convert digit to equal value in decimal
offsetToDecLoop_continue:
    shl ECX, 4
    add CL, AL
    inc ESI
    jmp offsetToDecLoop

physicalAddressCalc:
    shl EBX, 4                               ; physical-address = segment-value * 16 + offset-value
    add EBX, ECX
    xor ECX, ECX                             ; physical-address length as hexadecimal
    mov ESI, physicalAddress                 ; copy physical-address pointer to ESI
physicalAddressToHex:                        ; convert physical-address from decimal to hexadecimal
    cmp EBX, 0
    je physicalAddressToHexCalcDone
    mov DL, BL
    and DL, 0FH                              ; mod 16
    shr EBX, 4                               ; div 16
    cmp DL, 9
    jg physicalAddressToHex_toLetter
physicalAddressToHex_toDigit:
    add DL, "0"                              ; convert to equal value in hexadecimal
    jmp physicalAddressToHex_continue
physicalAddressToHex_toLetter:
    add DL, "A"-10                           ; convert to equal value in hexadecimal
physicalAddressToHex_continue:
    xor DH, DH
    push DX
    inc ECX
    jmp physicalAddressToHex
physicalAddressToHexCalcDone:
    cmp ECX, 0
    je physicalAddress_zero
physicalAddressMovLoop:                      ; place characters in reverse order
    pop DX
    mov [ESI], DX
    inc ESI
    loop physicalAddressMovLoop
    jmp physicalAddressToHex_done
physicalAddress_zero:
    mov [ESI], BYTE "0"                      ; set physical-address to zero
    inc ESI
physicalAddressToHex_done:
    mov [ESI], BYTE NULL                     ; terminate the physical-address string
    puts MSG_PHYSICALADDRESS_OUTPUT
    puts physicalAddress
    puts NEWLINE
    
_end:
    push DWORD 0
    call ExitProcess
