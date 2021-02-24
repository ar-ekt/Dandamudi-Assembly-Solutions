and al, 0Fh ; mask off the upper four bits to get the unpacked BCD representation of least significant digit
shl ah, 4   ; shift most significant digit to left by 4 bits to have its unpacked BCD representation in four upper bits
and al, ah  ; now combine unpacked BCD representations to get packed BCD representation and store it in AL