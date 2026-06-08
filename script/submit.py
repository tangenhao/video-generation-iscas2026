import os
import sys
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(file_path, '../script/'))

from instantiate import delComment
import obfuse_python
import json
import subprocess

def copy_rtl_to_submit():
    print("Start to copy rtl to submit")
    rtl_path = os.path.join(file_path, "../rtl/")
    submit_path = os.path.join(file_path, "../submit/rtl")
    os.system(f"mkdir -p ../submit")
    os.system(f"mkdir -p ../submit/rtl")
    os.system(f"bash copy.sh {rtl_path} {submit_path}")


if __name__ == "__main__":

    obfuse_list = [
        "vcu", "operator", "activation_func", "vcu_regfile", "fpu", "fast_func", "dispatch", "synchronize", "sincos_pre", "reciprocal_pre",
        "log2_pre", "exp2_pre", "rsqrt_pre", "interpolor", "sincos_norm", "reciprocal_norm", "log2_norm",
        "exp2_norm", "rsqrt_norm", "fast_activation_pre", "fast_activation_norm", "data_in_convert", "data_out_convert"
    ]

    copy_rtl_to_submit()
    for root, dirs, files in os.walk(os.path.join(file_path, "../submit/rtl")):
        for file in files:
            if file.endswith('.v'):
                full_path = os.path.join(root, file)
                with open(full_path, 'r') as f:
                    content = f.read()
                    new_content = delComment(content)
                if file[:-2] in obfuse_list:
                    print(f"Obfuscating {file}")
                    with open("./dict.json", 'r') as f:
                        obfuse_dict = json.load(f)
                    new_content, new_dict = obfuse_python.obfuse(new_content, obfuse_dict)
                    data = json.dumps(obfuse_dict, indent=1)
                    with open("./dict.json", 'w', newline='\n') as f:
                        f.write(data)
                with open(full_path, 'w') as f:
                    f.write(new_content)
    os.system("bash remove_blank.sh ../submit/rtl/")

