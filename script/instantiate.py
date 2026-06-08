# generate instantiation of module 
# usage: python script/instantiate.py --file components/basic/adder/adder/rtl/adder.v 
#        python script/instantiate.py --file components/basic/adder/adder/rtl/adder.v --para
#        python script/instantiate.py --file components/basic/adder/adder/rtl/adder.v --para -tb

import os
import sys
file_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(file_path, '../'))

import re
import chardet
import argparse

def delComment( Text ):
    """ removed comment """
    single_line_comment = re.compile(r"//(.*)$", re.MULTILINE)
    multi_line_comment  = re.compile(r"/\*(.*?)\*/",re.DOTALL)
    Text = multi_line_comment.sub('\n',Text)
    Text = single_line_comment.sub('\n',Text)
    return Text

def delBlock( Text ) :
    """ removed task and function block """
    Text = re.sub(r'\Wtask\W[\W\w]*?\Wendtask\W','\n',Text)
    Text = re.sub(r'\Wfunction\W[\W\w]*?\Wendfunction\W','\n',Text)
    Text = re.sub(r'\Wgenerate\W[\W\w]*?\Wendgenerate\W','\n',Text)
    return Text

def findName(inText):
    """ find module name and port list"""
    p = re.search(r'([a-zA-Z_][a-zA-Z_0-9]*)\s*',inText)
    mo_Name = p.group(0).strip()
    return mo_Name

def paraDeclare(inText ,portArr) :
    """ find parameter declare """
    pat = r'\s'+ portArr + r'\s[\w\W]*?[;,)]'
    ParaList = re.findall(pat ,inText)

    return ParaList

def portDeclare(inText ,portArr) :
    """find port declare, Syntax:
       input [ net_type ] [ signed ] [ range ] list_of_port_identifiers

       return list as : (port, [range])
    """
    port_definition = re.compile(
        r'\b' + portArr +
        r''' (\s+(wire|reg)\s+)* (\s*signed\s+)*  (\s*\[.*?:.*?\]\s*)*
        (?P<port_list>.*?)
        (?= \binput\b | \boutput\b | \binout\b | ; | \) )
        ''',
        re.VERBOSE|re.MULTILINE|re.DOTALL
    )

    pList = port_definition.findall(inText)

    t = []
    for ls in pList:
        if len(ls) >=2  :
            t = t+ portDic(ls[-2:])
    return t

def portDic(port) :
    """delet as : input a =c &d;
        return list as : (port, [range])
    """
    pRe = re.compile(r'(.*?)\s*=.*', re.DOTALL)

    pRange = port[0]
    pList  = port[1].split(',')
    pList  = [ i.strip() for i in pList if i.strip() !='' ]
    pList  = [(pRe.sub(r'\1', p), pRange.strip() ) for p in pList ]

    return pList

def formatPort(AllPortList, isPortRange =1) :
    PortList = AllPortList[0] + AllPortList[1] + AllPortList[2]

    str =''
    if PortList !=[] :
        l1 = max([len(i[0]) for i in PortList])
        # l3 = max(24, l1)

        strList = []
        for pl in AllPortList :
            if pl  != [] :
                str = ',\n'.join( [' '*4+'.'+ i[0].ljust(l1+1)
                                  + '( '+ (i[0].ljust(l1+1)) + ')' for i in pl ] )
                strList = strList + [ str ]

        str = ',\n'.join(strList)

    return str


def formatPort_tb(AllPortList, isPortRange =1) :
    PortList = AllPortList[0] + AllPortList[1] + AllPortList[2]

    str =''
    if PortList !=[] :
        l1 = max([len(i[0]) for i in PortList])
        # l3 = max(24, l1)

        strList = []
        for pl in AllPortList :
            if pl  != [] :
                str = ',\n'.join( [' '*4+'.'+ i[0].ljust(l1+1)
                                  + '( '+ (i[0].ljust(l1+1)) + ')' for i in pl ] )
                strList = strList + [ str ]

        str = ',\n'.join(strList)

    return str


def formatDeclare(PortList,portArr, initial = "" ):
    str =''
    width_length = max([len(i[1]) for i in PortList]) if PortList!=[] else 0

    if PortList!=[] :
        str = '\n'.join( [ portArr.ljust(4) +' '+i[1].ljust(width_length+1)+i[0] + ';' for i in PortList])

    return str


def formatDeclare_tb(PortList,portArr, initial = "" ):
    str =''
    width_length = max([len(i[1]) for i in PortList]) if PortList!=[] else 0

    if PortList!=[] :
        # str = '\n'.join( [ portArr.ljust(4) +' '+(i[1]+min(len(i[1]),1)*' '
        #                    +i[0]) + ';' for i in PortList])
        para_pat = r'\[((?!\d)\w+)(?:-\d+)?(?::\d+)?\]'
        for i in PortList:
            matches = re.findall(para_pat, i[1])
            if (matches):
                s = re.sub(f"\\b{matches[0]}\\b", f"{matches[0]}", i[1])
                str += portArr.ljust(4) +' '+(s.ljust(width_length+1) +i[0]) + ';' + "\n"
            else:
                str += portArr.ljust(4) +' '+(i[1].ljust(width_length+1) +i[0]) + ';' + "\n"

    return str


def formatPara(ParaList) :
    paraDec = ''
    paraDef = ''
    if ParaList !=[]:
        s = '\n'.join( ParaList)
        pat = r'([a-zA-Z_][a-zA-Z_0-9]*)\s*=\s*([\w\W]*?)\s*[;,)]'
        p = re.findall(pat,s)

        l1 = max([len(i[0] ) for i in p])
        l2 = max([len(i[1] ) for i in p])

        paraDec = '\n'.join( ['parameter %s = %s;'
                             %(i[0].ljust(l1 +1),i[1].ljust(l2 ))
                             for i in p])
        paraDef =  '#(\n' +',\n'.join( ['    .'+ i[0].ljust(l1+1)
                    + '('+ i[1].ljust(len(i[1]))+')' for i in p])+ '\n)'
    
    return paraDec,paraDef


def formatPara_tb(ParaList) :
    paraDec = ''
    paraDef = ''
    if ParaList !=[]:
        s = '\n'.join( ParaList)
        pat = r'([a-zA-Z_][a-zA-Z_0-9]*)\s*=\s*([\w\W]*?)\s*[;,)]'
        p = re.findall(pat,s)

        l1 = max([len(i[0]) for i in p])
        # l2 = max([len(i[1]) for i in p])

        paraDec = '\n'.join( ['parameter %s = %s;'
                             %((i[0] + "").ljust(l1 +1),i[1].ljust(len(i[1])))
                             for i in p])
        paraDef =  '#(\n' +',\n'.join( ['    .'+ i[0].ljust(l1 +1)
                    + '( '+ i[0].ljust(l1 +1)+')' for i in p])+ '\n)'
    
    return paraDec, paraDef


def writeInstance(input_file, para_flag):
    """ write testbench to file """
    with open(input_file, 'rb') as f:
        f_info =  chardet.detect(f.read())
        f_encoding = f_info['encoding']
    with open(input_file, encoding=f_encoding) as inFile:
        inText  = inFile.read()

    # removed comment,task,function
    inText = delComment(inText)
    inText = delBlock  (inText)

    # moduel ... endmodule  #
    moPos_begin = re.search(r'(\b|^)module\b', inText ).end()
    moPos_end   = re.search(r'\bendmodule\b', inText ).start()
    inText = inText[moPos_begin:moPos_end]

    name  = findName(inText)
    paraList = paraDeclare(inText,'parameter')
    if args.testbench:
        paraDec , paraDef = formatPara_tb(paraList)
    else:
        paraDec , paraDef = formatPara(paraList)

    ioPadAttr = [ 'input','output','inout']
    input  =  portDeclare(inText,ioPadAttr[0])
    output =  portDeclare(inText,ioPadAttr[1])
    inout  =  portDeclare(inText,ioPadAttr[2])

    if args.testbench:
        portList = formatPort_tb( [input , output , inout] )
    else:
        portList = formatPort( [input , output , inout] )
    if args.testbench:
        input  = formatDeclare_tb(input ,'reg')
        output = formatDeclare_tb(output ,'wire')
        inout  = formatDeclare_tb(inout ,'wire')        
    else:
        input  = formatDeclare(input ,'reg')
        output = formatDeclare(output ,'wire')
        inout  = formatDeclare(inout ,'wire')

    # write Instance

    # module_parameter_port_list
    # if(paraDec!=''):
    #     print("// %s Parameters\n%s\n" % (name, paraDec))

    # # list_of_port_declarations
    # print("// %s Inputs\n%s\n"  % (name, input ))
    # print("// %s Outputs\n%s\n" % (name, output))
    # if(inout!=''):
    #     print("// %s Bidirs\n%s\n"  % (name, inout ))

    # UUT
    if para_flag:
        text = name + ' ' + 'u_' + name + '(\n' + portList + '\n);'
    else:
        if args.testbench:
            text = paraDec + '\n\n' + input + '\n' + output + '\n\n' + name + ' ' + paraDef + ' ' + 'u_' + name + '(\n' + portList + '\n);'
        else:
            text = name + ' ' + paraDef + ' ' + 'u_' + name + '(\n' + portList + '\n);'
    print(text)
    # print("%s %s u_%s (\n%s\n);" %(name,paraDef,name,portList))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='generate instantiation of a module')
    parser.add_argument('-f', '--file', type=str, help="verilog file path")
    parser.add_argument('-p', '--para', action='store_false', help="display parameters")
    parser.add_argument('-tb', '--testbench', action='store_true', help="instantation for testbench")
    args = parser.parse_args()

    writeInstance(args.file, args.para)
    