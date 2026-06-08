"""
文件格式转换工具
支持二进制文件与文本文件之间的相互转换

参考C++实现:
- saveCharArrayToBinFile
- saveCharArrayToTextFile  
- saveCharArrayToFormattedTextFile

新增反向转换:
- bin_to_formatted_txt
- formatted_txt_to_bin
"""

import os
import struct
from typing import Union, Optional
from pathlib import Path


def save_char_array_to_bin_file(filename: str, data: bytes) -> int:
    """
    将字节数组保存为二进制文件
    
    Args:
        filename: 输出文件名
        data: 字节数据
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        with open(filename, 'wb') as file:
            written = file.write(data)
            if written != len(data):
                print(f"Error: 只写入了 {written}/{len(data)} 字节")
                return 1
        return 0
    except Exception as e:
        print(f"Error writing to file {filename}: {e}")
        return 1


def save_char_array_to_text_file(filename: str, data: bytes) -> int:
    """
    将字节数组保存为文本文件（每行一个十六进制字节）
    
    Args:
        filename: 输出文件名
        data: 字节数据
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        with open(filename, 'w') as file:
            for byte in data:
                file.write(f"{byte:02x}\n")
        return 0
    except Exception as e:
        print(f"Error writing to file {filename}: {e}")
        return 1


def save_char_array_to_formatted_text_file(filename: str, data: bytes, bytes_per_line: int = 32, 
                                         right_low: bool = True, int4: bool = False) -> int:
    """
    将字节数组保存为格式化文本文件
    
    Args:
        filename: 输出文件名
        data: 字节数据
        bytes_per_line: 每行字节数
        right_low: 是否右低位（反转字节顺序）
        int4: 是否使用4位十六进制（1位）而不是8位（2位）
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        with open(filename, 'w') as file:
            if right_low:
                # 右低位模式：每行反转字节顺序
                for i in range(0, len(data), bytes_per_line):
                    line_data = data[i:i + bytes_per_line]
                    result = ""
                    
                    for byte in line_data:
                        if int4:
                            hex_str = f"{byte & 0xf:01x}"
                        else:
                            hex_str = f"{byte & 0xff:02x}"
                        result = hex_str + result  # 前置拼接实现反转
                    
                    file.write(result + "\n")
            else:
                # 正常模式：每个字节一行
                for byte in data:
                    if int4:
                        file.write(f"{byte & 0xf:01x}\n")
                    else:
                        file.write(f"{byte & 0xff:02x}\n")
        
        return 0
    except Exception as e:
        print(f"Error writing to file {filename}: {e}")
        return 1


def bin_to_formatted_txt(bin_filename: str, txt_filename: str, bytes_per_line: int = 32,
                        right_low: bool = True, int4: bool = False) -> int:
    """
    二进制文件转换为格式化文本文件
    
    Args:
        bin_filename: 输入二进制文件名
        txt_filename: 输出文本文件名
        bytes_per_line: 每行字节数
        right_low: 是否右低位（反转字节顺序）
        int4: 是否使用4位十六进制
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        with open(bin_filename, 'rb') as file:
            data = file.read()
        
        return save_char_array_to_formatted_text_file(
            txt_filename, data, bytes_per_line, right_low, int4
        )
    except Exception as e:
        print(f"Error reading from file {bin_filename}: {e}")
        return 1


def formatted_txt_to_bin(txt_filename: str, bin_filename: str, bytes_per_line: int = 32,
                        right_low: bool = True, int4: bool = False) -> int:
    """
    格式化文本文件转换为二进制文件
    
    Args:
        txt_filename: 输入文本文件名
        bin_filename: 输出二进制文件名  
        bytes_per_line: 每行字节数
        right_low: 是否右低位（反转字节顺序）
        int4: 是否使用4位十六进制
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        with open(txt_filename, 'r') as file:
            lines = file.readlines()
        
        data = bytearray()
        
        if right_low:
            # 右低位模式：需要反转解析
            hex_width = 1 if int4 else 2
            
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                    
                # 反转字符串并按hex_width分组解析
                reversed_line = line[::-1]  # 反转整个字符串
                
                # 按hex_width分组并解析
                for i in range(0, len(reversed_line), hex_width):
                    hex_str = reversed_line[i:i + hex_width][::-1]  # 再次反转得到正确的hex字符串
                    if len(hex_str) == hex_width:
                        byte_val = int(hex_str, 16)
                        data.append(byte_val)
        else:
            # 正常模式：每行一个字节
            for line in lines:
                line = line.strip()
                if not line:
                    continue
                byte_val = int(line, 16)
                data.append(byte_val)
        
        return save_char_array_to_bin_file(bin_filename, bytes(data))
        
    except Exception as e:
        print(f"Error converting {txt_filename} to {bin_filename}: {e}")
        return 1


# ========================== 外部调用接口 ==========================

def convert_bin_to_formatted_txt(input_file: str, output_file: str, 
                                data_type: str = "fp32", bytes_per_line: int = 32,
                                right_low: bool = True, int4: bool = False) -> int:
    """
    通用二进制文件转格式化文本文件接口
    
    Args:
        input_file: 输入二进制文件路径
        output_file: 输出格式化文本文件路径
        data_type: 数据类型 ("fp16", "fp32", "int8", "int16", "int32")
        bytes_per_line: 每行字节数
        right_low: 是否右低位（反转字节顺序）
        int4: 是否使用4位十六进制
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        # 验证数据类型
        valid_types = {"fp16": 2, "fp32": 4, "int8": 1, "int16": 2, "int32": 4}
        if data_type not in valid_types:
            print(f"Error: 不支持的数据类型 '{data_type}'. 支持的类型: {list(valid_types.keys())}")
            return 1
        
        # 读取二进制文件
        with open(input_file, 'rb') as f:
            data = f.read()
        
        # 验证数据长度是否符合数据类型
        bytes_per_element = valid_types[data_type]
        if len(data) % bytes_per_element != 0:
            print(f"Warning: 文件大小 ({len(data)} bytes) 不是 {data_type} 元素大小 ({bytes_per_element} bytes) 的倍数")
        
        print(f"📁 转换: {input_file} -> {output_file}")
        print(f"   数据类型: {data_type} ({bytes_per_element} bytes/element)")
        print(f"   数据大小: {len(data)} bytes ({len(data)//bytes_per_element} elements)")
        print(f"   格式参数: bytes_per_line={bytes_per_line}, right_low={right_low}, int4={int4}")
        
        # 执行转换
        result = save_char_array_to_formatted_text_file(
            output_file, data, bytes_per_line, right_low, int4
        )
        
        if result == 0:
            print(f"✅ 转换成功: {output_file}")
        else:
            print(f"❌ 转换失败")
            
        return result
        
    except FileNotFoundError:
        print(f"Error: 输入文件不存在: {input_file}")
        return 1
    except Exception as e:
        print(f"Error: 转换过程中发生错误: {e}")
        return 1


def convert_formatted_txt_to_bin(input_file: str, output_file: str,
                                data_type: str = "fp32", bytes_per_line: int = 32,
                                right_low: bool = True, int4: bool = False) -> int:
    """
    通用格式化文本文件转二进制文件接口
    
    Args:
        input_file: 输入格式化文本文件路径
        output_file: 输出二进制文件路径
        data_type: 数据类型 ("fp16", "fp32", "int8", "int16", "int32")
        bytes_per_line: 每行字节数
        right_low: 是否右低位（反转字节顺序）
        int4: 是否使用4位十六进制
        
    Returns:
        0表示成功，1表示失败
    """
    try:
        # 验证数据类型
        valid_types = {"fp16": 2, "fp32": 4, "int8": 1, "int16": 2, "int32": 4}
        if data_type not in valid_types:
            print(f"Error: 不支持的数据类型 '{data_type}'. 支持的类型: {list(valid_types.keys())}")
            return 1
        
        bytes_per_element = valid_types[data_type]
        
        print(f"📁 转换: {input_file} -> {output_file}")
        print(f"   数据类型: {data_type} ({bytes_per_element} bytes/element)")
        print(f"   格式参数: bytes_per_line={bytes_per_line}, right_low={right_low}, int4={int4}")
        
        # 执行转换
        result = formatted_txt_to_bin(
            input_file, output_file, bytes_per_line, right_low, int4
        )
        
        if result == 0:
            # 验证输出文件大小
            output_size = os.path.getsize(output_file)
            num_elements = output_size // bytes_per_element
            print(f"✅ 转换成功: {output_file}")
            print(f"   输出大小: {output_size} bytes ({num_elements} elements)")
        else:
            print(f"❌ 转换失败")
            
        return result
        
    except FileNotFoundError:
        print(f"Error: 输入文件不存在: {input_file}")
        return 1
    except Exception as e:
        print(f"Error: 转换过程中发生错误: {e}")
        return 1


def batch_convert_bin_to_txt(input_dir: str, output_dir: str, 
                           file_pattern: str = "*.bin",
                           data_type: str = "fp32", bytes_per_line: int = 32,
                           right_low: bool = True, int4: bool = False) -> int:
    """
    批量转换二进制文件为格式化文本文件
    
    Args:
        input_dir: 输入目录
        output_dir: 输出目录
        file_pattern: 文件匹配模式 (例如: "*.bin", "weight_*.bin")
        data_type: 数据类型
        bytes_per_line: 每行字节数
        right_low: 是否右低位
        int4: 是否使用4位十六进制
        
    Returns:
        转换成功的文件数量
    """
    from pathlib import Path
    import glob
    
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    
    # 创建输出目录
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 查找匹配的文件
    pattern = str(input_path / file_pattern)
    files = glob.glob(pattern)
    
    if not files:
        print(f"Warning: 未找到匹配的文件: {pattern}")
        return 0
    
    print(f"🚀 批量转换开始: {len(files)} 个文件")
    print(f"   输入目录: {input_dir}")
    print(f"   输出目录: {output_dir}")
    print(f"   文件模式: {file_pattern}")
    
    success_count = 0
    
    for file_path in files:
        input_file = Path(file_path)
        output_file = output_path / (input_file.stem + ".txt")
        
        print(f"\n📄 处理: {input_file.name}")
        result = convert_bin_to_formatted_txt(
            str(input_file), str(output_file),
            data_type, bytes_per_line, right_low, int4
        )
        
        if result == 0:
            success_count += 1
    
    print(f"\n🎯 批量转换完成: {success_count}/{len(files)} 文件转换成功")
    return success_count


def batch_convert_txt_to_bin(input_dir: str, output_dir: str, 
                           file_pattern: str = "*.txt",
                           data_type: str = "fp32", bytes_per_line: int = 32,
                           right_low: bool = True, int4: bool = False) -> int:
    """
    批量转换格式化文本文件为二进制文件
    
    Args:
        input_dir: 输入目录
        output_dir: 输出目录
        file_pattern: 文件匹配模式 (例如: "*.txt", "output_*.txt")
        data_type: 数据类型
        bytes_per_line: 每行字节数
        right_low: 是否右低位
        int4: 是否使用4位十六进制
        
    Returns:
        转换成功的文件数量
    """
    from pathlib import Path
    import glob
    
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    
    # 创建输出目录
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 查找匹配的文件
    pattern = str(input_path / file_pattern)
    files = glob.glob(pattern)
    
    if not files:
        print(f"Warning: 未找到匹配的文件: {pattern}")
        return 0
    
    print(f"🚀 批量转换开始: {len(files)} 个文件")
    print(f"   输入目录: {input_dir}")
    print(f"   输出目录: {output_dir}")
    print(f"   文件模式: {file_pattern}")
    
    success_count = 0
    
    for file_path in files:
        input_file = Path(file_path)
        output_file = output_path / (input_file.stem + ".bin")
        
        print(f"\n📄 处理: {input_file.name}")
        result = convert_formatted_txt_to_bin(
            str(input_file), str(output_file),
            data_type, bytes_per_line, right_low, int4
        )
        
        if result == 0:
            success_count += 1
    
    print(f"\n🎯 批量转换完成: {success_count}/{len(files)} 文件转换成功")
    return success_count


def get_file_info(filename: str) -> dict:
    """
    获取文件信息（用于调试和验证）
    
    Args:
        filename: 文件路径
        
    Returns:
        文件信息字典
    """
    try:
        file_path = Path(filename)
        if not file_path.exists():
            return {"error": "文件不存在"}
        
        file_size = file_path.stat().st_size
        
        info = {
            "filename": str(file_path),
            "size_bytes": file_size,
            "size_elements": {},
            "exists": True
        }
        
        # 计算不同数据类型的元素数量
        data_types = {"fp16": 2, "fp32": 4, "int8": 1, "int16": 2, "int32": 4}
        for dtype, bytes_per_elem in data_types.items():
            info["size_elements"][dtype] = file_size // bytes_per_elem
            
        return info
        
    except Exception as e:
        return {"error": str(e)}


# ========================== 命令行接口 ==========================

def main():
    """命令行接口"""
    import argparse
    
    parser = argparse.ArgumentParser(description="文件格式转换工具")
    subparsers = parser.add_subparsers(dest='command', help='转换命令')
    
    # bin -> txt 子命令
    bin2txt_parser = subparsers.add_parser('bin2txt', help='二进制文件转格式化文本文件')
    bin2txt_parser.add_argument('input_file', help='输入二进制文件')
    bin2txt_parser.add_argument('output_file', help='输出文本文件')
    bin2txt_parser.add_argument('--data-type', choices=['fp16', 'fp32', 'int8', 'int16', 'int32'], 
                               default='fp32', help='数据类型 (默认: fp32)')
    bin2txt_parser.add_argument('--bytes-per-line', type=int, default=32, help='每行字节数 (默认: 32)')
    bin2txt_parser.add_argument('--right-low', default=True, help='启用右低位模式')
    bin2txt_parser.add_argument('--int4', action='store_true', help='使用4位十六进制')
    
    # txt -> bin 子命令  
    txt2bin_parser = subparsers.add_parser('txt2bin', help='格式化文本文件转二进制文件')
    txt2bin_parser.add_argument('input_file', help='输入文本文件')
    txt2bin_parser.add_argument('output_file', help='输出二进制文件')
    txt2bin_parser.add_argument('--data-type', choices=['fp16', 'fp32', 'int8', 'int16', 'int32'],
                               default='fp32', help='数据类型 (默认: fp32)')
    txt2bin_parser.add_argument('--bytes-per-line', type=int, default=32, help='每行字节数 (默认: 32)')
    txt2bin_parser.add_argument('--right-low', default=True, help='启用右低位模式')
    txt2bin_parser.add_argument('--int4', action='store_true', help='使用4位十六进制')
    
    # 批量转换子命令
    batch_bin2txt_parser = subparsers.add_parser('batch_bin2txt', help='批量转换二进制文件')
    batch_bin2txt_parser.add_argument('input_dir', help='输入目录')
    batch_bin2txt_parser.add_argument('output_dir', help='输出目录')
    batch_bin2txt_parser.add_argument('--pattern', default='*.bin', help='文件匹配模式 (默认: *.bin)')
    batch_bin2txt_parser.add_argument('--data-type', choices=['fp16', 'fp32', 'int8', 'int16', 'int32'],
                             default='fp32', help='数据类型 (默认: fp32)')
    batch_bin2txt_parser.add_argument('--bytes-per-line', type=int, default=32, help='每行字节数 (默认: 32)')
    batch_bin2txt_parser.add_argument('--right-low', default=True, help='启用右低位模式')
    batch_bin2txt_parser.add_argument('--int4', action='store_true', help='使用4位十六进制')
    
    # 批量文本转二进制子命令
    batch_txt2bin_parser = subparsers.add_parser('batch_txt2bin', help='批量转换文本文件为二进制文件')
    batch_txt2bin_parser.add_argument('input_dir', help='输入目录')
    batch_txt2bin_parser.add_argument('output_dir', help='输出目录')
    batch_txt2bin_parser.add_argument('--pattern', default='*.txt', help='文件匹配模式 (默认: *.txt)')
    batch_txt2bin_parser.add_argument('--data-type', choices=['fp16', 'fp32', 'int8', 'int16', 'int32'],
                                     default='fp32', help='数据类型 (默认: fp32)')
    batch_txt2bin_parser.add_argument('--bytes-per-line', type=int, default=32, help='每行字节数 (默认: 32)')
    batch_txt2bin_parser.add_argument('--right-low', default=True, help='启用右低位模式')
    batch_txt2bin_parser.add_argument('--int4', action='store_true', help='使用4位十六进制')
    
    # 文件信息子命令
    info_parser = subparsers.add_parser('info', help='显示文件信息')
    info_parser.add_argument('filename', help='文件路径')
    
    args = parser.parse_args()
    
    if args.command == 'bin2txt':
        result = convert_bin_to_formatted_txt(
            args.input_file, args.output_file,
            args.data_type, args.bytes_per_line,
            args.right_low, args.int4
        )
        exit(result)
        
    elif args.command == 'txt2bin':
        result = convert_formatted_txt_to_bin(
            args.input_file, args.output_file,
            args.data_type, args.bytes_per_line,
            args.right_low, args.int4
        )
        exit(result)
        
    elif args.command == 'batch_bin2txt':
        success_count = batch_convert_bin_to_txt(
            args.input_dir, args.output_dir, args.pattern,
            args.data_type, args.bytes_per_line,
            args.right_low, args.int4
        )
        print(f"Total files converted: {success_count}")
        exit(0 if success_count > 0 else 1)
        
    elif args.command == 'batch_txt2bin':
        success_count = batch_convert_txt_to_bin(
            args.input_dir, args.output_dir, args.pattern,
            args.data_type, args.bytes_per_line,
            args.right_low, args.int4
        )
        print(f"Total files converted: {success_count}")
        exit(0 if success_count > 0 else 1)
        
    elif args.command == 'info':
        info = get_file_info(args.filename)
        if "error" in info:
            print(f"Error: {info['error']}")
            exit(1)
        else:
            print(f"File: {info['filename']}")
            print(f"Size: {info['size_bytes']} bytes")
            print("Elements count by data type:")
            for dtype, count in info['size_elements'].items():
                print(f"  {dtype}: {count} elements")
            exit(0)
    else:
        parser.print_help()
        exit(1)


if __name__ == "__main__":
    # 如果没有命令行参数，显示帮助信息
    import sys
    if len(sys.argv) == 1:
        print("🔧 文件格式转换工具")
        print("使用方法: python txt_bin_convert.py <command> [args...]")
        print("可用命令:")
        print("  bin2txt       - 二进制文件转格式化文本文件")
        print("  txt2bin       - 格式化文本文件转二进制文件") 
        print("  batch         - 批量转换二进制文件为文本文件")
        print("  batch_txt2bin - 批量转换文本文件为二进制文件")
        print("  info          - 显示文件信息")
        print("使用 --help 查看详细帮助")
    else:
        main()
