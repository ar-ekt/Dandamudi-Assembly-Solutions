global _start
extern ExitProcess
%include "lib.h"

section .data
    MAX_NUMBER_LENGTH EQU 100
    NULL EQU 0
    
    nwln db 10, NULL
    inMSG1 db "enter the first number: ", NULL
    inMSG2 db "enter the second number: ", NULL
    outMSG db "The sum is: ", NULL

section .bss
    number1 resb MAX_NUMBER_LENGTH
    number2 resb MAX_NUMBER_LENGTH
    buffer resb MAX_NUMBER_LENGTH
    result resb MAX_NUMBER_LENGTH

section .code
_start:
    puts inMSG1
    fgets number1, MAX_NUMBER_LENGTH
    puts inMSG2
    fgets number2, MAX_NUMBER_LENGTH
    push number2
    push number1
    call fix_length
    ; ESI is used as index into number1, number2, and sum
    mov EBX, EAX
    mov ECX, EAX               ; iteration count ( of digits)
    mov ESI, EAX               ; ESI points to rightmost digit
    dec ESI
    clc                        ; clear carry (we use ADC not ADD)
add_loop:
    mov AL, [number1+ESI]
    adc AL, [number2+ESI]
    aaa                        ; ASCII adjust
    pushf                      ; save flags because OR
    or AL, 30H                 ; changes CF that we need
    popf                       ; in the next iteration
    mov [result+ESI], AL       ; store the sum byte
    dec ESI                    ; update ESI
    loop add_loop
    jnc _end
add_carry:                     ; if the value of the CF is one, 1 will be added to the left of the sum
    mov ECX, EBX
    mov ESI, EBX
shift_right_loop:              ; shifts the sum characters to the right once
    mov AL, [result+ESI-1]
    mov [result+ESI], AL
    dec ESI
    loop shift_right_loop
    mov [result], BYTE "1"     ; add 1 to start of sum
_end:
    puts outMSG                ; display sum
    puts result
    puts nwln
    push 0
    call ExitProcess

; proc fix_length -> increase the length of the smaller number to the length
;                    of the larger number by adding zero to its left and
;                    return length of the bigger number in EAX
fix_length:
    %define number1 DWORD [EBP+8]
    %define number2 DWORD [EBP+12]
    enter 0, 0
    push ECX
    push EBX
    push number1
    call strlen
    mov ECX, EAX              ; length of number1 in ECX
    push number2
    call strlen
    mov EBX, EAX              ; length of number2 in EBX
    cmp ECX, EBX
    jl number2_bigger         ; number1 < number2
    jg number1_bigger         ; number1 > number2
    jmp fix_length_done       ; otherwise the lengths are equal and the job is done
number2_bigger:
    push EBX
    push ECX
    push number1
    call addZero
    mov EAX, EBX              ; move the larger length to EAX
    jmp fix_length_done
number1_bigger:
    push ECX
    push EBX
    push number2
    call addZero
    mov EAX, ECX              ; move the larger length to EAX
fix_length_done:
    pop EBX
    pop ECX
    leave
    ret 8

; proc addZero -> add zero to the left of number until its length reaches len2
addZero:
    %define number DWORD [EBP+8]
    %define len1 DWORD [EBP+12]
    %define len2 DWORD [EBP+16]
    enter 0, 0
    pushad
    mov ESI, buffer            ; copy buffer pointer to ESI
    mov ECX, len2              ; number of zeros = len2 - len1
    sub ECX, len1
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

; proc strlen -> return string length in EAX
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
