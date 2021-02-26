global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro geti 0
    fgets buffer, 15
    a2i 15, buffer
%endmacro

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_NAME_SIZE EQU 20
    MAX_STUDENT EQU 20
    MAX_MARK EQU 25
    NUMBER_TEST EQU 4
    NULL EQU 0

    NEWLINE db 10, NULL
    TAB db 9, NULL
    
    MSG_N_STUDENTS_INPUT db "Enter number of students: ", NULL
    
    MSG_STUDENT_INPUT db 10, "-Student ", NULL
    MSG_NAME_INPUT db "Name: ", NULL
    MSG_MARK_INPUT1 db "Test ", NULL
    MSG_MARK_INPUT2 db ": ", NULL
    
    MSG_GRADES_OUTPUT db 10, "--Grades--", 10, NULL
    
    GRADE_A db "A", NULL
    GRADE_B db "B", NULL
    GRADE_C db "C", NULL
    GRADE_D db "D", NULL
    GRADE_F db "F", NULL
    
section .bss
    buffer resb 100
    marks resd (MAX_STUDENT*4)+1
    names resd (MAX_STUDENT*MAX_NAME_SIZE)+1

section .code
_start:
    push DWORD 0
    push marks
    push names
    call studentsInput
    pop EBX
    
    push EBX
    push marks
    push names
    call showLetterGrade
    
_end:
    push DWORD 0
    call ExitProcess

;--------------------proc studentsInput-------------------;
; receives two pointer to names array and marks array.    ;
; Inputs names and scores from user and fills the arrays. ;
;---------------------------------------------------------;
studentsInput:
    %define names DWORD [EBP+8]
    %define marks DWORD [EBP+12]
    %define nStudents DWORD [EBP+16]
    enter 0, 0
    pushad
nStudentsInput:                      ; input number of students
    puts MSG_N_STUDENTS_INPUT
    geti
    cmp EAX, MAX_STUDENT             ; not be greater than maximum number of students
    jg nStudentsInput
    cmp EAX, 1                       ; be greater than zero
    jl nStudentsInput
    mov nStudents, EAX
nStudentsInput_done:
    mov ESI, marks                   ; copy marks array pointer to ESI
    mov EDI, names                   ; copy names array pointer to EDI
    mov ECX, 0                       ; student number counter
studentInput:
    inc ECX
    cmp ECX, nStudents
    jg studentsInput_done
    puts MSG_STUDENT_INPUT
    puti ECX                         ; output student number
    puts NEWLINE
studentNameInput:
    puts MSG_NAME_INPUT
    fgets buffer, MAX_NAME_SIZE      ; input student name
    mov EBX, buffer                  ; copy name pointer to EBX
    dec EBX
movNameLoop:                         ; add name to names pointer
    inc EBX
    cmp [EBX], BYTE NULL             ; reached end of the name
    je movNameLoop_done
    mov EAX, [EBX]
    mov [EDI], EAX
    inc EDI
    jmp movNameLoop
movNameLoop_done:
    mov [EDI], BYTE NULL             ; add null to the end of names pointer
    inc EDI
    mov EDX, 0                       ; test mark counter
studentMarksInputLoop:               ; input student test marks
    inc EDX
    cmp EDX, NUMBER_TEST
    jg studentInput
studentMarkInput:                    ; input test mark
    puts MSG_MARK_INPUT1
    puti EDX
    puts MSG_MARK_INPUT2
    geti
    cmp EAX, MAX_MARK
    jg studentMarkInput              ; test mark should be between 0 to 25
    cmp EAX, 0
    jl studentMarkInput
    mov [ESI], EAX                   ; move test mark to marks pointer
    add ESI, 4
    jmp studentMarksInputLoop
studentsInput_done:
    popad
    leave
    ret 12-4
;-----------------proc showLetterGrade------------------;
; Converts percentage marks to a letter grade and shows ;
; the letter with name                                  ;
;-------------------------------------------------------;
showLetterGrade:
    %define names DWORD [EBP+8]
    %define marks DWORD [EBP+12]
    %define nStudents DWORD [EBP+16]
    enter 0, 0
    pushad
    puts MSG_GRADES_OUTPUT
    mov ESI, marks                   ; copy marks array pointer to ESI
    mov EDI, names                   ; copy names array pointer to EDI
    mov ECX, 0-1                     ; student number counter
showLetterGradeLoop:
    inc ECX
    cmp ECX, nStudents
    jge showLetterGrade_done
    xor EBX, EBX                     ; sum of student test marks
    mov EDX, 0-1                     ; test mark counter
gradeSumLoop:                        ; calculate sum of student test marks
    inc EDX
    cmp EDX, NUMBER_TEST
    jge gradeSumLoop_done
    add EBX, [ESI]
    add ESI, 4
    jmp gradeSumLoop
gradeSumLoop_done:
    puts names                       ; output name
    puts TAB
    ; show grade in letter
    cmp EBX, 50
    jl showGrade_F                   ; 0 <= grade <= 49
    cmp EBX, 60
    jl showGrade_D                   ; 50 <= grade <= 59
    cmp EBX, 70
    jl showGrade_C                   ; 60 <= grade <= 69
    cmp EBX, 85
    jl showGrade_B                   ; 70 <= grade <= 84
    jmp showGrade_A                  ; 85 <= grade <= 100
showGrade_A:
    puts GRADE_A
    jmp movNameForward
showGrade_B:
    puts GRADE_B
    jmp movNameForward
showGrade_C:
    puts GRADE_C
    jmp movNameForward
showGrade_D:
    puts GRADE_D
    jmp movNameForward
showGrade_F:
    puts GRADE_F
    jmp movNameForward
movNameForward:                     ; point to next name
    inc EDI
    cmp [EDI], BYTE NULL
    jne movNameForward
    inc EDI
    mov names, EDI
    puts NEWLINE
    jmp showLetterGradeLoop
showLetterGrade_done:
    popad
    leave
    ret 12
