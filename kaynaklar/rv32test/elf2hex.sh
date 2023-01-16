#!/bin/bash

for file in rv32imc-elf/*; do
	elf2hex 4 4096 "${file}" 1073741824 > "rv32imc-hex/${file##*/}.hex"  
done
