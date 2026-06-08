# File name  :    generate_master_insn.py
# Author     :    xiaocuicui
# Time       :    2024/01/16 21:09:47
# Version    :    V1.0
# Abstract   :        

import os
import sys
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(file_path, '../'))


import subprocess
import configparser


insn_bits = 128
insn_lanes = 8
insn_vspace = insn_lanes * 8
insn_hspace = int(insn_bits / insn_lanes * 60)
trim_number = 4
insn_font = "Times New Roman"

def draw_insn(bitfield_insn_component, bitfiedld_insn_name, bitfield_bash):

    context = """[\n"""
    for i, c in enumerate(bitfield_insn_component):
        if i == len(bitfield_insn_component) - 1:
            context += """{"name": "%s", "bits": %d, "type": %d}\n""" % (c[0], c[1], c[2])
        else:
            context += """{"name": "%s", "bits": %d, "type": %d},\n""" % (c[0], c[1], c[2])
    context += """]\n"""
    
    with open(os.path.join(file_path, "../doc/" + bitfiedld_insn_name+".json"), "w") as f:
        f.write(context)
    f.close()

    result = subprocess.run(bitfield_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    print(result.stdout.decode("utf-8"))

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
    
        insn_bash = "node ./bit-field/bin/bitfield.js --input " + file_path + "/../doc/" + insn_name + ".json --lanes " + str(insn_lanes) + " --bits " + str(insn_bits) + " --fontfamily " + insn_font + " --trim " + str(trim_number) + " --vspace " + str(insn_vspace) + " --hspace " + str(insn_hspace) + " > " + file_path + "/../doc/Figs/" + insn_name + ".svg"
        insn_bash += "&& rm " + file_path + "/../doc/" + insn_name + ".json"
        draw_insn(insn_componets, insn_name, insn_bash)

