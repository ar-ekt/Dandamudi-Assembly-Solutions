extern read,itoa,atoi,write

%macro fgets 2 
push %2;length
push %1;buffer
call read
%endmacro

%macro i2a 2 
push %1
push %2
call itoa
%endmacro

%macro a2i 2 ;stores res in eax
push %1
push %2
call atoi
%endmacro

%macro puts 1
pushad
xor ecx,ecx
mov esi,%1
%%_get_length:
    inc ecx
    lodsb
    cmp al,0
jne  %%_get_length
dec ecx
push ecx;length
push %1;buffer
call write
popad
%endmacro