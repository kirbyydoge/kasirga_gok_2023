riscv64-unknown-elf-gcc -march=rv32imc -fno-common -fno-builtin-printf -specs=htif_nano.specs -c kasirga.c
riscv64-unknown-elf-gcc -static -specs=htif_nano.specs kasirga.o -o kasirga.riscv
