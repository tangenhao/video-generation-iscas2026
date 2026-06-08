#!/bin/bash

# 设置当前目录为脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# 将 lib 目录加入 LD_LIBRARY_PATH
export LD_LIBRARY_PATH="$LIB_DIR:$LD_LIBRARY_PATH"

echo "LD_LIBRARY_PATH 已设置为: $LD_LIBRARY_PATH"
echo "尝试加载的库路径: $LIB_DIR/libfunc.so"

# 检查库文件是否存在
if [ ! -f "$LIB_DIR/libfunc.so" ]; then
    echo "错误: $LIB_DIR/libfunc.so 不存在！请检查路径和文件名。"
    exit 1
fi

# [Usage]: source config_lib_path.sh 
# [Mark]: 不要使用bash config_lib_path.sh, 因为那样会在子shell中设置环境变量, 对当前shell无效, 脚本结束后，子进程退出，环境变量丢失
