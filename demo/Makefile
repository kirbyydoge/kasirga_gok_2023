RISCVTYPE = riscv64-unknown-elf
CC = $(RISCVTYPE)-gcc

LINKER_SCRIPT ?= link.ld
OUTPUTS = ./hex

ifndef PROG
$(error PROG is not set)
endif
 
CFLAGS ?= -O2 -static -std=gnu99 -fno-common -fno-builtin-printf -nostdlib -nostartfiles -lm -lgcc -T $(LINKER_SCRIPT) -march=rv32imc -mabi=ilp32 -mcmodel=medany -DPREALLOCATE=1

demo_patterns=$(shell find *.c -maxdepth 0 -type f)
demo-targets=$(demo_patterns:%=%)

compile:
	$(CC) $(CFLAGS) $(PROG)/*.c crt.S -o $(PROG).riscv
	elf2hex 4 4096 $(PROG).riscv 1073741824 > $(OUTPUTS)/$(PROG).hex
	rm *.riscv
	
.PHONY: clean
clean:
	rm -f $(OUTFILE) $(OBJS) $(OPATH)*.log *.info $(OPATH)index.html $(PORT_CLEAN) *.o *.s *.riscv *.bin *.hex *.vh *.coe *.txt *.hex
