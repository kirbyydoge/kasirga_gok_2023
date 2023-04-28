riscv64-unknown-elf-gcc -march=rv32imc -mabi=ilp32 -fno-common -fno-builtin-printf -c kasirga.c
riscv64-unknown-elf-gcc -march=rv32imc -mabi=ilp32 -static kasirga.o -o kasirga.riscv