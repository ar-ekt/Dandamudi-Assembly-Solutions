global _start
extern ExitProcess
%INCLUDE "lib.h"

%macro geti 0
    fgets buffer, 12
    a2i 12, buffer
%endmacro

%macro puti 1
    i2a DWORD %1, buffer
    puts buffer
%endmacro

section .data
    MAX_N_STUDENTS EQU 20
    MAX_N_TESTS EQU 5
    
    NEWLINE db 10, 0
    
    space db ' ', 0
    
    MSG_N_STUDENTS_INPUT db "Number of students(0<x<=", 0
    MSG_N_TESTS_INPUT db "Number of tests(0<x<=", 0
    MSG_CLOSE_PARENTESE db "): ", 0
    
    MSG_MARK_INPUT1 db "Student ", 0
    MSG_MARK_INPUT2 db " Test ", 0
    MSG_MARK_INPUT3 db " = ", 0
    
    MSG_SUM_OUTPUT db "The sum of the last test marks is: ", 0
    
section .bss
    buffer resb 100
    marks resd (MAX_N_TESTS*MAX_N_STUDENTS)+1

section .code
_start:
    push DWORD 0
    push DWORD 0
    push marks
    call MarksInput
    pop ECX
    pop EBX
    
    push EBX
    push ECX
    push marks
    call SumLastTest
    
_end:
    push DWORD 0
    call ExitProcess

MarksInput:
    %define marks DWORD [EBP+8]
    %define studentsN DWORD [EBP+12]
    %define testsN DWORD [EBP+16]
    enter 0, 0
    push ESI
    push EAX
    push ECX
    push EDX

StudentsNInput:
    puts MSG_N_STUDENTS_INPUT
    puti MAX_N_STUDENTS
    puts MSG_CLOSE_PARENTESE
    geti
    cmp EAX, MAX_N_STUDENTS
    jg StudentsNInput
    cmp EAX, 1
    jl StudentsNInput
    mov studentsN, EAX

TestsNInput:
    puts MSG_N_TESTS_INPUT
    puti MAX_N_TESTS
    puts MSG_CLOSE_PARENTESE
    geti
    cmp EAX, MAX_N_TESTS
    jg TestsNInput
    cmp EAX, 1
    jl TestsNInput
    mov testsN, EAX
    
    mov ESI, marks
    xor ECX, ECX

Students:
    cmp ECX, studentsN
    je MarksInput_done
    inc ECX
    mov EDX, 1

Tests:
    puts MSG_MARK_INPUT1
    puti ECX
    puts MSG_MARK_INPUT2
    puti EDX
    puts MSG_MARK_INPUT3
    
    geti
    mov [ESI], EAX
    add ESI, 4
    
    inc EDX
    cmp EDX, testsN
    jg Students
    jmp Tests
            
MarksInput_done:
    pop EDX
    pop ECX
    pop EAX
    pop ESI
    leave
    ret 12-8


SumLastTest:
    %define class_marks DWORD [EBP+8]
    %define NO_ROWS DWORD [EBP+12]
    %define NO_COLUMNS DWORD [EBP+16]
    %define NO_ROW_BYTES DWORD [EBP-4]
    enter 4, 0
    
    mov ECX, NO_ROWS
    xor EAX, EAX
    xor EBX, EBX
    
    mov ESI, NO_COLUMNS
    shl ESI, 2
    mov NO_ROW_BYTES, ESI
    sub ESI, 4
    add ESI, class_marks
    
sum_loop:
    add EAX, [ESI+EBX]
    add EBX, NO_ROW_BYTES
    loop sum_loop
    
    puts MSG_SUM_OUTPUT
    puti EAX
    puts NEWLINE

SumLastTest_done:
    leave
    ret 12-0
