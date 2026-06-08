import json
import logging
import os, sys, subprocess

def run_test(logger):
    with open('config.json', 'r') as f:
        config = json.load(f)
    cases_number = len(config['case_mapping'].keys())
    logger.info(f'Number of cases: {cases_number}')
    logger.info(f'Maximum number of jobs: {config["max_jobs"]}')
    for i in range(0, cases_number, config['max_jobs']):
        process = []
        for j in range(config['max_jobs']):
            if i + j >= cases_number:
                break
            process.append(subprocess.Popen(f'cd work/{i+j}/c/exe && ./{config["case_mapping"][str(i + j)]} | tee {config["case_mapping"][str(i + j)]}.log', shell=True))
            logger.info(f'Generating input for case: {i + j}, pid: {process[-1].pid}')
        for p in process:
            p.wait()
            logger.info(f'Thread: {p.pid} finished with return code: {p.returncode}')
        process = []
        for j in range(config['max_jobs']):
            if i + j >= cases_number:
                break
            process.append(subprocess.Popen(f'cd work/{i+j}/sim && make update && make sim TOP=npu_pcie_tb', shell=True))
            logger.info(f'Running simulation for case: {i + j}, pid: {process[-1].pid}')
        for p in process:
            p.wait()
            logger.info(f'Thread: {p.pid} finished with return code: {p.returncode}')

if __name__ == '__main__':
    logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger("run_test")
    logger.setLevel(level = logging.INFO)
    handler = logging.FileHandler("run_test.log", mode="w")
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    
    run_test(logger)