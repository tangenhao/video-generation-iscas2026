import json
import logging
import os, sys

def make_config(logger):
    type_a = [
        "fp", "bf", "i4", "i8", "i4n"
    ]
    type_b = [
        "fp", "bf", "i4", "i8", "i4n", "i4_outlier", "i8_outlier", "i4n_outlier"
    ]

    prefix = [
        "test_sparse_conv_1x1"
    ]
    
    endfix = [
       "2of4"
    ]

    cnt = 0
    cfg = {
        "case_mapping": {},
        "max_jobs": 16
    }

    for p in prefix:
        for a in type_a:
            for b in type_b:
                if a == "i4n" and b == "fp":
                    continue
                if a == "i4n" and b == "bf":
                    continue
                if a == "fp" and "outlier" in b:
                    continue
                if a == "bf" and "outlier" in b:
                    continue
                if a == "fp" and b == "i4n":
                    continue
                if a == "bf" and b == "i4n":
                    continue
                if len(endfix) > 0:
                    name = f'{p}_{a}x{b}_{endfix[0]}'
                else:
                    name = f'{p}_{a}x{b}'
                logger.info(f'generate config for {name}')
                cfg["case_mapping"][cnt] = name
                cnt += 1
    with open('config.json', 'w') as f:
        json.dump(cfg, f, indent=2)


if __name__ == '__main__':
    logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger = logging.getLogger("make_config")
    logger.setLevel(level = logging.INFO)
    handler = logging.FileHandler("make_config.log", mode="w")
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    
    make_config(logger)