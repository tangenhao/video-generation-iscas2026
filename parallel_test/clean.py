import json
import logging
import os, sys

def clean(logger):
    with open('config.json', 'r') as f:
        config = json.load(f)
    cases_number = len(config['case_mapping'].keys())
    logger.info(f'Number of cases: {cases_number}')
    for i in range(cases_number):
        logger.info(f'clean folder for case: {i}')
        os.system(f'rm -rf work/{i}/c')
        os.system(f'cd work/{i}/sim && make clean')


if __name__ == '__main__':
    logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger("clean")
    logger.setLevel(level = logging.INFO)
    handler = logging.FileHandler("clean.log", mode="w")
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    
    clean(logger)