import os
import configparser

file_path = os.path.dirname(os.path.realpath(__file__))


if __name__ == "__main__":
    config = configparser.ConfigParser()
    config.read(os.path.join(file_path, '../cfg/insn_bits.cfg'))
    all_sections = config.sections()
    for section in all_sections:
        insn_name = section
        options = config.options(section)
        # [name, bits, type]
        insn_componets = []
        for o_idx, option in enumerate(options):
            value = config.get(section, option)
            insn_componets.append([option, int(value), o_idx+2])

        print("==== ", insn_name, "====")
        print()

        align_len = max([len(insn_part[0]) + 10 + len(str(insn_part[1])) + 1 for insn_part in insn_componets])
        start = 0
        for insn_part in insn_componets:
            name_str = "reg " + "[" + str(insn_part[1]) + ":0]" + insn_part[0]
            print(name_str.ljust(align_len), end="")
            insn_str = "insn[" + str(start + insn_part[1] - 1) + ":" + str(start) + "]"
            print(insn_str)
            start += insn_part[1]
        print()
        print()