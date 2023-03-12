import re
import itertools

VIVADO_PATH = "_vivado.txt"
GOLDEN_PATH = "_golden.txt"

def parse_line(line):
    line = line.split(" ")
    ret_bundle = {
        "pc": line[5],
        "reg": "<none>",
        "reg_val": "<none>"
    }
    line = line[5:]
    if len(line) == 2 or line[2] == "mem":
        return ret_bundle
    if line[2] == "x":
        if line[3] != "0":
            ret_bundle["reg"] = line[3]
            ret_bundle["reg_val"] = line[4]
        return ret_bundle
    if line[2][0] == "x":
        ret_bundle["reg"] = line[2][1:]
        ret_bundle["reg_val"] = line[3]
        return ret_bundle
    return ret_bundle

def compare_line(line0, line1, index):
    viv_groups = parse_line(line0)
    spk_groups = parse_line(line1)
    success = True
    for group in viv_groups:
        if viv_groups[group] != spk_groups[group]:
            if success:
                print(f"DIFF {index}:", end=" ")
            print(f"<{group}> vivado {viv_groups[group]} spike {spk_groups[group]}", end=" | ")
            success = False
    if not success:
        print("")

with open(VIVADO_PATH, "r", encoding="utf-8") as f_viv, open(GOLDEN_PATH, "r", encoding="utf-8") as f_spk:
    index = 1
    for line0, line1 in itertools.zip_longest(f_viv, f_spk):
        if not line0 or not line1:
            print("EOF")
            break
        compare_line(line0.strip(), line1.strip(), index)
        index += 1