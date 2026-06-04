import argparse
import re

parser = argparse.ArgumentParser(description='Generate unroll code')
parser.add_argument('--input', type=str, help='input file')
parser.add_argument('--output', type=str, help='output file')

def unroll_assign(ori_codes: str):
    unrolled_codes = []
    for line in ori_codes:
        if re.match(r"^\s*assign\s*(\w+)\s*=\s*(\d+)'h(\w+);\s*$", line):
            m = re.match(r"^\s*assign\s*(\w+)\s*=\s*(\d+)'h(\w+);\s*$", line)
            width = int(m.group(2))
            value = int(m.group(3), 16)
            for i in range(width):
                unrolled_codes.append(f"assign {m.group(1)}[{i}] = {value & 1};")
                value >>= 1
        else:
            unrolled_codes.append(line)

def main():
    args = parser.parse_args()
    # read files
    with open(args.input, 'r') as f:
        lines = f.readlines()
    
    # find generate block
    generate_block_start_line = []
    for i, line in enumerate(lines):
        if re.match(r"^\s*generate\s*$", line):
            generate_block_start_line.append(i)
    print(generate_block_start_line)
    generate_block_end_line = []
    for i, line in enumerate(lines):
        if re.match(r"^\s*endgenerate\s*$", line):
            generate_block_end_line.append(i)
    print(generate_block_end_line)

    # process generate block one by one

if __name__ == "__main__":
    main()