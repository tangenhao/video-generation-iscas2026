import os
import sys
import argparse

parser = argparse.ArgumentParser(description="Obfuscate the code")
parser.add_argument("--path", type=str, help="Path to the code")
parser.add_argument("--top", type=str, help="Top level file name")

def new_str():
    with open("dict.txt", "r") as f:
        t = f.readlines()
    sub_dict = {}    

    for i in t:
        if (i == "\n"):
            continue
        i = i.strip().split()
        sub_dict[i[0]] = i[1]

    with open("dict", "w") as f:
        for key, value in sub_dict.items():
            f.write(f"{key} {value}\n")

if __name__ == "__main__":
    args = parser.parse_args()
    path = args.path
    top = args.top

    # find all modules name and file path
    modules = {}
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".v"):
                name = file[:-2]
                modules[name] = os.path.join(root, file)
    
    modules_to_obfuse = [
        "vcu", "operator", "activation_func", "vcu_regfile", "fpu", "fast_func", "dispatch", "synchronize", "sincos_pre", "reciprocal_pre",
        "log2_pre", "exp2_pre", "rsqrt_pre", "interpolor", "sincos_norm", "reciprocal_norm", "log2_norm",
        "exp2_norm", "rsqrt_norm", "fast_activation_pre", "fast_activation_norm", "data_in_convert", "data_out_convert", "operator_unroll"
    ]
    
    for module in modules_to_obfuse:
        if module in modules:
            print(f"Obfuscating {module}", modules[module])
            os.system(f"verible-verilog-obfuscate --preserve_interface true --preserve_builtin_functions --load_map ./dict.txt --save_map dict  <{modules[module]}> {modules[module]}1")
            os.system(f"mv {modules[module]}1 {modules[module]}")
            if module == "vcu":
                break