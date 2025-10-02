nasm -f elf64 lsInAssembly.asm -o lsInAssembly.o -g
gcc -m64 -no-pie -g lsInAssembly.o -o lsInAssembly