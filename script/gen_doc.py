import os
import configparser

file_path = os.path.dirname(os.path.realpath(__file__))


if __name__ == "__main__":
    config = configparser.ConfigParser()
    config.read(os.path.join(file_path, '../cfg/insn_bits.cfg'))
    all_sections = config.sections()
    description = configparser.ConfigParser()
    description.read(os.path.join(file_path, '../cfg/insn_description.cfg'))
    description_sections = description.sections()
    default = configparser.ConfigParser()
    default.read(os.path.join(file_path, '../cfg/insn_default.cfg'))
    default_sections = default.sections()
    for section in all_sections:
        insn_name = section
        options = config.options(section)
        # [name, bits, type]
        insn_componets = []
        with open("../doc/" + insn_name + ".md", "w") as f:
          f.write("| Name | Field | Bits | Description | Default |\n")
          f.write("|:-----|:-----:|:----:|:------------|:-------:|\n")
          start = 0
          for o_idx, option in enumerate(options):
              value = config.get(section, option)
              insn_componets.append([option, int(value), o_idx+2])
              default_value = default.get(section, option, fallback=None)
              description_value = description.get(section, option, fallback=None)
              name_str = "| "
              name_str += option + " | "
              name_str += "[" + str(start + int(value) - 1) + ":" + str(start) + "] | "
              name_str += str(value) + " | "
              if description_value is not None:
                name_str += description_value + " | "
              else:
                name_str += " | "
              if default_value is not None:
                name_str += default_value + " | "
              else:
                name_str += " | "
              start += int(value)
              f.write(name_str)
              f.write("\n")