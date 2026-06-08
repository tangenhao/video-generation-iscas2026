SHELL := /bin/bash
.ONESHELL:
# Makefile for Operator Validation
# Ensure you are in the simulator/op_val directory or adjust PROJECT_ROOT and RUNNER_SCRIPT paths accordingly.

# Infer Project Root (assuming Makefile is in simulator/op_val)
PROJECT_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/../..
OP_VAL_DIR := $(PROJECT_ROOT)/simulator/op_val
RUNNER_SCRIPT := $(OP_VAL_DIR)/run_op_validation.py
RUN_ALL_SCRIPT := $(PROJECT_ROOT)/simulator/op_val/run_all_validations.sh
PYTHON_EXECUTABLE := $(shell which python3 || echo "python3")

# Base output directory for logs and charts from Makefile runs
# This helps distinguish them from direct run_all_validations.sh runs if needed,
# though run_op_validation.py creates its own unique test_name based subdirectories.
BASE_OUTPUT_DIR := $(OP_VAL_DIR)

# Conda environment settings
CONDA_ENV_NAME := cocotb
_CONDA_SETUP_PATH := $(shell conda info --base 2>/dev/null)

# Using semicolons to chain commands for Make. Double dollar signs for Make to pass single dollar to shell.
# Added -e to subshell to exit on error within the activation sequence.
CONDA_ACTIVATE_LINE := echo "Attempting to activate Conda environment: $(CONDA_ENV_NAME)"; \
                        _CONDA_SETUP='$(strip $(_CONDA_SETUP_PATH))'; \
                        if [ -n "$$_CONDA_SETUP" ] && [ -f "$$_CONDA_SETUP/etc/profile.d/conda.sh" ]; then \
                            echo "Sourcing conda.sh from $$_CONDA_SETUP/etc/profile.d/conda.sh"; \
                            source "$$_CONDA_SETUP/etc/profile.d/conda.sh"; \
                        else \
                            echo "Warning: conda.sh not found or _CONDA_SETUP_PATH is empty ('$$_CONDA_SETUP'). Attempting direct activation of $(CONDA_ENV_NAME)."; \
                        fi; \
                        conda activate $(CONDA_ENV_NAME); \
                        if [ $$? -ne 0 ]; then \
                            echo "Critical Error: Failed to activate Conda environment '$(CONDA_ENV_NAME)'. Please check your Conda setup and environment name." && exit 1; \
                        else \
                            echo "Conda environment '$(CONDA_ENV_NAME)' activated successfully for Make target."; \
                        fi

.PHONY: all
.PHONY: clean
.PHONY: clean_all
.PHONY: gemm_fp16
.PHONY: gemm_fp16_test1
.PHONY: gemm_fp16_test2
.PHONY: rmsnorm_fp32
.PHONY: rmsnorm_fp32_test1
.PHONY: rmsnorm_fp32_test2
.PHONY: softmax_fp32
.PHONY: softmax_fp32_test1
.PHONY: softmax_fp32_test2
.PHONY: swish_fp32
.PHONY: swish_fp32_test1
.PHONY: swish_fp32_test2
.PHONY: llama_block
.PHONY: llama_block_test1
.PHONY: llama_block_test2
.PHONY: help

all: gemm_fp16 rmsnorm_fp32 softmax_fp32 swish_fp32 
# @echo "Running all validations via run_all_validations.sh..."
# @bash $(RUN_ALL_SCRIPT)

# --- GEMM FP16 Tests ---
gemm_fp16_test1:
	@echo "----------------------------------------------------"
	@echo "Target: gemm_fp16_test1 (Makefile)"
	@( 
	  TEST_NAME=gemm_fp16_mk_test1;
	  OP_FULL_NAME=gemm_fp16;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running GEMM FP16 Test 1 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type gemm --test_name $${TEST_NAME} --M 64 --K 128 --N 32 --gemm_precision fp16 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for gemm_fp16_test1 available at $${LOG_FILE}" >&2
	)

gemm_fp16_test2:
	@echo "----------------------------------------------------"
	@echo "Target: gemm_fp16_test2 (Makefile)"
	@( 
	  TEST_NAME=gemm_fp16_mk_test2;
	  OP_FULL_NAME=gemm_fp16;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running GEMM FP16 Test 2 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type gemm --test_name $${TEST_NAME} --M 128 --K 256 --N 64 --gemm_precision fp16 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for gemm_fp16_test2 available at $${LOG_FILE}" >&2
	)

gemm_fp16_test3:
	@echo "----------------------------------------------------"
	@echo "Target: gemm_fp16_test3 (Makefile)"
	@( 
	  TEST_NAME=gemm_fp16_mk_test3;
	  OP_FULL_NAME=gemm_fp16;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running $${TEST_NAME} with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type gemm --test_name $${TEST_NAME} --M 256 --K 512 --N 128 --gemm_precision fp16 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for $${TEST_NAME} available at $${LOG_FILE}" >&2
	)


gemm_fp16: gemm_fp16_test1 gemm_fp16_test2

# --- RMSNorm FP32 Tests ---
rmsnorm_fp32_test1:
	@echo "----------------------------------------------------"
	@echo "Target: rmsnorm_fp32_test1 (Makefile)"
	@( 
	  TEST_NAME=rmsnorm_fp32_mk_test1;
	  OP_FULL_NAME=rmsnorm_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running RMSNorm FP32 Test 1 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type rmsnorm --test_name $${TEST_NAME} --seq_len 128 --d_model 256 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for rmsnorm_fp32_test1 available at $${LOG_FILE}" >&2
	)

rmsnorm_fp32_test2:
	@echo "----------------------------------------------------"
	@echo "Target: rmsnorm_fp32_test2 (Makefile)"
	@( 
	  TEST_NAME=rmsnorm_fp32_mk_test2;
	  OP_FULL_NAME=rmsnorm_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running RMSNorm FP32 Test 2 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type rmsnorm --test_name $${TEST_NAME} --seq_len 512 --d_model 256 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for rmsnorm_fp32_test2 available at $${LOG_FILE}" >&2
	)

rmsnorm_fp32: rmsnorm_fp32_test1 rmsnorm_fp32_test2

# --- Softmax FP32 Tests ---
softmax_fp32_test1:
	@echo "----------------------------------------------------"
	@echo "Target: softmax_fp32_test1 (Makefile)"
	@( 
	  TEST_NAME=softmax_fp32_mk_test1;
	  OP_FULL_NAME=softmax_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running Softmax FP32 Test 1 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type softmax --test_name $${TEST_NAME} --oc_group 1 --seq_len 128 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for softmax_fp32_test1 available at $${LOG_FILE}" >&2
	)

softmax_fp32_test2:
	@echo "----------------------------------------------------"
	@echo "Target: softmax_fp32_test2 (Makefile)"
	@( 
	  TEST_NAME=softmax_fp32_mk_test2;
	  OP_FULL_NAME=softmax_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running Softmax FP32 Test 2 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type softmax --test_name $${TEST_NAME} --oc_group 4 --seq_len 128 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for softmax_fp32_test2 available at $${LOG_FILE}" >&2
	)

softmax_fp32_test3:
	@echo "----------------------------------------------------"
	@echo "Target: softmax_fp32_test3 (Makefile)"
	@( 
	  TEST_NAME=softmax_fp32_mk_test3;
	  OP_FULL_NAME=softmax_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running Softmax FP32 Test 3 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type softmax --test_name $${TEST_NAME} --oc_group 4 --seq_len 64 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for softmax_fp32_test3 available at $${LOG_FILE}" >&2
	)

softmax_fp32: softmax_fp32_test1 softmax_fp32_test2 softmax_fp32_test3

# --- Swish FP32 Tests ---
swish_fp32_test1:
	@echo "----------------------------------------------------"
	@echo "Target: swish_fp32_test1 (Makefile)"
	@( 
	  TEST_NAME=swish_fp32_mk_test1;
	  OP_FULL_NAME=swish_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running Swish FP32 Test 1 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type swish --test_name $${TEST_NAME} --oc_group 2 --num_data 1024 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for swish_fp32_test1 available at $${LOG_FILE}" >&2
	)

swish_fp32_test2:
	@echo "----------------------------------------------------"
	@echo "Target: swish_fp32_test2 (Makefile)"
	@( 
	  TEST_NAME=swish_fp32_mk_test2;
	  OP_FULL_NAME=swish_fp32;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running Swish FP32 Test 2 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type swish --test_name $${TEST_NAME} --oc_group 4 --num_data 1024 --oc_group_size 32 --project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) > $${LOG_FILE} 2>&1;
	  echo "Log file for swish_fp32_test2 available at $${LOG_FILE}" >&2
	)

swish_fp32: swish_fp32_test1 swish_fp32_test2

# --- LLaMA Block Tests ---
llama_block_test1:
	@echo "----------------------------------------------------"
	@echo "Target: llama_block_test1 (Makefile)"
	@( 
	  TEST_NAME=llama_block_mk_test1;
	  OP_FULL_NAME=llama_block;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running LLaMA Block Test 1 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type llama_block --test_name $${TEST_NAME} \
		--seq_len 64 --d_model 128 --intermediate_size 128 --head_num 2 --rmsnorm_eps 1e-6 \
		--project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) \
		--enable_outlier_analysis --outlier_abs_threshold 1e-2 --outlier_rel_threshold 0.2 \
		> $${LOG_FILE} 2>&1;
	  echo "Log file for llama_block_test1 available at $${LOG_FILE}" >&2
	)

llama_block_test2:
	@echo "----------------------------------------------------"
	@echo "Target: llama_block_test2 (Makefile)"
	@( 
	  TEST_NAME=llama_block_mk_test2;
	  OP_FULL_NAME=llama_block;
	  LOG_DIR=$(BASE_OUTPUT_DIR)/$${OP_FULL_NAME}/results/$${TEST_NAME};
	  LOG_FILE=$${LOG_DIR}/$${TEST_NAME}_make.log;
	  echo "Logging to $${LOG_FILE}";
	  mkdir -p $${LOG_DIR};
	  $(CONDA_ACTIVATE_LINE);
	  echo "Running LLaMA Block Test 2 with python3 from Conda env ($(CONDA_ENV_NAME))..." >&2;
	  python3 $(RUNNER_SCRIPT) --op_type llama_block --test_name $${TEST_NAME} \
	  	--seq_len 128 --d_model 512 --intermediate_size 512 --head_num 4 --rmsnorm_eps 1e-6 \
		--project_root $(PROJECT_ROOT) --base_output_dir $(BASE_OUTPUT_DIR) \
		--enable_outlier_analysis --outlier_abs_threshold 1e-2 --outlier_rel_threshold 0.2 \
		> $${LOG_FILE} 2>&1;
	  echo "Log file for llama_block_test2 available at $${LOG_FILE}" >&2
	)

llama_block: llama_block_test1 llama_block_test2

# --- Clean targets ---
# These clean targets remove the *results* directories generated by tests.
# They are operator-specific to avoid accidentally deleting unrelated data.

CLEAN_DIRS := $(wildcard $(OP_VAL_DIR)/gemm_fp16/results/*_mk_test*) \
              $(wildcard $(OP_VAL_DIR)/rmsnorm_fp32/results/*_mk_test*) \
              $(wildcard $(OP_VAL_DIR)/softmax_fp32/results/*_mk_test*) \
              $(wildcard $(OP_VAL_DIR)/swish_fp32/results/*_mk_test*)

# Clean results from Makefile-specific test names
clean:
	@echo "Cleaning results generated by Makefile tests (*_mk_test*)..."
	@if [ -n "$(CLEAN_DIRS)" ]; then \
	    rm -rf $(CLEAN_DIRS); \
	    echo "Removed directories: $(CLEAN_DIRS)"; \
	else \
	    echo "No Makefile-specific test result directories found to clean."; \
	fi

# Clean all results (including those from run_all_validations.sh if patterns match)
# This is more aggressive.
CLEAN_ALL_DIRS := $(wildcard $(OP_VAL_DIR)/*/results/*)
clean_all:
	@echo "Cleaning all test result directories..."
	@if [ -n "$(CLEAN_ALL_DIRS)" ]; then \
	    rm -rf $(CLEAN_ALL_DIRS); \
	    echo "Removed directories: $(CLEAN_ALL_DIRS)"; \
	else \
	    echo "No test result directories found to clean."; \
	fi

help:
	@echo "Operator Validation Makefile"
	@echo "----------------------------"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Main targets:"
	@echo "  all                - Run all validation tests via run_all_validations.sh"
	@echo "  clean              - Clean results generated by Makefile specific tests (test_name suffix '_mk_test*')"
	@echo "  clean_all          - Clean all results from all test runs in simulator/op_val/*_fp*/results/"
	@echo ""
	@echo "Operator group targets (run all tests for the operator defined in this Makefile):"
	@echo "  gemm_fp16          - Run all GEMM FP16 tests"
	@echo "  rmsnorm_fp32       - Run all RMSNorm FP32 tests"
	@echo "  softmax_fp32       - Run all Softmax FP32 tests"
	@echo "  swish_fp32         - Run all Swish FP32 tests"
	@echo "  llama_block        - Run all LLaMA Block tests"
	@echo ""
	@echo "Individual test targets (example):"
	@echo "  gemm_fp16_test1    - Run specific GEMM FP16 test 1"
	@echo "  softmax_fp32_test2 - Run specific Softmax FP32 test 2"
	@echo ""
	@echo "Outlier Analysis Support:"
	@echo "  Add --enable_outlier_analysis to any test for detailed outlier detection"
	@echo "  Customize thresholds with --outlier_abs_threshold <value> --outlier_rel_threshold <value>"
	@echo "  Examples:"
	@echo "    make gemm_outlier_test   - GEMM test with outlier analysis enabled"
	@echo "    make softmax_outlier_test - Softmax test with outlier analysis enabled"
	@echo ""
	@echo "Note: For Makefile individual/group targets, test names will have a '_mk_' prefix (e.g., gemm_fp16_mk_test1)"
	@echo "      to differentiate their output folders from run_all_validations.sh outputs if parameters are identical."
	@echo "      The run_all_validations.sh script manages its own log files within its test name structure." 