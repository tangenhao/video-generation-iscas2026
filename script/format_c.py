import os, sys, subprocess
import logging

def format_c(logger, path):
    for root, dirs, files in os.walk(path):
        for f in files:
            endfix = f.split(".")[-1]
            if endfix == "c" or endfix == "h" or endfix == "cpp":
                cmd = "clang-format -i %s --style=file" % (os.path.join(root, f))
                subprocess.Popen(cmd, shell=True)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger("format_c")
    handler = logging.FileHandler("format.log", "w")
    logger.addHandler(handler)
    format_c(logger, "../c/csrc")
    format_c(logger, "../c/include")