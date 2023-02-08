RISCVTYPE = riscv64-unknown-elf
CC = $(RISCVTYPE)-gcc

LINKER_SCRIPT ?= link.ld
 
CFLAGS ?= -O1 -static -std=gnu99 -ffast-math -fno-common -fno-builtin-printf -fno-tree-loop-distribute-patterns -nostdlib -nostartfiles -lm -lgcc -T $(LINKER_SCRIPT) -march=rv32imc -mabi=ilp32 -mcmodel=medany -DPREALLOCATE=1

demo_patterns=$(shell find *.c -maxdepth 0 -type f)
demo-targets=$(demo_patterns:%=%)

$(demo-targets): 
	$(CC) $(CFLAGS) $*.c crt.S -o $*.riscv
	$(CC) -S $(CFLAGS) $*.c crt.S
	$(CC) -c $(CFLAGS) $*.c crt.S
	$(RISCVTYPE)-objdump -D $*.riscv > $*_assembly.txt
	$(RISCVTYPE)-objcopy -O binary $*.riscv $*.bin
	elf2hex 1 4096 $*.riscv 1073741824 > $*.hex
	rm $*.bin $*.o $*.riscv $*.s crt.o
	
.PHONY: clean
clean:
	rm -f $(OUTFILE) $(OBJS) $(OPATH)*.log *.info $(OPATH)index.html $(PORT_CLEAN) *.o *.s *.riscv *.bin *.hex *.vh *.coe *.txt *.hex
