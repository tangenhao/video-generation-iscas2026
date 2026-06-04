#!/bin/bash

# 尝试激活 Conda 环境
CONDA_ENV_NAME="cocotb" # 请确认这是正确的环境名称
if command -v conda &> /dev/null; then
    echo "Attempting to activate Conda environment: ${CONDA_ENV_NAME}"
    # shellcheck disable=SC1090 # 在某些系统中，conda.sh 可能不在标准路径
    # 首先尝试找到 conda.sh 以正确初始化 conda
    _CONDA_SETUP=$(conda info --base 2>/dev/null || true)
    if [ -n "$_CONDA_SETUP" ] && [ -f "$_CONDA_SETUP/etc/profile.d/conda.sh" ]; then
        # shellcheck source=/dev/null
        source "$_CONDA_SETUP/etc/profile.d/conda.sh"
    else
        echo "Warning: conda.sh not found, attempting direct activation."
    fi
    
    conda activate "${CONDA_ENV_NAME}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to activate Conda environment '${CONDA_ENV_NAME}'."
        echo "Please ensure the environment exists and conda is configured correctly."
        # exit 1 # 先不退出，让脚本尝试使用系统 python
    else
        echo "Conda environment '${CONDA_ENV_NAME}' activated successfully."
    fi
else
    echo "Warning: conda command not found. Skipping Conda activation."
fi

# 推断项目根目录 (假定此脚本在项目根目录下执行)
PROJECT_ROOT=$(pwd)/../../
echo "Project Root determined as: ${PROJECT_ROOT}"

# 将项目内的 C++ 库路径添加到 LD_LIBRARY_PATH
PROJECT_C_LIB_DIR="${PROJECT_ROOT}/c/lib"
if [ -d "${PROJECT_C_LIB_DIR}" ]; then
    export LD_LIBRARY_PATH="${PROJECT_C_LIB_DIR}:${LD_LIBRARY_PATH}"
    echo "Added ${PROJECT_C_LIB_DIR} to LD_LIBRARY_PATH. Current LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
else
    echo "Warning: Project C++ library directory ${PROJECT_C_LIB_DIR} not found."
fi

# simulator/op_val 目录的路径
OP_VAL_DIR="${PROJECT_ROOT}/simulator/op_val"
RUNNER_SCRIPT="${OP_VAL_DIR}/run_op_validation.py"

# C++ 可执行文件目录
CPP_EXE_DIR="${PROJECT_ROOT}/c/exe"

# Python 可执行文件
PYTHON_EXECUTABLE=$(which python3 || echo "python3")

# 检查 runner 脚本是否存在
if [ ! -f "${RUNNER_SCRIPT}" ]; then
    echo "Error: Runner script not found at ${RUNNER_SCRIPT}"
    exit 1
fi

if ! command -v "${PYTHON_EXECUTABLE}" &> /dev/null; then
    echo "Error: Python executable '${PYTHON_EXECUTABLE}' not found. Please ensure Python 3 is installed and in your PATH."
    exit 1
fi
echo "Using Python executable: ${PYTHON_EXECUTABLE}"

# 检查 C++ 可执行文件
echo "Checking for C++ executables..."
cpp_exes=("gemm_sim" "rmsnorm_sim" "softmax_sim" "swish_sim" "llama_block_sim")
all_exes_found=true
for exe_name in "${cpp_exes[@]}"; do
    if [ ! -x "${CPP_EXE_DIR}/${exe_name}" ]; then
        echo "Error: C++ executable not found or not executable: ${CPP_EXE_DIR}/${exe_name}"
        all_exes_found=false
    fi
done

if [ "$all_exes_found" = false ]; then
    echo "One or more C++ executables are missing. Please build them first."
    exit 1
else
    echo "All C++ executables found."
fi

echo -e "\nStarting All Operator Validations (excluding GEMM FP32)..."

# --- Helper function to run a test ---
run_test() {
    local op_type=$1
    local test_name=$2
    local op_dir_suffix=$3 # e.g., fp16 for gemm_fp16, fp32 for others, but "llama_block" for llama_block
    shift 3 # Remove op_type, test_name, op_dir_suffix from args
    local params=("$@")

    echo -e "\n---------------------------------------"
    echo "Running ${op_type^^} ${op_dir_suffix^^} Test: ${test_name}"
    echo "---------------------------------------"

    # Special handling for llama_block: use just "llama_block" as directory name
    if [ "$op_type" == "llama_block" ]; then
        local log_dir="${OP_VAL_DIR}/llama_block/results/${test_name}"
    else
        local log_dir="${OP_VAL_DIR}/${op_type}_${op_dir_suffix}/results/${test_name}"
    fi
    mkdir -p "${log_dir}"
    local log_file="${log_dir}/run.log"
    
    echo "Logging to ${log_file}"
    > "${log_file}" # Create/truncate log file

    "${PYTHON_EXECUTABLE}" "${RUNNER_SCRIPT}" \
        --op_type "${op_type}" \
        --test_name "${test_name}" \
        "${params[@]}" \
        --project_root "${PROJECT_ROOT}" \
        --base_output_dir "${OP_VAL_DIR}" > "${log_file}" 2>&1
    
    local exit_code=$?
    # echo "Python script exit code: ${exit_code}" # Optional: keep for debugging if needed

    if [ ! -f "${log_file}" ]; then
        echo "Critical Error: Log file ${log_file} was NOT created." >&2
    elif [ ! -s "${log_file}" ]; then
        echo "Warning: Log file ${log_file} was created but is EMPTY (Python script likely failed before producing output). Exit code: ${exit_code}" >&2
    # else
        # echo "Log file ${log_file} exists and is not empty." # Optional
    fi

    if [ ${exit_code} -ne 0 ]; then
        echo "Error: ${op_type^^} ${op_dir_suffix^^} Test ${test_name} FAILED. Python exit code: ${exit_code}. Check log: ${log_file}"
    else
        echo "${op_type^^} ${op_dir_suffix^^} Test ${test_name} COMPLETED. Python exit code: ${exit_code}. Log: ${log_file}"
    fi
}

# --- GEMM FP16 Tests ---
run_test gemm "gemm_fp16_test1" "fp16" --M 64 --K 128 --N 32 --gemm_precision fp16
run_test gemm "gemm_fp16_test2" "fp16" --M 128 --K 256 --N 64 --gemm_precision fp16

# --- RMSNorm FP32 Tests ---
run_test rmsnorm "rmsnorm_fp32_test1" "fp32" --seq_len 128 --d_model 256 --oc_group_size 64
run_test rmsnorm "rmsnorm_fp32_test2" "fp32" --seq_len 512 --d_model 1024 --oc_group_size 128

# --- Softmax FP32 Tests ---
run_test softmax "softmax_fp32_test1" "fp32" --oc_group 4 --seq_len 256 --oc_group_size 512
run_test softmax "softmax_fp32_test2" "fp32" --oc_group 8 --seq_len 128 --oc_group_size 256

# --- Swish FP32 Tests ---
run_test swish "swish_fp32_test1" "fp32" --oc_group 2 --num_data 1024 --oc_group_size 256
run_test swish "swish_fp32_test2" "fp32" --oc_group 4 --num_data 2048 --oc_group_size 512

# --- LLaMA Block Tests ---
run_test llama_block "llama_block_test1" "fp32" --seq_len 512 --d_model 4096 --intermediate_size 11008 --head_num 32 --rmsnorm_eps 1e-6
run_test llama_block "llama_block_test2" "fp32" --seq_len 1024 --d_model 2048 --intermediate_size 5504 --head_num 16 --rmsnorm_eps 1e-6

echo -e "\n\n---------------------------------------"
echo "All Validations Finished."
echo "Please check the respective run.log files in each operator's results directory."
echo "---------------------------------------"
