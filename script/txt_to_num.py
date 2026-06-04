import os
import struct
import argparse
import numpy as np
import random
import shutil

def to_int4(hexchar):
    """将一个十六进制字符转换为4位整数"""
    return int(hexchar, 16)

def to_int8(hexchars):
    """将两个十六进制字符转换为8位整数"""
    value = int(hexchars, 16)
    # 如果最高位为1，则为负数
    if value > 127:
        value -= 256
    return value

def to_fp16(hexchars):
    """将四个十六进制字符转换为半精度浮点数"""
    value = int(hexchars, 16)
    # 使用更可靠的方法转换fp16
    sign = (value >> 15) & 0x1
    exp = (value >> 10) & 0x1F
    frac = value & 0x3FF
    
    if exp == 0:
        if frac == 0:
            return 0.0 if sign == 0 else -0.0
        else:
            # 非规格化数
            return ((-1) ** sign) * (2 ** -14) * (frac / 1024)
    elif exp == 31:
        if frac == 0:
            return float('inf') if sign == 0 else float('-inf')
        else:
            return float('nan')
    else:
        # 规格化数
        return ((-1) ** sign) * (2 ** (exp - 15)) * (1 + frac / 1024)

def to_fp32(hexchars):
    """将八个十六进制字符转换为单精度浮点数"""
    try:
        value = int(hexchars, 16)
        return struct.unpack('!f', struct.pack('!I', value))[0]
    except Exception as e:
        print(f"错误：转换fp32值 '{hexchars}' 时出错: {e}")
        return 0.0

def process_file(input_file, output_file, data_format, verify=False, verify_count=5):
    """处理单个文件的转换"""
    print(f'处理文件: {input_file} -> {output_file}')
    
    # 确保输出目录存在
    os.makedirs(os.path.dirname(output_file) or '.', exist_ok=True)
    
    # 设置格式相关参数
    if data_format == "int4":
        chars_per_value = 1
        converter = to_int4
        format_str = "{:4d}"
    elif data_format == "int8":
        chars_per_value = 2
        converter = to_int8
        format_str = "{:5d}"
    elif data_format == "fp16":
        chars_per_value = 4
        converter = to_fp16
        format_str = "{:12.5f}"
    elif data_format == "fp32":
        chars_per_value = 8
        converter = to_fp32
        format_str = "{:15.7e}"  # 使用科学计数法确保能显示很小的数
    
    # 用于验证的样本
    verification_samples = []
    
    with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
        for line_num, line in enumerate(f_in):
            # 移除行末的换行符并转为小写
            line = line.strip().lower()
            
            if not line:  # 跳过空行
                continue
            
            # 检查注释并移除
            if '#' in line:
                line = line[:line.index('#')]
            
            # 移除所有空格和制表符
            line = line.replace(" ", "").replace("\t", "")
            
            if not line:  # 如果移除注释后为空行，则跳过
                continue
                
            if line.startswith("//"):  # 跳过注释行
                continue
                
            formatted_line = ""
            values = []
            
            # 解析行中的每个值
            for i in range(0, len(line), chars_per_value):
                if i + chars_per_value <= len(line):
                    hex_str = line[i:i+chars_per_value]
                    try:
                        value = converter(hex_str)
                        values.append(value)
                        formatted_line += format_str.format(value)
                        
                        # 存储一些样本用于验证
                        if verify and len(verification_samples) < verify_count and random.random() < 0.1:
                            verification_samples.append((hex_str, value))
                            
                        if i + chars_per_value < len(line):
                            formatted_line += ", "
                    except Exception as e:
                        print(f"警告：处理值 '{hex_str}' 时出错: {e}")
            
            if values:
                formatted_line += "\n"
                f_out.write(formatted_line)
    
    # 打印验证样本
    if verify and verification_samples:
        print(f"\n验证样本 ({data_format}):")
        for hex_str, value in verification_samples:
            print(f"  原始十六进制: {hex_str} -> 转换后: {format_str.format(value)}")
    
    return True  # 返回成功标志

def process_directory(input_dir, output_dir, data_format, verify=False, verify_count=5):
    """处理目录中的所有文件"""
    print(f"处理目录: {input_dir} -> {output_dir}")
    
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)
    
    # 计数器
    file_count = 0
    success_count = 0
    
    # 遍历目录中的所有文件
    for root, _, files in os.walk(input_dir):
        # 计算相对路径以保持目录结构
        rel_path = os.path.relpath(root, input_dir)
        if rel_path == ".":
            rel_path = ""
            
        # 为输出创建对应的子目录
        if rel_path:
            os.makedirs(os.path.join(output_dir, rel_path), exist_ok=True)
            
        for file in files:
            if file.endswith(".txt"):
                input_file = os.path.join(root, file)
                output_file = os.path.join(output_dir, rel_path, file.replace(".txt", f"_{data_format}_to_num.txt"))
                
                success = process_file(input_file, output_file, data_format, verify, verify_count)
                file_count += 1
                if success:
                    success_count += 1
    
    print(f"已处理 {file_count} 个文件，成功转换 {success_count} 个文件")
    return success_count == file_count

def txt_to_num(input_path='data.txt', output_path='data_converted.txt', data_format="fp32", verify=False, verify_count=5):    
    # 判断输入是文件还是目录
    if os.path.isfile(input_path):
        # 处理单个文件
        if os.path.isdir(output_path):
            # 如果输出是目录，在其中创建转换后的文件
            basename = os.path.basename(input_path)
            output_file = os.path.join(output_path, basename.replace(".txt", f"_{data_format}_to_num.txt"))
        else:
            # 如果输出已指定文件名
            output_file = output_path
            
        success = process_file(input_path, output_file, data_format, verify, verify_count)
    elif os.path.isdir(input_path):
        # 处理整个目录
        success = process_directory(input_path, output_path, data_format, verify, verify_count)
    else:
        print(f"错误：输入路径 '{input_path}' 不存在")
        return False

    print("转换" + ("成功" if success else "部分完成，有错误发生"))
    return success

def parse_arguments():
    parser = argparse.ArgumentParser(description="将十六进制文本文件转换为数值格式")
    parser.add_argument("--input", default='data.txt', help="输入文件或目录路径")
    parser.add_argument("--output", default='data_converted.txt', help="输出文件或目录路径")
    parser.add_argument("--format", choices=["int4", "int8", "fp16", "fp32"], default="fp32",
                        help="数据格式: int4, int8, fp16, fp32")
    parser.add_argument("--verify", action="store_true", help="打印样本验证数据")
    parser.add_argument("--verify_count", type=int, default=5, help="验证时显示的样本数量")
    return parser.parse_args()

if __name__ == "__main__":
    """主函数，可以作为模块导入或命令行调用"""
    args = parse_arguments()
    input_path = args.input
    output_path = args.output
    data_format = args.format
    verify = args.verify
    verify_count = args.verify_count

    txt_to_num(input_path, output_path, data_format, verify, verify_count)
