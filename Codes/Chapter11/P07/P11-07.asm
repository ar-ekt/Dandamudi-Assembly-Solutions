global _start
extern ExitProcess
%include "lib.h"

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_NUMBER_LENGTH EQU 100
    NULL EQU 0
    
    nwln db 10, NULL
    inMSG1 db "enter the first number: ", NULL
    inMSG2 db "enter the second number: ", NULL
    outMSG db "The subtraction is: ", NULL
    negative db "-", NULL

section .bss
    buffer resb MAX_NUMBER_LENGTH
    number1 resb MAX_NUMBER_LENGTH
    number2 resb MAX_NUMBER_LENGTH
    BCDsub resb MAX_NUMBER_LENGTH
    ASCIIsub resb MAX_NUMBER_LENGTH

section .code
_start:
    puts inMSG1
    fgets number1, MAX_NUMBER_LENGTH
    puts inMSG2
    fgets number2, MAX_NUMBER_LENGTH
    push number1
    push number2
    call num_cmp               ; compare numbers
    push number1
    push number2
    call fix_length            ; equalize the length of two numbers by adding zero to the left of the smaller number
    push EAX
    push number1
    call ASCII_to_BCD          ; convert first number to packed decimal number
    push EAX
    push number2
    call ASCII_to_BCD          ; convert second number to packed decimal number
    mov EBX, EAX               ; save length of result
    mov ECX, EAX               ; loop iteration count
    shr ECX, 1
    mov ESI, ECX               ; ESI is used as index into number1, number2 and ASCIIsub
    dec ESI
    clc                        ; clear carry (we use ADC)
    cmp EDX, 0
    je add_loop1
    jmp add_loop2
add_loop1:                     ; if first number was bigger
    mov AL,[number1+ESI]
    sub AL,[number2+ESI]
    das                        ; ASCII adjust
    mov [BCDsub+ESI],AL        ; store the sub byte
    dec ESI                    ; update index
    loop add_loop1
    jmp output_result
add_loop2:                     ; if second number was bigger
    mov AL,[number2+ESI]
    sub AL,[number1+ESI]
    das                        ; ASCII adjust
    mov [BCDsub+ESI],AL        ; store the sub byte
    dec ESI                    ; update index
    loop add_loop2
output_result:
    push EBX
    call BCD_to_ASCII
    puts outMSG                ; display sub
    cmp EDX, 1
    jne output_result_continue
    puts negative
output_result_continue:
    puts ASCIIsub
    puts nwln
_end:
    push 0
    call ExitProcess

;-----------------------------------------------------------
; Converts ASCII to packed decimal number
;-----------------------------------------------------------
ASCII_to_BCD:
    %define number DWORD [EBP+8]
    %define length DWORD [EBP+12]
    enter 0, 0
    pushad
    mov ESI, number           ; copy number pointer to ESI (ASCII mode)
    mov EDI, number           ; copy number pointer to EDI (BCD mode)
    mov ECX, length           ; loop counter
    shr ECX, 1
ASCII_to_BCD_loop:
    mov AH, [ESI]             ; first ASCII digit
    inc ESI                   ; update ESI
    mov AL, [ESI]             ; second ASCII digit
    and AL, 0Fh               ; converts digits to BCD digit
    shl AH, 4
    or AL, AH
    mov [EDI], AL             ; BCD digit
    inc ESI                   ; update ESI
    inc EDI                   ; update EDI
    loop ASCII_to_BCD_loop
    mov [EDI], BYTE NULL      ; terminate number
ASCII_to_BCD_done:
    popad
    leave
    ret 8
    
;-----------------------------------------------------------
; Converts the packed decimal number in BCDsub
; to ASCII represenation and stores it in ASCIIsub.
; All registers are preserved.
;-----------------------------------------------------------
BCD_to_ASCII:
    %define length DWORD [EBP+8]
    enter 0,0
    pushad                         ; save registers
    mov ESI,length                 ; ESI is used as index into ASCIIsub
    dec ESI
    mov ECX,length                 ; loop count ( of BCD digits)
    shr ECX,1
    mov EDI,ECX                    ; EDI is used as index into BCDsub
    dec EDI
cnv_loop:
    mov AL,[BCDsub+EDI]            ; AL = BCD digit
    mov AH,AL                      ; save the BCD digit
    ; convert right digit to ASCII & store in ASCIIsub
    and AL,0FH
    or AL,30H
    mov [ASCIIsub+ESI],AL
    dec ESI
    mov AL,AH                      ; restore the BCD digit
    ; convert left digit to ASCII & store in ASCIIsub
    shr AL,4                       ; right-shift by 4 positions
    or AL,30H
    mov [ASCIIsub+ESI],AL
    dec ESI
    dec EDI                        ; update EDI
    loop cnv_loop
    mov ESI, 0-1
remove_leading_zeros:              ; remove leading zeros
    inc ESI
    cmp [ASCIIsub+ESI], BYTE "0"   ; iterate while digit == 0
    je remove_leading_zeros
    xor EDI, EDI                   ; index into start of ASCIIsub
    cmp ESI, length
    jne shift_left
    dec ESI                        ; if there is no more digit so result is zero
shift_left:                        ; shift all digits to left
    cmp ESI, length
    je BCD_to_ASCII_done
    mov AL, [ASCIIsub+ESI]
    mov [ASCIIsub+EDI], AL
    inc ESI
    inc EDI
    jmp shift_left
BCD_to_ASCII_done:
    mov [ASCIIsub+EDI], BYTE NULL  ; terminate ASCIIsub
    popad                          ; restore registers
    leave
    ret 12

;--------------------------------------------------------------------------
; increase the length of the smaller number to the length
; of the larger number by adding zero to its left and
; return length of the bigger number in EAX
; and return 1 in EDX if both numbers start with zero otherwise set it 0
;--------------------------------------------------------------------------
fix_length:
    %define number1 DWORD [EBP+8]
    %define number2 DWORD [EBP+12]
    enter 0, 0
    push EBX
    push ECX
    push EDX
    push ESI
    push number1
    call strlen
    mov ECX, EAX               ; length of number1
    push number2
    call strlen
    mov EBX, EAX               ; length of number2
    ; EAX = max(strlen(number1), strlen(number2))
    cmp ECX, EBX
    jge fix_length_num1_bigger
    jmp fix_length_num2_bigger
fix_length_num1_bigger:
    mov EAX, ECX
    jmp fix_length_addZero
fix_length_num2_bigger:        
    mov EAX, EBX
    jmp fix_length_addZero
fix_length_addZero:
    mov DL, AL
    and DL, 1H
    add AL, DL                 ; if maximum length is odd, add one to the length
    push EAX
    push ECX
    push number1
    call addZero               ; add zero to the left of number1
    push EAX
    push EBX
    push number2
    call addZero               ; add zero to the left of number2
fix_length_done:
    pop ESI
    pop EDX
    pop ECX
    pop EBX
    leave
    ret 8

;--------------------------------------------------------------------------------
; compare numbers and return 1 if second number is bigger and 0 if first number 
;--------------------------------------------------------------------------------
num_cmp:
    %define number1 DWORD [EBP+12]
    %define number2 DWORD [EBP+8]
    enter 0, 0
    push number1
    call strlen
    mov ECX, EAX               ; length of number1
    push number2
    call strlen
    mov EBX, EAX               ; length of number2
    cmp ECX, EBX
    jg num_cmp_num1_bigger     ; len(number1) > len(number2)
    jl num_cmp_num2_bigger     ; len(number1) < len(number2)
    ; len(number1) == len(number2)
    mov ESI, number1
    mov EDI, number2
num_cmp_loop:
    mov AL, [ESI]
    mov DL, [EDI]
    cmp AL, DL
    jg num_cmp_num1_bigger     ; number1[i] > number2[i]
    jl num_cmp_num2_bigger     ; number1[i] < number2[i]
    inc ESI
    inc EDI
    loop num_cmp_loop
num_cmp_num1_bigger:           ; first number is bigger
    xor EDX, EDX
    jmp num_cmp_done
num_cmp_num2_bigger:           ; second number is bigger
    mov EDX, 1
    jmp num_cmp_done
num_cmp_done:
    leave
    ret 8

;----------------------------------------------------------------
; add zero to the left of number until its length reaches len2
;----------------------------------------------------------------
addZero:
    %define number DWORD [EBP+8]
    %define len1 DWORD [EBP+12]
    %define len2 DWORD [EBP+16]
    enter 0, 0
    pushad
    mov ESI, buffer            ; copy buffer pointer to ESI
    mov ECX, len2              ; number of zeros = len2 - len1
    sub ECX, len1
    cmp ECX, 0
    je addZero_done
addZero_zeroLoop:              ; first add zeros to the buffer
    mov [ESI], BYTE "0"
    inc ESI                    ; next position
    loop addZero_zeroLoop
    mov EDI, number            ; copy number pointer to EDI
    mov ECX, len1
addZero_movLoop:               ; contact number to the end of buffer
    mov AL, [EDI]
    mov [ESI], AL
    inc ESI
    inc EDI
    loop addZero_movLoop
    mov EDI, buffer
    mov ESI, number
    mov ECX, len2
addZero_copyLoop:              ; copy buffer to number
    mov AL, [EDI]
    mov [ESI], AL
    inc ESI
    inc EDI
    loop addZero_copyLoop
    mov [ESI], BYTE NULL       ; terminate the number string
addZero_done:
    popad
    leave
    ret 12
    
;-------------------------------
; return length of string in EAX
;-------------------------------
strlen:
    %define string DWORD [EBP+8]
    enter 0, 0
    push ESI
    mov ESI, string            ; copy string pointer to ESI
    xor EAX, EAX               ; save the length
strlen_loop:
    cmp [ESI+EAX], BYTE NULL   ; end of string
    je strlen_done
    inc EAX
    jmp strlen_loop
strlen_done:
    pop ESI
    leave
    ret 4
