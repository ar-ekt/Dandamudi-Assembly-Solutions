#!/bin/bash
PATH=$PATH:.
# To compile a NASM assemnly program
		z="$1"
		k=${z%.asm}
		nasm -f elf32  -g -F dwarf "${k}.asm" -o "${k}.o"

		if [ -f "${k}.o" ] 
        then 
			# To Link a NASM assemnly program
		    ld -m elf_i386 "${k}.o" "lib.o" -o "${k}" 
		else
			exit 1
		fi


# command to execute a NASM assemnly program
./"${k}"

# command to delete assembler and linker created file
#rm -i "$k".o
#rm -i "${k}"
