import json
import logging
import os, sys

def make_folder(logger):
    with open('config.json', 'r') as f:
        config = json.load(f)
    cases_number = len(config['case_mapping'].keys())
    logger.info(f'Number of cases: {cases_number}')
    for i in range(cases_number):
        logger.info(f'Creating folder for case: {i}')
        os.system(f'mkdir -p work/{i}')
        os.system(f'mkdir -p work/{i}/sim')
        os.system(f"cp -r ../sim/bench work/{i}/sim")
        os.system(f"cp -r ../sim/makefile work/{i}/sim")
        os.system(f"mkdir -p work/{i}/sim/memory")
        os.system(f"cp -r ../sim/memory/* work/{i}/sim/memory")
        os.system(f"mkdir -p work/{i}/sim/work")
        os.system(f"cp -r ../sim/work/makefile work/{i}/sim/work")
        os.system(f"cp -r ../sim/work/update_filelist.sh work/{i}/sim/work")
        os.system(f"cp -r ../rtl work/{i}")
        os.system(f"mkdir -p work/{i}/c")
        os.system(f"mkdir -p work/{i}/c/exe")
        os.system(f"cp -r ../c/exe/{config['case_mapping'][str(i)]} work/{i}/c/exe")


if __name__ == '__main__':
    logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger("make_folder")
    logger.setLevel(level = logging.INFO)
    handler = logging.FileHandler("make_folder.log", mode="w")
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    
    make_folder(logger)