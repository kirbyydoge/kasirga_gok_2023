#!/bin/bash

tail -n +6 golden.txt > _golden.txt
cp vivado.txt _vivado.txt
python3 compare.py > diff.txt
rm _golden.txt
rm _vivado.txt