import argparse
import os
import subprocess
import sys
import shutil

# Ensure common_utils is in path if this script is run from op_val
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), 'common_utils')))

# Path to the data_gen.py script itself
DATA_GEN_SCRIPT_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "common_utils", "data_gen.py"))

# --- Configuration: Paths to executables and scripts ---
# These might need adjustment based on your build system and where executables are placed.
# Assuming executables are in a standard build location relative to the project root.
# The script will try to determine project root based on its own location.

def get_project_root():
    """Determines the project root directory."""
    # Assuming this script is in simulator/op_val/
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # Project root is ../../ from current_dir
    project_root = os.path.abspath(os.path.join(current_dir, "..", ".."))
    return project_root

def get_cpp_exe_path(op_name: str, project_root: str):
    """Constructs the path to the C++ simulator executable."""
    # Example: project_root/c/exe/gemm_sim
    return os.path.join(project_root, "c", "exe", f"{op_name}_sim")

def get_pytorch_script_path(op_name: str, precision: str):
    """Constructs the path to the PyTorch reference script."""
    if op_name == "gemm":
        # GEMM PyTorch script is in gemm_fp16 and handles both precisions
        script_dir = os.path.join(os.path.dirname(__file__), "gemm_fp16", "pytorch_ref")
    elif op_name == "llama_block":
        # LLaMA Block PyTorch script is in llama_block directory
        script_dir = os.path.join(os.path.dirname(__file__), "llama_block", "pytorch_ref")
    else:
        # Other ops have precision-specific directories (e.g., rmsnorm_fp32)
        script_dir = os.path.join(os.path.dirname(__file__), f"{op_name}_{precision}", "pytorch_ref")
    return os.path.join(script_dir, f"{op_name}_pytorch.py")

def get_compare_script_path(op_name: str, precision: str):
    """Constructs the path to the comparison script."""
    if op_name == "gemm":
        # GEMM comparison script is in gemm_fp16
        script_dir = os.path.join(os.path.dirname(__file__), "gemm_fp16")
    elif op_name == "llama_block":
        # LLaMA Block comparison script is in llama_block directory
        script_dir = os.path.join(os.path.dirname(__file__), "llama_block")
    else:
        script_dir = os.path.join(os.path.dirname(__file__), f"{op_name}_{precision}")
    return os.path.join(script_dir, f"compare_{op_name}_outputs.py")


def run_command(command: list, cwd: str = None, desc: str = ""):
    """Helper to run a shell command and print its output."""
    if desc:
        print(f"\n--- Running: {desc} ---", flush=True)
    print(f"Executing: {' '.join(command)}", flush=True)
    if cwd:
        print(f"In CWD: {cwd}", flush=True)
    
    try:
        process = subprocess.run(command, capture_output=True, text=True, check=False, cwd=cwd)
        
        if process.stdout:
            print("Stdout:", flush=True)
            print(process.stdout, flush=True)
        if process.stderr:
            print("Stderr:", flush=True)
            print(process.stderr, flush=True)
        
        if process.returncode != 0:
            error_message = f"Error: Command {' '.join(command)} failed with exit code {process.returncode}"
            print(error_message, flush=True)
            # sys.exit(process.returncode) # Exit immediately on failure
            raise subprocess.CalledProcessError(process.returncode, command, output=process.stdout, stderr=process.stderr)
        print(f"{desc} completed successfully.", flush=True)
        return process
    except FileNotFoundError as e:
        print(f"Critical Error: Executable or script not found for command: {' '.join(command)}. Details: {e}", flush=True)
        # Make sure this critical error is propagated
        raise # Re-raise the FileNotFoundError to be caught by the main try-except in main()
    except Exception as e:
        print(f"Critical Error during command execution: {' '.join(command)}. Details: {e}", flush=True)
        # Propagate other critical errors
        raise # Re-raise the exception

def main():
    print("--- run_op_validation.py main() started ---", flush=True)
    parser = argparse.ArgumentParser(description="Run operator validation for GEMM, RMSNorm, Softmax, or Swish.")
    parser.add_argument("--op_type", type=str, required=True,         choices=["gemm", "rmsnorm", "softmax", "swish", "llama_block"], help="Operator type to validate.")
    parser.add_argument("--test_name", type=str, default="default_test", help="Name for this test run, used for subdirectories.")
    parser.add_argument("--base_output_dir", type=str, default=os.path.dirname(__file__), help="Base directory for operator outputs (e.g., simulator/op_val/). Test-specific subdirectories will be created here.")
    parser.add_argument("--project_root", type=str, default=get_project_root(), help="Path to the project root directory.")
    
    # Common dimension args (not all used by all ops)
    parser.add_argument("--M", type=int, help="M dimension (for GEMM)")
    parser.add_argument("--K", type=int, help="K dimension (for GEMM)")
    parser.add_argument("--N", type=int, help="N dimension (for GEMM)")
    
    parser.add_argument("--oc_group", type=int, help="oc_group dimension (batch-like, for RMSNorm, Softmax, Swish)")
    parser.add_argument("--num_data", type=int, help="Number of data elements, e.g. H*W or seq_len (for Swish)")
    parser.add_argument("--oc_group_size", type=int, help="oc_group_size dimension (feature dim per group, for RMSNorm, Softmax, Swish)")

    parser.add_argument("--gemm_precision", type=str, choices=["fp16", "fp32"], default="fp16", help="Precision for GEMM (fp16 or fp32). Other ops are FP32 by default.")
    parser.add_argument("--rmsnorm_epsilon", type=float, default=1e-5, help="Epsilon for RMSNorm.")
    
    # LLaMA Block specific arguments
    parser.add_argument("--seq_len", type=int, help="Sequence length")
    parser.add_argument("--d_model", type=int, help="Model dimension")
    parser.add_argument("--intermediate_size", type=int, help="Intermediate size for LLaMA Block MLP")
    parser.add_argument("--head_num", type=int, help="Number of attention heads for LLaMA Block")
    parser.add_argument("--rmsnorm_eps", type=float, default=1e-6, help="RMSNorm epsilon for LLaMA Block")
    
    parser.add_argument("--compare_epsilon", type=float, default=1e-5, help="Epsilon for relative error in comparison scripts.")

    parser.add_argument("--skip_data_gen", action="store_true", help="Skip data generation step.")
    parser.add_argument("--skip_pytorch_ref", action="store_true", help="Skip PyTorch reference generation step.")
    parser.add_argument("--skip_cpp_sim", action="store_true", help="Skip C++ simulation step.")
    parser.add_argument("--skip_compare", action="store_true", help="Skip comparison step.")
    parser.add_argument("--enable_outlier_analysis", action="store_true", help="Enable outlier analysis and visualization")
    parser.add_argument("--outlier_abs_threshold", type=float, default=None, help="Absolute error threshold for outlier detection")
    parser.add_argument("--outlier_rel_threshold", type=float, default=None, help="Relative error threshold for outlier detection")
    
    args = parser.parse_args()

    try:
        print(f"Parsed arguments: {args}", flush=True)

        # --- Setup paths and directories ---
        # Special handling for llama_block: always use "llama_block" instead of "llama_block_fp32"
        if args.op_type == "llama_block":
            op_full_name = "llama_block"
            op_precision = "fp16"  # llama_block uses fp16 precision
        else:
            op_precision = args.gemm_precision if args.op_type == "gemm" else "fp32"
            op_full_name = f"{args.op_type}_{op_precision}" # e.g., gemm_fp16 or softmax_fp32
        print(f"Determined op_full_name: {op_full_name}", flush=True)

        # Test-specific output directory for this run
        current_op_base_dir = os.path.join(args.base_output_dir, op_full_name)
        test_run_dir = os.path.join(current_op_base_dir, "results", args.test_name)
        
        test_data_dir = os.path.join(test_run_dir, "data")
        test_charts_dir = os.path.join(test_run_dir, "charts")
        # Define paths for JSON outputs
        pytorch_perf_json_path = os.path.join(test_run_dir, "pytorch_performance.json")
        accuracy_json_path = os.path.join(test_run_dir, "accuracy.json")

        print(f"--- Starting Operator Validation for: {op_full_name} ---", flush=True)
        print(f"Test Name: {args.test_name}", flush=True)
        print(f"Project Root: {args.project_root}", flush=True)
        print(f"Base Output Dir (from args): {args.base_output_dir}", flush=True)
        print(f"Operator Base Directory (calculated): {current_op_base_dir}", flush=True)
        print(f"Test Run Directory (outputs here): {test_run_dir}", flush=True)
        print(f"  - Data Subdirectory: {test_data_dir}", flush=True)
        print(f"  - Charts Subdirectory: {test_charts_dir}", flush=True)

        # Clean and create directories for the current test run
        # The parent test_run_dir (e.g., .../results/gemm_fp16_test1) is created by the calling script (run_all_validations.sh)
        # or should be created if called directly (e.g. by Makefile)
        # and contains the log file. DO NOT delete test_run_dir here if it only contains a log.
        # Instead, clean/create subdirectories data and charts.
        
        print(f"Ensuring test run directory exists: {test_run_dir}", flush=True)
        os.makedirs(test_run_dir, exist_ok=True)

        if os.path.exists(test_data_dir):
            print(f"Cleaning up existing data directory: {test_data_dir}", flush=True)
            shutil.rmtree(test_data_dir)
        # if os.path.exists(test_run_dir): # OLD LOGIC
        #     print(f"Cleaning up existing test run directory: {test_run_dir}", flush=True)
        #     shutil.rmtree(test_run_dir)
        
        print(f"Creating directory: {test_data_dir}", flush=True)
        os.makedirs(test_data_dir, exist_ok=True)
        
        if os.path.exists(test_charts_dir):
            print(f"Cleaning up existing charts directory: {test_charts_dir}", flush=True)
            shutil.rmtree(test_charts_dir)
        print(f"Creating directory: {test_charts_dir}", flush=True)
        os.makedirs(test_charts_dir, exist_ok=True)
        
        # Paths for generated files (will be inside test_data_dir)
        # These need to be constructed based on op_type and its specific file naming conventions.
        # For now, these are placeholder names, actual names will be derived from op-specific logic.
        input_file_generic_name = "input.bin" # Placeholder, will be more specific
        ifmap_file_name = "ifmap.bin"
        weight_file_name = "weight.bin"
        gamma_file_name = "gamma.bin"
        
        ref_output_file_name = "ref_output.bin" # Placeholder
        cpp_output_file_name = "cpp_output.bin" # Placeholder
        
        # --- Step 1: Data Generation ---
        if not args.skip_data_gen:
            cmd_data_gen = ["python3", DATA_GEN_SCRIPT_PATH]
            cmd_data_gen.extend(["--op_type", args.op_type])
            
            default_data_gen_output_base = os.path.join(args.base_output_dir, op_full_name, "data")
            
            # Handle special case for llama_block which saves to llama_block/data 
            if args.op_type == "llama_block":
                actual_data_gen_output_base = os.path.join(args.base_output_dir, "llama_block", "data")
            else:
                actual_data_gen_output_base = default_data_gen_output_base
            
            if os.path.exists(actual_data_gen_output_base):
                print(f"Cleaning default data gen location: {actual_data_gen_output_base}")
                shutil.rmtree(actual_data_gen_output_base)
            os.makedirs(actual_data_gen_output_base, exist_ok=True)

            input_path = "" # Initialize to satisfy linter, will be set in op-specific block
            ifmap_path = "" # for gemm
            weight_path = "" # for gemm
            gamma_path = "" # for rmsnorm
            ref_output_path = "" # for single precision ref ops
            ref_output_path_fp16 = "" # for gemm
            ref_output_path_fp32 = "" # for gemm
            cpp_output_path = ""

            if args.op_type == "gemm":
                if not all([args.M, args.K, args.N]):
                    parser.error("M, K, N are required for GEMM.")
                cmd_data_gen.extend([
                    "--gemm_m", str(args.M), "--gemm_k", str(args.K), "--gemm_n", str(args.N),
                    "--gemm_precision", args.gemm_precision
                ])
                generated_ifmap_path_default = os.path.join(default_data_gen_output_base, f"ifmap_m{args.M}_k{args.K}.bin")
                generated_weight_path_default = os.path.join(default_data_gen_output_base, f"weight_k{args.K}_n{args.N}.bin")
                
                ifmap_path = os.path.join(test_data_dir, f"ifmap_m{args.M}_k{args.K}.bin")
                weight_path = os.path.join(test_data_dir, f"weight_k{args.K}_n{args.N}.bin")
                ref_output_path_fp16 = os.path.join(test_data_dir, f"ref_gemm_fp16_m{args.M}_k{args.K}_n{args.N}.bin")
                ref_output_path_fp32 = os.path.join(test_data_dir, f"ref_gemm_fp32_m{args.M}_k{args.K}_n{args.N}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_gemm_{args.gemm_precision}_m{args.M}_k{args.K}_n{args.N}.bin")

            elif args.op_type == "rmsnorm":
                if not all([args.d_model, args.seq_len, args.oc_group_size]):
                    parser.error("d_model, seq_len, oc_group_size are required for RMSNorm.")
                if args.d_model % args.oc_group_size != 0:
                    parser.error("d_model must be divisible by oc_group_size for RMSNorm.")
                calculated_oc_group = args.d_model // args.oc_group_size
                cmd_data_gen.extend([
                    "--rmsnorm_oc_group", str(calculated_oc_group), 
                    "--rmsnorm_seq_len", str(args.seq_len),
                    "--rmsnorm_ogs", str(args.oc_group_size)
                ])
                generated_input_path_default = os.path.join(default_data_gen_output_base, f"input_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")
                generated_gamma_path_default = os.path.join(default_data_gen_output_base, f"gamma_d{args.d_model}.bin")

                input_path = os.path.join(test_data_dir, f"input_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")
                gamma_path = os.path.join(test_data_dir, f"gamma_d{args.d_model}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_rmsnorm_fp32_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_rmsnorm_fp32_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")

            elif args.op_type == "softmax":
                if not all([args.oc_group, args.seq_len, args.oc_group_size]):
                    parser.error("oc_group, seq_len, oc_group_size are required for Softmax.")
                cmd_data_gen.extend([
                    "--softmax_oc_group", str(args.oc_group),
                    "--softmax_seq_len", str(args.seq_len),
                    "--softmax_ogs", str(args.oc_group_size)
                ])
                dims_suffix_softmax = f"_g{args.oc_group}_s{args.seq_len}_ogs{args.oc_group_size}"
                generated_input_path_default = os.path.join(default_data_gen_output_base, f"input{dims_suffix_softmax}.bin")
                
                input_path = os.path.join(test_data_dir, f"input{dims_suffix_softmax}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_softmax_fp32{dims_suffix_softmax}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_softmax_fp32{dims_suffix_softmax}.bin")

            elif args.op_type == "swish":
                if not all([args.oc_group, args.num_data, args.oc_group_size]):
                    parser.error("oc_group, num_data, oc_group_size are required for Swish.")
                cmd_data_gen.extend([
                    "--swish_oc_group", str(args.oc_group),
                    "--swish_num_data", str(args.num_data),
                    "--swish_ogs", str(args.oc_group_size)
                ])
                dims_suffix_swish = f"_g{args.oc_group}_n{args.num_data}_ogs{args.oc_group_size}"
                generated_input_path_default = os.path.join(default_data_gen_output_base, f"input{dims_suffix_swish}.bin")
                
                input_path = os.path.join(test_data_dir, f"input{dims_suffix_swish}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_swish_fp32{dims_suffix_swish}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_swish_fp32{dims_suffix_swish}.bin")

            elif args.op_type == "llama_block":
                if not all([args.seq_len, args.d_model, args.intermediate_size, args.head_num]):
                    parser.error("seq_len, d_model, intermediate_size, head_num are required for LLaMA Block.")
                cmd_data_gen.extend([
                    "--llama_seq_len", str(args.seq_len),
                    "--llama_d_model", str(args.d_model),
                    "--llama_intermediate_size", str(args.intermediate_size),
                    "--llama_head_num", str(args.head_num)
                ])
                dims_suffix_llama = f"_s{args.seq_len}_d{args.d_model}_i{args.intermediate_size}_h{args.head_num}"
                # data_gen.py saves to llama_block/data
                data_gen_output_dir = os.path.join(args.base_output_dir, "llama_block", "data")
                generated_input_path_default = os.path.join(data_gen_output_dir, f"input{dims_suffix_llama}.bin")
                
                input_path = os.path.join(test_data_dir, f"input{dims_suffix_llama}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_llama_block{dims_suffix_llama}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_llama_block{dims_suffix_llama}.bin")

            else:
                print(f"Operator type {args.op_type} data generation path logic not fully implemented in runner yet.")
                sys.exit(1)

            try:
                run_command(cmd_data_gen, desc="Data Generation")
                
                print(f"Moving generated data from {default_data_gen_output_base} to {test_data_dir}", flush=True)
                if args.op_type == "gemm":
                    shutil.move(generated_ifmap_path_default, ifmap_path)
                    shutil.move(generated_weight_path_default, weight_path)
                elif args.op_type == "rmsnorm":
                    shutil.move(generated_input_path_default, input_path)
                    shutil.move(generated_gamma_path_default, gamma_path)
                elif args.op_type == "softmax":
                    shutil.move(generated_input_path_default, input_path)
                elif args.op_type == "swish":
                    shutil.move(generated_input_path_default, input_path)
                elif args.op_type == "llama_block":
                    # Move all generated files from llama_block/data to test_data_dir
                    shutil.move(generated_input_path_default, input_path)
                    # Move all weight files
                    shutil.move(os.path.join(data_gen_output_dir, f"attn_norm_gamma{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"attn_norm_gamma{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"ffn_norm_gamma{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"ffn_norm_gamma{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"query_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"query_weight{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"key_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"key_weight{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"value_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"value_weight{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"output_proj_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"output_proj_weight{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"gate_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"gate_weight{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"up_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"up_weight{dims_suffix_llama}.bin"))
                    shutil.move(os.path.join(data_gen_output_dir, f"down_weight{dims_suffix_llama}.bin"), 
                               os.path.join(test_data_dir, f"down_weight{dims_suffix_llama}.bin"))

            except subprocess.CalledProcessError:
                print("Failed during data generation. Exiting.", flush=True)
                sys.exit(1)
            except FileNotFoundError:
                print("Failed during data generation (FileNotFound). Exiting.", flush=True)
                sys.exit(1)
        else:
            print("Skipping data generation.")
            # Define paths if skipping, assuming they exist in test_data_dir
            if args.op_type == "gemm":
                ifmap_path = os.path.join(test_data_dir, f"ifmap_m{args.M}_k{args.K}.bin")
                weight_path = os.path.join(test_data_dir, f"weight_k{args.K}_n{args.N}.bin")
                ref_output_path_fp16 = os.path.join(test_data_dir, f"ref_gemm_fp16_m{args.M}_k{args.K}_n{args.N}.bin")
                ref_output_path_fp32 = os.path.join(test_data_dir, f"ref_gemm_fp32_m{args.M}_k{args.K}_n{args.N}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_gemm_{args.gemm_precision}_m{args.M}_k{args.K}_n{args.N}.bin")
            elif args.op_type == "rmsnorm":
                calculated_oc_group = args.d_model // args.oc_group_size
                input_path = os.path.join(test_data_dir, f"input_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")
                gamma_path = os.path.join(test_data_dir, f"gamma_d{args.d_model}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_rmsnorm_fp32_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_rmsnorm_fp32_g{calculated_oc_group}_s{args.seq_len}_ogs{args.oc_group_size}.bin")
            elif args.op_type == "softmax":
                dims_suffix_softmax = f"_g{args.oc_group}_s{args.seq_len}_ogs{args.oc_group_size}"
                input_path = os.path.join(test_data_dir, f"input{dims_suffix_softmax}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_softmax_fp32{dims_suffix_softmax}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_softmax_fp32{dims_suffix_softmax}.bin")
            elif args.op_type == "swish":
                dims_suffix_swish = f"_g{args.oc_group}_n{args.num_data}_ogs{args.oc_group_size}"
                input_path = os.path.join(test_data_dir, f"input{dims_suffix_swish}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_swish_fp32{dims_suffix_swish}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_swish_fp32{dims_suffix_swish}.bin")
            elif args.op_type == "llama_block":
                dims_suffix_llama = f"_s{args.seq_len}_d{args.d_model}_i{args.intermediate_size}_h{args.head_num}"
                input_path = os.path.join(test_data_dir, f"input{dims_suffix_llama}.bin")
                ref_output_path = os.path.join(test_data_dir, f"ref_llama_block{dims_suffix_llama}.bin")
                cpp_output_path = os.path.join(test_data_dir, f"cpp_llama_block{dims_suffix_llama}.bin")

        # --- Step 2: PyTorch Reference ---
        if not args.skip_pytorch_ref:
            pytorch_script = get_pytorch_script_path(args.op_type, op_precision)
            if not os.path.exists(pytorch_script):
                print(f"Error: PyTorch script not found: {pytorch_script}"); sys.exit(1)
            
            cmd_pytorch = ["python3", pytorch_script]
            if args.op_type == "gemm":
                cmd_pytorch.extend([
                    "--M", str(args.M), "--K", str(args.K), "--N", str(args.N),
                    "--ifmap_path", ifmap_path, "--weight_path", weight_path,
                ])
                if args.gemm_precision == "fp16":
                     cmd_pytorch.extend([
                         "--precision", "fp16", 
                         "--output_path_fp16", ref_output_path_fp16,
                         "--output_performance_json", pytorch_perf_json_path
                     ])
                elif args.gemm_precision == "fp32": 
                    cmd_pytorch.extend([
                        "--precision", "fp32", 
                        "--output_path_fp32", ref_output_path_fp32,
                        "--output_performance_json", pytorch_perf_json_path
                    ])
            
            elif args.op_type == "rmsnorm":
                cmd_pytorch.extend([
                    "--seq_len", str(args.seq_len), "--d_model", str(args.d_model),
                    "--oc_group_size", str(args.oc_group_size), "--epsilon", str(args.rmsnorm_epsilon),
                    "--input_path", input_path, "--gamma_path", gamma_path,
                    "--output_path", ref_output_path,
                    "--output_performance_json", pytorch_perf_json_path
                ])
            elif args.op_type == "softmax":
                cmd_pytorch.extend([
                    "--oc_group", str(args.oc_group), "--seq_len", str(args.seq_len),
                    "--oc_group_size", str(args.oc_group_size),
                    "--input_path", input_path, "--output_path", ref_output_path,
                    "--output_performance_json", pytorch_perf_json_path
                ])
            elif args.op_type == "swish":
                cmd_pytorch.extend([
                    "--oc_group", str(args.oc_group), "--num_data", str(args.num_data),
                    "--oc_group_size", str(args.oc_group_size),
                    "--input_path", input_path, "--output_path", ref_output_path,
                    "--output_performance_json", pytorch_perf_json_path
                ])
            elif args.op_type == "llama_block":
                # Need to pass all weight file paths as well
                dims_suffix_llama = f"_s{args.seq_len}_d{args.d_model}_i{args.intermediate_size}_h{args.head_num}"
                
                # Paths to weight files generated by data_gen.py
                attn_norm_gamma_path = os.path.join(test_data_dir, f"attn_norm_gamma{dims_suffix_llama}.bin")
                ffn_norm_gamma_path = os.path.join(test_data_dir, f"ffn_norm_gamma{dims_suffix_llama}.bin")
                query_weight_path = os.path.join(test_data_dir, f"query_weight{dims_suffix_llama}.bin")
                key_weight_path = os.path.join(test_data_dir, f"key_weight{dims_suffix_llama}.bin")
                value_weight_path = os.path.join(test_data_dir, f"value_weight{dims_suffix_llama}.bin")
                output_proj_weight_path = os.path.join(test_data_dir, f"output_proj_weight{dims_suffix_llama}.bin")
                gate_weight_path = os.path.join(test_data_dir, f"gate_weight{dims_suffix_llama}.bin")
                up_weight_path = os.path.join(test_data_dir, f"up_weight{dims_suffix_llama}.bin")
                down_weight_path = os.path.join(test_data_dir, f"down_weight{dims_suffix_llama}.bin")
                
                cmd_pytorch.extend([
                    "--seq_len", str(args.seq_len), "--d_model", str(args.d_model),
                    "--intermediate_size", str(args.intermediate_size), "--head_num", str(args.head_num),
                    "--rmsnorm_epsilon", str(args.rmsnorm_eps),
                    "--input_path", input_path,
                    "--attn_norm_gamma_path", attn_norm_gamma_path,
                    "--ffn_norm_gamma_path", ffn_norm_gamma_path,
                    "--query_weight_path", query_weight_path,
                    "--key_weight_path", key_weight_path,
                    "--value_weight_path", value_weight_path,
                    "--output_proj_weight_path", output_proj_weight_path,
                    "--gate_weight_path", gate_weight_path,
                    "--up_weight_path", up_weight_path,
                    "--down_weight_path", down_weight_path,
                    "--output_path", ref_output_path,
                    "--output_performance_json", pytorch_perf_json_path
                ])

            try:
                run_command(cmd_pytorch, desc="PyTorch Reference Generation")
            except subprocess.CalledProcessError:
                print("Failed during PyTorch reference generation. Exiting.", flush=True)
                sys.exit(1)
            except FileNotFoundError:
                print("Failed during PyTorch reference generation (FileNotFound). Exiting.", flush=True)
                sys.exit(1)
        else:
            print("Skipping PyTorch reference generation.")


        # --- Step 3: C++ Simulation ---
        if not args.skip_cpp_sim:
            cpp_exe = get_cpp_exe_path(args.op_type, args.project_root)
            if not os.path.exists(cpp_exe):
                print(f"Error: C++ executable not found: {cpp_exe}. Ensure it is built."); sys.exit(1)

            cpp_exe_dir = os.path.dirname(cpp_exe)

            cmd_cpp = [cpp_exe]
            if args.op_type == "gemm":
                 cmd_cpp.extend([
                    str(args.M), str(args.K), str(args.N),
                    ifmap_path, weight_path, cpp_output_path
                ])
            elif args.op_type == "rmsnorm":
                cmd_cpp.extend([
                    str(args.seq_len), str(args.d_model), str(args.oc_group_size),
                    str(args.rmsnorm_epsilon),
                    input_path, gamma_path, cpp_output_path
                ])
            elif args.op_type == "softmax":
                cmd_cpp.extend([
                    str(args.oc_group), str(args.seq_len), str(args.oc_group_size),
                    input_path, cpp_output_path # cpp_output_path was correctly defined before
                ])
            elif args.op_type == "swish":
                cmd_cpp.extend([
                    str(args.oc_group), str(args.num_data), str(args.oc_group_size),
                    input_path, cpp_output_path
                ])
            elif args.op_type == "llama_block":
                cmd_cpp.extend([
                    "--seq_len", str(args.seq_len), 
                    "--d_model", str(args.d_model), 
                    "--intermediate_size", str(args.intermediate_size),
                    "--head_num", str(args.head_num), 
                    "--input_path", input_path,
                    "--attn_norm_gamma_path", os.path.join(test_data_dir, f"attn_norm_gamma{dims_suffix_llama}.bin"),
                    "--ffn_norm_gamma_path", os.path.join(test_data_dir, f"ffn_norm_gamma{dims_suffix_llama}.bin"),
                    "--query_weight_path", os.path.join(test_data_dir, f"query_weight{dims_suffix_llama}.bin"),
                    "--key_weight_path", os.path.join(test_data_dir, f"key_weight{dims_suffix_llama}.bin"),
                    "--value_weight_path", os.path.join(test_data_dir, f"value_weight{dims_suffix_llama}.bin"),
                    "--output_proj_weight_path", os.path.join(test_data_dir, f"output_proj_weight{dims_suffix_llama}.bin"),
                    "--gate_weight_path", os.path.join(test_data_dir, f"gate_weight{dims_suffix_llama}.bin"),
                    "--up_weight_path", os.path.join(test_data_dir, f"up_weight{dims_suffix_llama}.bin"),
                    "--down_weight_path", os.path.join(test_data_dir, f"down_weight{dims_suffix_llama}.bin"),
                    "--output_path", cpp_output_path
                ])
            
            try:
                run_command(cmd_cpp, cwd=cpp_exe_dir, desc="C++ Simulation")
            except subprocess.CalledProcessError:
                print("Failed during C++ simulation. Exiting.", flush=True)
                sys.exit(1)
            except FileNotFoundError:
                print("Failed during C++ simulation (FileNotFound). Exiting.", flush=True)
                sys.exit(1)
        else:
            print("Skipping C++ simulation.")


        # --- Step 4: Comparison ---
        if not args.skip_compare:
            compare_script = get_compare_script_path(args.op_type, op_precision)
            if not os.path.exists(compare_script):
                print(f"Error: Comparison script not found: {compare_script}"); sys.exit(1)

            cmd_compare = ["python3", compare_script]
            primary_ref_path_for_compare = "" 

            if args.op_type == "gemm":
                # Determine the primary reference based on args.gemm_precision
                if args.gemm_precision == "fp16":
                    primary_ref_path_for_compare = ref_output_path_fp16
                else: # args.gemm_precision == "fp32"
                    primary_ref_path_for_compare = ref_output_path_fp32
                
                if not os.path.exists(primary_ref_path_for_compare):
                    print(f"Error: Primary reference file {primary_ref_path_for_compare} for GEMM ({args.gemm_precision}) comparison not found. Ensure PyTorch step ran.")
                    sys.exit(1)
                if not os.path.exists(cpp_output_path):
                    print(f"Error: C++ output file {cpp_output_path} for GEMM comparison not found. Ensure C++ sim step ran."); sys.exit(1)
                
                # compare_gemm_outputs.py expects --ref_fp16_path for the main FP16 ref, and optionally --ref_fp32_path
                # If our primary target (and thus C++ output) is FP32, the roles are different.
                # For now, compare_gemm_outputs.py is structured around FP16 DUT vs FP16 REF, with optional FP32 REF.
                # If args.gemm_precision == "fp32", this comparison script might need adjustment or a different script.
                # Current compare_gemm_outputs.py: ref_fp16_path is required, cpp_fp16_path is required.
                # This implies it always compares FP16 vs FP16 primarily.
                
                if args.gemm_precision == "fp16":
                    cmd_compare.extend([
                        "--M", str(args.M), "--K", str(args.K), "--N", str(args.N),
                        "--ref_fp16_path", ref_output_path_fp16, # This is primary_ref_path_for_compare
                        "--cpp_fp16_path", cpp_output_path, 
                        "--charts_dir", test_charts_dir,
                        "--epsilon", str(args.compare_epsilon),
                        "--output_accuracy_json", accuracy_json_path
                    ])
                    if os.path.exists(ref_output_path_fp32): # If the FP32 ref was generated
                        cmd_compare.extend(["--ref_fp32_path", ref_output_path_fp32])
                elif args.gemm_precision == "fp32":
                    # compare_gemm_outputs.py expects --ref_fp16_path and --cpp_fp16_path.
                    # If we are running a GEMM FP32 validation, we need to ensure inputs to compare_gemm_outputs.py are appropriate.
                    # The C++ output (cpp_output_path) would be FP32.
                    # The PyTorch reference (ref_output_path_fp32) is FP32.
                    # compare_gemm_outputs.py loads cpp_fp16_path as float32 and casts to fp16.
                    # This is not ideal if the DUT is actually FP32.
                    # For now, we'll assume compare_gemm_outputs.py is for FP16 DUT focus.
                    # A dedicated FP32 comparison might be needed or modification of compare_gemm_outputs.py
                    print(f"Warning: GEMM FP32 validation with compare_gemm_outputs.py may not be ideal as it focuses on FP16 DUT.")
                    print(f"         Consider a dedicated FP32 comparison script or adapting compare_gemm_outputs.py.")
                    # As a workaround, we can pass the FP32 files to the FP16-named arguments.
                    # The script will load them as FP32, then cast cpp to FP16, which is not what we want for FP32 DUT.
                    # This will likely show large errors if C++ output is indeed FP32 and ref is FP32.
                    # The compare_gemm_outputs.py would need to be more flexible.
                    # SKIPPING comparison for GEMM FP32 for now until compare_gemm_outputs.py is made more flexible
                    # or a new script is introduced.
                    print("Skipping GEMM FP32 comparison due to script limitations.")
                    cmd_compare = [] # Empty the command to skip this step

            elif args.op_type == "rmsnorm":
                primary_ref_path_for_compare = ref_output_path
                if not os.path.exists(primary_ref_path_for_compare):
                    print(f"Error: Reference file {primary_ref_path_for_compare} for RMSNorm comparison not found."); sys.exit(1)
                if not os.path.exists(cpp_output_path):
                    print(f"Error: C++ output file {cpp_output_path} for RMSNorm comparison not found. Ensure C++ sim step ran."); sys.exit(1)
                cmd_compare.extend([
                    "--seq_len", str(args.seq_len), "--d_model", str(args.d_model),
                    "--oc_group_size", str(args.oc_group_size),
                    "--ref_path", primary_ref_path_for_compare,
                    "--cpp_output_path", cpp_output_path,
                    "--charts_dir", test_charts_dir,
                    "--epsilon", str(args.compare_epsilon),
                    "--output_accuracy_json", accuracy_json_path
                ])
                if args.enable_outlier_analysis:
                    cmd_compare.append("--enable_outlier_analysis")
                    if args.outlier_abs_threshold is not None:
                        cmd_compare.extend(["--outlier_abs_threshold", str(args.outlier_abs_threshold)])
                    if args.outlier_rel_threshold is not None:
                        cmd_compare.extend(["--outlier_rel_threshold", str(args.outlier_rel_threshold)])
            elif args.op_type == "softmax":
                primary_ref_path_for_compare = ref_output_path
                if not os.path.exists(primary_ref_path_for_compare):
                    print(f"Error: Reference file {primary_ref_path_for_compare} for Softmax comparison not found."); sys.exit(1)
                if not os.path.exists(cpp_output_path):
                    print(f"Error: C++ output file {cpp_output_path} for Softmax comparison not found. Ensure C++ sim step ran."); sys.exit(1)
                cmd_compare.extend([
                    "--oc_group", str(args.oc_group), "--seq_len", str(args.seq_len),
                    "--oc_group_size", str(args.oc_group_size),
                    "--ref_path", primary_ref_path_for_compare,
                    "--cpp_output_path", cpp_output_path, 
                    "--charts_dir", test_charts_dir,
                    "--epsilon", str(args.compare_epsilon),
                    "--output_accuracy_json", accuracy_json_path
                ])
                if args.enable_outlier_analysis:
                    cmd_compare.append("--enable_outlier_analysis")
                    if args.outlier_abs_threshold is not None:
                        cmd_compare.extend(["--outlier_abs_threshold", str(args.outlier_abs_threshold)])
                    if args.outlier_rel_threshold is not None:
                        cmd_compare.extend(["--outlier_rel_threshold", str(args.outlier_rel_threshold)])
            elif args.op_type == "swish":
                primary_ref_path_for_compare = ref_output_path
                if not os.path.exists(primary_ref_path_for_compare):
                    print(f"Error: Reference file {primary_ref_path_for_compare} for Swish comparison not found."); sys.exit(1)
                if not os.path.exists(cpp_output_path):
                    print(f"Error: C++ output file {cpp_output_path} for Swish comparison not found. Ensure C++ sim step ran."); sys.exit(1)
                cmd_compare.extend([
                    "--oc_group", str(args.oc_group), "--num_data", str(args.num_data),
                    "--oc_group_size", str(args.oc_group_size),
                    "--ref_path", primary_ref_path_for_compare,
                    "--cpp_output_path", cpp_output_path, 
                    "--charts_dir", test_charts_dir,
                    "--epsilon", str(args.compare_epsilon),
                    "--output_accuracy_json", accuracy_json_path
                ])
                if args.enable_outlier_analysis:
                    cmd_compare.append("--enable_outlier_analysis")
                    if args.outlier_abs_threshold is not None:
                        cmd_compare.extend(["--outlier_abs_threshold", str(args.outlier_abs_threshold)])
                    if args.outlier_rel_threshold is not None:
                        cmd_compare.extend(["--outlier_rel_threshold", str(args.outlier_rel_threshold)])
            elif args.op_type == "llama_block":
                primary_ref_path_for_compare = ref_output_path
                if not os.path.exists(primary_ref_path_for_compare):
                    print(f"Error: Reference file {primary_ref_path_for_compare} for LLaMA Block comparison not found."); sys.exit(1)
                if not os.path.exists(cpp_output_path):
                    print(f"Error: C++ output file {cpp_output_path} for LLaMA Block comparison not found. Ensure C++ sim step ran."); sys.exit(1)
                cmd_compare.extend([
                    "--seq_len", str(args.seq_len), "--d_model", str(args.d_model),
                    "--intermediate_size", str(args.intermediate_size), "--head_num", str(args.head_num),
                    "--ref_path", primary_ref_path_for_compare,
                    "--cpp_output_path", cpp_output_path, 
                    "--charts_dir", test_charts_dir, 
                    "--epsilon", str(args.compare_epsilon),
                    "--output_accuracy_json", accuracy_json_path
                ])
                if args.enable_outlier_analysis:
                    cmd_compare.append("--enable_outlier_analysis")
                    if args.outlier_abs_threshold is not None:
                        cmd_compare.extend(["--outlier_abs_threshold", str(args.outlier_abs_threshold)])
                    if args.outlier_rel_threshold is not None:
                        cmd_compare.extend(["--outlier_rel_threshold", str(args.outlier_rel_threshold)])

            try:
                if cmd_compare: # Only run if cmd_compare is not empty (e.g. not for GEMM FP32 skipped case)
                    run_command(cmd_compare, desc="Comparison")
            except subprocess.CalledProcessError:
                print("Failed during comparison. Exiting.", flush=True)
                sys.exit(1)
            except FileNotFoundError:
                print("Failed during comparison (FileNotFound). Exiting.", flush=True)
                sys.exit(1)
        else:
            print("Skipping comparison.")

        print(f"\n--- Operator Validation for {op_full_name} ({args.test_name}) Finished ---")
        print(f"All outputs, data, and charts for this run are in: {test_run_dir}")

    except Exception as e:
        print(f"Unhandled exception in main(): {e}", flush=True)
        import traceback
        print(traceback.format_exc(), flush=True)
        sys.exit(1) # Ensure script exits with non-zero on unhandled error

if __name__ == "__main__":
    main() 