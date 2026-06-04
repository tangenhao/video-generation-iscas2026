#!/bin/bash
# 编译NPU算子动态库 - 支持多模式编译

set -e

# 默认参数
CONFIG_FOR_FPGA="off" # on 或 off
DEBUG_MODE="off"      # on 或 off  
SIM_MODE="off"        # on 或 off
CLEAN_BUILD=false
VERBOSE=true

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 帮助信息
show_help() {
    cat << EOF
🔧 NPU算子动态库编译脚本

使用方法:
  $0 [选项]

选项:
  -f, --fpga MODE       FPGA配置: on 或 off (默认: off)
  -d, --debug MODE      调试模式: on 或 off (默认: off)
  -s, --sim MODE        仿真输出: on 或 off (默认: off)
  -c, --clean          清理后重新编译
  -v, --verbose        显示详细编译信息
  -h, --help           显示此帮助信息

模式说明:
  FPGA配置 (--fpga):
    on   - 使用FPGA配置的SRAM深度
    off  - 使用仿真配置的SRAM深度
    
  调试模式 (--debug):  
    on   - 启用调试信息，_DEBUG=true
    off  - 关闭调试信息，_DEBUG=false
    
  仿真输出 (--sim):
    on   - 文本格式输出(.txt)，SIM=true
    off  - 二进制格式输出(.bin)，SIM=false

示例:
  $0                           # 默认模式 (仿真配置+非调试+二进制输出)
  $0 -f on                     # FPGA配置
  $0 -d on                     # 启用调试模式
  $0 -s on                     # 文本输出模式
  $0 -f on -d on -s on         # FPGA+调试+文本输出
  $0 --clean --verbose         # 清理后详细编译

常用组合:
  开发调试:  $0 -f off -d on -s on
  仿真测试:  $0 -f off -d off -s on  
  FPGA部署:  $0 -f on -d off -s off

EOF
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--fpga)
            CONFIG_FOR_FPGA="$2"
            shift 2
            ;;
        -d|--debug)
            DEBUG_MODE="$2"
            shift 2
            ;;
        -s|--sim)
            SIM_MODE="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}❌ 未知参数: $1${NC}"
            echo "使用 $0 --help 查看帮助信息"
            exit 1
            ;;
    esac
done

# 验证参数
if [[ "$CONFIG_FOR_FPGA" != "on" && "$CONFIG_FOR_FPGA" != "off" ]]; then
    echo -e "${RED}❌ 错误: FPGA配置必须是 'on' 或 'off'${NC}"
    exit 1
fi

if [[ "$DEBUG_MODE" != "on" && "$DEBUG_MODE" != "off" ]]; then
    echo -e "${RED}❌ 错误: 调试模式必须是 'on' 或 'off'${NC}"
    exit 1
fi

if [[ "$SIM_MODE" != "on" && "$SIM_MODE" != "off" ]]; then
    echo -e "${RED}❌ 错误: 仿真输出模式必须是 'on' 或 'off'${NC}"
    exit 1
fi

# 显示编译配置
echo -e "${GREEN}🚀 开始编译NPU算子动态库...${NC}"
echo -e "${BLUE}📋 编译配置:${NC}"
echo -e "   FPGA配置: ${YELLOW}$CONFIG_FOR_FPGA${NC}"
echo -e "   调试模式: ${YELLOW}$DEBUG_MODE${NC}"
echo -e "   仿真输出: ${YELLOW}$SIM_MODE${NC}"
echo -e "   清理构建: ${YELLOW}$CLEAN_BUILD${NC}"
echo -e "   详细输出: ${YELLOW}$VERBOSE${NC}"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 进入C源码目录
cd "$PROJECT_ROOT/c"

# 清理构建目录（如果需要）
if [[ "$CLEAN_BUILD" == true ]]; then
    echo -e "${YELLOW}🧹 清理构建目录...${NC}"
    rm -rf build lib
fi

# 创建并进入构建目录
mkdir -p build && cd build

# 设置CMake参数
CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_POSITION_INDEPENDENT_CODE=ON"
CMAKE_ARGS="$CMAKE_ARGS -DBUILD_SHARED_LIBS=ON"

# 根据模式设置CMake参数
if [[ "$CONFIG_FOR_FPGA" == "on" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DCONFIG_FOR_FPGA=ON"
else
    CMAKE_ARGS="$CMAKE_ARGS -DCONFIG_FOR_FPGA=OFF"
fi

if [[ "$DEBUG_MODE" == "on" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DDEBUG_MODE=ON"
else
    CMAKE_ARGS="$CMAKE_ARGS -DDEBUG_MODE=OFF"
fi

if [[ "$SIM_MODE" == "on" ]]; then
    CMAKE_ARGS="$CMAKE_ARGS -DSIM_MODE=ON"
else
    CMAKE_ARGS="$CMAKE_ARGS -DSIM_MODE=OFF"
fi

# 配置CMake
echo -e "${BLUE}📝 配置CMake...${NC}"
if [[ "$VERBOSE" == true ]]; then
    echo "   CMake参数: $CMAKE_ARGS"
    cmake .. $CMAKE_ARGS
else
    cmake .. $CMAKE_ARGS > cmake_config.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ CMake配置失败，查看详细信息:${NC}"
        cat cmake_config.log
        exit 1
    fi
fi

# 编译动态库
echo -e "${BLUE}🔨 编译NPU算子...${NC}"
MAKE_ARGS="-j$(nproc)"

if [[ "$VERBOSE" == true ]]; then
    make $MAKE_ARGS
else
    make $MAKE_ARGS > make_build.log 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ 编译失败，查看详细信息:${NC}"
        tail -n 20 make_build.log
        exit 1
    fi
fi

# 检查是否生成了动态库
EXPECTED_LIBS=("libnpu_interface.so")
SUCCESS_COUNT=0

echo -e "${BLUE}🔍 检查生成的动态库...${NC}"
for lib in "${EXPECTED_LIBS[@]}"; do
    if [ -f "../lib/$lib" ]; then
        echo -e "   ${GREEN}✅ $lib${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "   ${RED}❌ $lib (未找到)${NC}"
    fi
done

if [[ $SUCCESS_COUNT -eq 0 ]]; then
    echo -e "${RED}❌ 动态库编译失败，未找到预期的库文件${NC}"
    echo "查找所有可能的库文件："
    find . -name "*.so" -o -name "*.dylib" -o -name "*.dll" | head -10
    exit 1
fi

# 创建Python接口lib目录并复制库文件
echo -e "${BLUE}📦 部署动态库...${NC}"
mkdir -p ../../python_interface/lib

# 复制所有生成的.so文件
if ls ../lib/*.so 1> /dev/null 2>&1; then
    cp ../lib/*.so ../../python_interface/lib/
    echo "   动态库已复制到 python_interface/lib/"
    
    # 显示复制的文件
    if [[ "$VERBOSE" == true ]]; then
        echo "   复制的文件:"
        ls -la ../../python_interface/lib/*.so | sed 's/^/     /'
    fi
else
    echo -e "${RED}❌ 没有找到.so文件进行复制${NC}"
    exit 1
fi

# 显示编译结果总结
echo ""
echo -e "${GREEN}✅ NPU算子动态库编译完成${NC}"
echo -e "${BLUE}📊 编译摘要:${NC}"
echo -e "   FPGA配置: ${YELLOW}$CONFIG_FOR_FPGA${NC}"
echo -e "   调试模式: ${YELLOW}$DEBUG_MODE${NC}" 
echo -e "   仿真输出: ${YELLOW}$SIM_MODE${NC}"
echo -e "   成功库数: ${GREEN}$SUCCESS_COUNT${NC}/${#EXPECTED_LIBS[@]}"
echo -e "   输出目录: $PROJECT_ROOT/c/lib/"
echo -e "   部署目录: $PROJECT_ROOT/python_interface/lib/"

# 显示预处理宏设置
echo ""
echo -e "${BLUE}🏷️  预处理宏:${NC}"
if [[ "$CONFIG_FOR_FPGA" == "on" ]]; then
    echo -e "   ${GREEN}CONFIG_FOR_FPGA=1${NC} (FPGA配置)"
else
    echo -e "   ${YELLOW}CONFIG_FOR_FPGA=0${NC} (仿真配置)"
fi

if [[ "$DEBUG_MODE" == "on" ]]; then
    echo -e "   ${GREEN}DEBUG_MODE=1${NC} (_DEBUG=true)"
else
    echo -e "   ${YELLOW}DEBUG_MODE=0${NC} (_DEBUG=false)"
fi

if [[ "$SIM_MODE" == "on" ]]; then
    echo -e "   ${GREEN}SIM_MODE=1${NC} (SIM=true, 文本输出)"
else
    echo -e "   ${YELLOW}SIM_MODE=0${NC} (SIM=false, 二进制输出)"
fi

echo ""
echo -e "${GREEN}🎯 下一步:${NC}"
echo -e "   cd $PROJECT_ROOT/python_interface"
echo -e "   python test_xx.py  # 运行测试"
echo ""