import re
import itertools

GOLDEN_PATH = "_golden.txt"

with open(GOLDEN_PATH, "r", encoding="utf-8") as f_spk:
    for line in f_spk:
        regex = r".*mem 0x2000000c 0x([0-9abcdef]+)"
        result = re.match(regex, line)
        if result:
            char = bytes.fromhex(result.group(1)[-2:]).decode("utf-8")
            print(char, end="")