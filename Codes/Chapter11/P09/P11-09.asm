globAL _start
extern ExitProcess
%include "lib.h"

section .data
    MAX_NUMBER_LENGTH EQU 100
    NULL EQU 0
    
    NEWLINE db 10, NULL
    MSG_INPUT1 db "Please input multiplicand: ", NULL
    MSG_INPUT2 db "Please input multiplier: ", NULL
    MSG_OUTPUT db "Result: ", NULL

section .bss
    multiplier resb MAX_NUMBER_LENGTH
    multiplicand resb MAX_NUMBER_LENGTH
    result resb MAX_NUMBER_LENGTH
    temp_result resb MAX_NUMBER_LENGTH
    buffer resb MAX_NUMBER_LENGTH

section .code
_start:
    puts MSG_INPUT1
    fgets multiplicand, MAX_NUMBER_LENGTH
    puts MSG_INPUT2
    fgets multiplier, MAX_NUMBER_LENGTH
    mov [result], BYTE NULL
    mov ESI, multiplier                   ; ESI holds pointer to multiplier
    dec ESI
multiplication_loop:
    inc ESI                               ; update ESI
    cmp [ESI], BYTE NULL                  ; end of multiplier
    je display_result
    push ESI
    push multiplicand
    push temp_result
    cALl num_mul                          ; temp_result = multiplicand * multiplier[i]
    push result
    cALl strlen
    mov [result+EAX], BYTE "0"            ; result *= 10
    mov [result+EAX+1], BYTE NULL
    push temp_result
    push result
    cALl num_add                          ; result += temp_result
    jmp multiplication_loop
display_result:
    puts MSG_OUTPUT
    puts result
    puts NEWLINE
_end:
    push 0
    cALl ExitProcess

; proc num_mul -> multiply a number by a digit and save it in result
num_mul:
    %define result DWORD [EBP+8]
    %define multiplicand DWORD [EBP+12]
    %define multiplier DWORD [EBP+16]
    enter 0, 0
    pushad
    push multiplicand
    cALl strlen
    mov EDI, multiplicand   ; EDI points to rightmost digit of multiplicand
    add EDI, EAX
    dec EDI
    mov ESI, result         ; ESI holds pointer to reversed result
    mov EAX, multiplier
    mov DL, [EAX]           ; DL holds multiplier
    and DL, 0Fh             ; mask off four upper bits to get multiplier in unpacked BCD form
    xor DH, DH              ; DH holds carry (initiALly set to zero)
num_mul_loop:
    mov AL, [EDI]           ; load AL with multiplicand in ASCII form
    cmp AL, 0               ; is it NULL?! goto loop_on_multiplicand_end if it is
    je num_mul_loop_end
    and AL, 0Fh             ; mask off four upper bits to get multiplicand in unpacked BCD form
    mul DL                  ; AL * DL = AX
    aam                     ; aam works as follows: AL is divided by 10 and the quotient is stored in AH and the remainder in AL
    add AL, DH              ; AL = remainder + old carry
    mov DH, AH              ; set DH to new carry (quotient)
    aam                     ; in case AL is greater than 10, one again we do division by 10 using aam
    add DH, AH              ; update carry (doesn''t change if AL was less than 10)
    or AL, 30h              ; replace four upper bits with 0011 to get result in ASCII form
    mov [ESI], AL           ; save result in result string
    dec EDI                 ; update EDI
    inc ESI                 ; update ESI
    jmp num_mul_loop
num_mul_loop_end:
    cmp DH, 0               ; is the last carry zero?!
    je num_mul_no_carry     ; goto no_carry if it is
num_mul_carry:
    or DH, 30h              ; replace four upper bits with 0011 to get carry in ASCII form
    mov [ESI], DH           ; save last carry in result string
    inc ESI                 ; update ESI
num_mul_no_carry:
    mov [ESI], byte 0       ; declare end of the result string
    push result
    cALl reverse            ; reverse reversed result
num_mul_done:
    popad
    leave
    ret 12

;-----------------------proc reverse-------------------------;
; reverse procedure receives a pointer to a character string ;
; (terminated by a NULL character) and reverses the string.  ;
;------------------------------------------------------------;
reverse:
    %define STRING [EBP+8]
    enter 0, 0
    push EAX
    push EBX
    mov EBX, STRING
push_characters:
    cmp [EBX], byte 0       ; check if we reached end of string
    je push_done
    xor AX, AX
    mov AL, [EBX]           ; load AL with current character
    push AX                 ; push character onto stack to be recived later
    inc EBX                 ; increase pointer to point to next character
    jmp push_characters
push_done:
    mov EBX, STRING
pop_characters:
    cmp [EBX], byte 0       ; check if we reached end of string
    je reverse_done
    pop AX                  ; recive characters in backward order
    mov [EBX], AL           ; and place them in originAL string in forward order
                            ; its logic: string[0] <- string[last_index + 0], string[1] <- string[last_index - 1] and so on ... 
    inc EBX                 ; increase pointer to point to next character
    jmp pop_characters
reverse_done:
    pop EBX
    pop EAX
    leave
    ret 4

; proc num_add -> add second number to first number
num_add:
    %define number1 DWORD [EBP+8]
    %define number2 DWORD [EBP+12]
    enter 0, 0
    pushad
    push number2
    push number1
    cALl fix_length
    mov EBX, EAX
    mov ECX, EAX                ; iteration count ( of digits)
    mov ESI, number1            ; ESI points to rightmost digit of number1
    add ESI, EAX
    dec ESI
    mov EDI, number2            ; EDI points to rightmost digit of number2
    add EDI, EAX
    dec EDI
    clc                         ; clear carry (we use ADC not ADD)
num_add_loop:
    mov AL, [ESI]
    adc AL, [EDI]
    aaa                         ; ASCII adjust
    pushf                       ; save flags because OR
    or AL, 30H                  ; changes CF that we need
    popf                        ; in the next iteration
    mov [ESI], AL               ; store the sum byte
    dec ESI                     ; update ESI
    dec EDI                     ; update EDI
    loop num_add_loop
    jnc num_add_done
num_add_carry:                  ; if the vALue of the CF is one, 1 will be added to the left of the sum
    mov ECX, EBX
    mov ESI, number1            ; ESI points to end of sum
    add ESI, EBX
    inc ESI
num_add_shift:                  ; shifts characters
    mov AL, [ESI-1]
    mov [ESI], AL
    dec ESI
    loop num_add_shift
    mov [ESI], BYTE "1"         ; add 1 to start of sum
num_add_done:
    popad
    leave
    ret 8

; proc fix_length -> increase the length of the smALler number to the length
;                    of the larger number by adding zero to its left and
;                    return length of the bigger number in EAX
fix_length:
    %define number1 DWORD [EBP+8]
    %define number2 DWORD [EBP+12]
    enter 0, 0
    push ECX
    push EBX
    push number1
    cALl strlen
    mov ECX, EAX              ; length of number1 in ECX
    push number2
    cALl strlen
    mov EBX, EAX              ; length of number2 in EBX
    cmp ECX, EBX
    jl number2_bigger         ; number1 < number2
    jg number1_bigger         ; number1 > number2
    jmp fix_length_done       ; otherwise the lengths are equAL and the job is done
number2_bigger:
    push EBX
    push ECX
    push number1
    cALl addZero
    mov EAX, EBX              ; move the larger length to EAX
    jmp fix_length_done
number1_bigger:
    push ECX
    push EBX
    push number2
    cALl addZero
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
