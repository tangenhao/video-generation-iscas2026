import json
import os
import string
import sys
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(file_path, '../'))

import re
import chardet
import argparse
import random

from instantiate import *

parser = argparse.ArgumentParser(description='Obfuscate Verilog code')
parser.add_argument('--file', type=str, help='Verilog file path')
parser.add_argument('--dict', type=str, help='Obfuscation dictionary')
args = parser.parse_args()


def paraDefine(paraList):
    """ generate parameter define """
    paraDict = []
    if paraList != []:
        s = '\n'.join(paraList)
        pat = r'([a-zA-Z_][a-zA-Z_0-9]*)\s*=\s*([\w\W]*?)\s*[;,)]'
        p = re.findall(pat,s)
        for i in p:
            paraDict.append(i[0])
    return paraDict


def portDefine(portList):
    """ generate port define """
    portDict = []
    if portList != []:
      for i in portList:
        portDict.append(i[0])
    return portDict


def varibleDeclare(inText) :
    """find varible declare, do not find input output inout, Syntax:
       reg [ signed ] [ range ] list_of_port_identifiers
       wire [ signed ] [ range ] list_of_port_identifiers
       wire [ signed ] [ range ] list_of_port_identifiers [range]
       

       return list as : (port, [range])
    """
    port_definition = re.compile(
      r'\b(reg|wire)\s+ (\s*signed\s+)*  (\s*\[.*?:.*?\]\s*)* (?P<port_list>.*?)(?=[;,])',
      # r'((?<=\b(reg|wire)\s).*?(?=[;\[]))',
      re.VERBOSE|re.MULTILINE|re.DOTALL
    )

    pList = port_definition.findall(inText)
    t = []
    for ls in pList:
      if ('[' in ls[-1]):
        t.append(ls[-1].split('[')[0].strip())
      else:
        t.append(ls[-1])
    return t


def generate_random_str(randomlength=16):
  """
  生成一个指定长度的随机字符串
  """
  random_str =''
  base_str ='ABCDEFGHIGKLMNOPQRSTUVWXYZabcdefghigklmnopqrstuvwxyz0123456789'
  length =len(base_str) -1
  for i in range(randomlength):
    random_str += base_str[random.randint(0, length)]
    if random_str[0].isdigit():
      random_str = random_str.replace(random_str[0], random.choice(string.ascii_letters))
  return random_str

def obfuse(inText, obfuse_dict):
    moPos_begin = re.search(r'(\b|^)module\b', inText ).end()
    moPos_end   = re.search(r'\bendmodule\b', inText ).start()
    inText = inText[moPos_begin:moPos_end]

    # Module name
    name  = findName(inText)

    # Parameter List
    paraList = paraDeclare(inText,'parameter')
    paraList = paraDefine(paraList)

    # Ports
    ioPadAttr = [ 'input','output','inout']
    inputList  =  portDeclare(inText,ioPadAttr[0])
    outputList =  portDeclare(inText,ioPadAttr[1])
    inoutList  =  portDeclare(inText,ioPadAttr[2])
    inputList = portDefine(inputList)
    outputList = portDefine(outputList)
    inoutList = portDefine(inoutList)

    # regs and wires
    varibleList = varibleDeclare(inText)
    new_varibleList = []
    for i in varibleList:
      if i not in inputList and i not in outputList and i not in inoutList:
        new_varibleList.append(i)

    for i in paraList:
      if i not in obfuse_dict.keys():
        obfuse_dict[i] = generate_random_str(len(i))
    for i in new_varibleList:
      if i not in obfuse_dict.keys():
        obfuse_dict[i] = generate_random_str(len(i))

    for key, value in obfuse_dict.items():
      pat = r'\b' + key + r'\b'
      inText = re.sub(pat, value, inText)

    inText = "module" + inText + "\nendmodule"

    return inText, obfuse_dict


def main(file_name, dict_name):
    file_name = args.file
    dict_name = args.dict if args.dict else None

    if dict_name:
      with open(dict_name, 'r') as f:
        obfuse_dict = json.load(f)

    with open(file_name, 'rb') as f:
      f_info =  chardet.detect(f.read())
      f_encoding = f_info['encoding']
    with open(file_name, encoding=f_encoding) as inFile:
      inText  = inFile.read()
    
    inText, obfuse_dict = obfuse(inText, obfuse_dict)

    with open(file_name, 'w', newline='\n') as f:
      f.write(inText)

    if dict_name:
      data = json.dumps(obfuse_dict, indent=1)
      with open(dict_name, 'w', newline='\n') as f:
        f.write(data)

if __name__ == '__main__':
    parser.parse_args()
    main(args.file, args.dict)