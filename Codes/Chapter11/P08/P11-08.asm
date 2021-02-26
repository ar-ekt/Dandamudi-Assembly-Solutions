%INCLUDE "lib.h"
global _start

section .data
    prompt_msg db "Please input multiplicand: ", 0
    prompt_msg1 db "Please input multiplier (one digit only): ", 0
    star db " * ", 0
    equal db " = ", 0
    endl db 10, 0

section .bss
    multiplier resb 3
    multiplicand resb 41
    result resb 61

section .code
_start:
    puts prompt_msg
    fgets multiplicand, 41
    puts prompt_msg1
    fgets multiplier, 3
    push multiplicand
    call reverse            ; reverse multiplicand
initialization:
    mov edi, multiplicand   ; EDI holds pointer to reversed multiplicand
    mov esi, result         ; ESI holds pointer to reversed result
    mov dl, [multiplier]    ; DL holds multiplier
    and dl, 0Fh             ; mask off four upper bits to get multiplier in unpacked BCD form
    xor dh, dh              ; DH holds carry (initially set to zero)
loop_on_multiplicand:
    mov al, [edi]           ; load AL with multiplicand in ASCII form
    cmp al, 0               ; is it NULL?! goto loop_on_multiplicand_end if it is
    je loop_on_multiplicand_end
    and al, 0Fh             ; mask off four upper bits to get multiplicand in unpacked BCD form
    mul dl                  ; AL * DL = AX
    aam                     ; aam works as follows: AL is divided by 10 and the quotient is stored in AH and the remainder in AL
    add al, dh              ; AL = remainder + old carry
    mov dh, ah              ; set DH to new carry (quotient)
    aam                     ; in case AL is greater than 10, one again we do division by 10 using aam
    add dh, ah              ; update carry (doesn't change if AL was less than 10)
    or al, 30h              ; replace four upper bits with 0011 to get result in ASCII form
    mov [esi], al           ; save result in result string
    inc edi                 ; update EDI
    inc esi                 ; update ESI
    jmp loop_on_multiplicand
loop_on_multiplicand_end:
    cmp dh, 0               ; is the last carry zero?!
    je no_carry             ; goto no_carry if it is
carry:
    or dh, 30h              ; replace four upper bits with 0011 to get carry in ASCII form
    mov [esi], dh           ; save last carry in result string
    inc esi                 ; update ESI
no_carry:
    mov [esi], byte 0       ; declare end of the result string
    push multiplicand
    call reverse            ; reverse reversed multiplicand
    push result
    call reverse            ; reverse reversed result
display_result:
    puts endl
    puts multiplicand
    puts star
    puts multiplier
    puts equal
    puts result
    puts endl
end:
    mov eax, 1
    mov ebx, 0
    int 0x80

%DEFINE STRING [EBP + 8]

;-----------------------proc reverse-------------------------;
; reverse procedure receives a pointer to a character string ;
; (terminated by a NULL character) and reverses the string.  ;
;------------------------------------------------------------;

reverse:
    enter 0, 0
    push eax
    push ebx
    mov ebx, STRING
push_characters:
    cmp [ebx], byte 0       ; check if we reached end of string
    je push_done
    xor ax, ax
    mov al, [ebx]           ; load AL with current character
    push ax                 ; push character onto stack to be recived later
    inc ebx                 ; increase pointer to point to next character
    jmp push_characters
push_done:
    mov ebx, STRING
pop_characters:
    cmp [ebx], byte 0       ; check if we reached end of string
    je reverse_done
    pop ax                  ; recive characters in backward order
    mov [ebx], al           ; and place them in original string in forward order
                            ; its logic: string[0] <- string[last_index + 0], string[1] <- string[last_index - 1] and so on ... 
    inc ebx                 ; increase pointer to point to next character
    jmp pop_characters
reverse_done:
    pop ebx
    pop eax
    leave
    ret 4