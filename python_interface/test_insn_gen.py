"""
Author: ray_huang
Description:
    NPU指令编译测试框架
    JSON配置驱动的完整指令生成测试
特性：
- 所有算子参数、地址配置从JSON文件读取
- 详细的编译信息记录（指令条数、文件大小、执行时间）
- 结构化的目录组织和测试报告
- 统一的测试流程
"""

import sys
import json
import time
import logging
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
import traceback

# 添加路径
current_dir = Path(__file__).parent
sys.path.append(str(current_dir.parent))

from npu_ops.core import get_npu_core, DType

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class InstructionCompilationTester:
    """指令编译测试器 - JSON配置驱动"""
    
    def __init__(self, config_dir: Optional[Path] = None):
        self.test_dir = Path("test/insn_gen")
        self.config_dir = config_dir or self.test_dir / "configs"
        self.output_dir = self.test_dir / "output"
        self.reports_dir = self.test_dir / "reports"
        
        # 创建目录
        for dir_path in [self.output_dir, self.reports_dir]:
            dir_path.mkdir(parents=True, exist_ok=True)
        
        # 加载配置
        self.operators_config = self._load_json(self.config_dir / "operators.json")
        self.addresses_config = self._load_json(self.config_dir / "addresses.json")
        self.test_cases_config = self._load_json(self.config_dir / "test_cases.json")
        
        # 加载NPU核心
        self.npu_core = get_npu_core()
        
        # 测试结果存储
        self.compilation_results = {}
        
        logger.info(f"🚀 指令编译测试器初始化完成")
        logger.info(f"   配置目录: {self.config_dir}")
        logger.info(f"   输出目录: {self.output_dir}")
        logger.info(f"   算子数量: {len(self.operators_config)}")
    
    def _load_json(self, file_path: Path) -> Dict:
        """加载JSON配置文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"❌ 加载配置文件失败: {file_path}, 错误: {e}")
            raise
    
    def _resolve_addresses(self, op_name: str) -> Dict:
        """解析算子地址配置"""
        address_config = self.addresses_config["address_allocation"][op_name]
        
            # 直接转换十六进制地址
        addresses = {}
        for key, value in address_config.items():
            if isinstance(value, str) and value.startswith("0x"):
                addresses[key] = int(value, 16)
            else:
                addresses[key] = value
        return addresses
    
    def test_operator_compilation(self, op_name: str, test_case_name: str) -> Dict:
        """测试单个算子的指令编译"""
        
        logger.info(f"🔧 编译测试: {op_name}.{test_case_name}")
        
        # 获取配置
        op_config = self.operators_config[op_name]
        test_case = self.test_cases_config[op_name][test_case_name]
        addresses = self._resolve_addresses(op_name)
        
        # 创建输出目录
        case_output_dir = self.output_dir / op_name / f"case_{test_case_name}"
        case_output_dir.mkdir(parents=True, exist_ok=True)
        
        # 准备文件路径
        insn_file = case_output_dir / f"{op_name}_insn.bin"
        vcucode_file = case_output_dir / f"{op_name}_vcucode.bin" if op_config["supports_vcucode"] else None
        
        # 记录编译开始时间
        start_time = time.perf_counter()
        
        try:
            # 执行指令编译
            instruction_count = self._compile_operator(
                op_name, op_config, test_case, addresses, insn_file, vcucode_file
            )
            
            # 记录编译结束时间
            end_time = time.perf_counter()
            compilation_time = end_time - start_time
            
            # 收集文件信息
            file_info = self._collect_file_info(insn_file, vcucode_file)
            
            
            # 构建编译报告
            compilation_report = {
                "operator": op_name,
                "test_case": test_case_name,
                "compilation_status": "SUCCESS",
                "instruction_count": instruction_count,
                "compilation_time_seconds": round(compilation_time, 6),
                "file_info": file_info,
                "parameters": test_case,
                "addresses_used": {k: hex(v) if isinstance(v, int) else v for k, v in addresses.items()},
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
            }
            
            # 保存编译报告
            self._save_compilation_report(compilation_report, case_output_dir)
                        
            logger.info(f"✅ {op_name}.{test_case_name} 编译成功")
            logger.info(f"   指令数: {instruction_count}, 时间: {compilation_time:.3f}s")
            if file_info.get("instruction_file"):
                logger.info(f"   指令文件: {file_info['instruction_file']['size_kb']} KB")
            if file_info.get("vcucode_file"):
                logger.info(f"   VCU代码: {file_info['vcucode_file']['size_kb']} KB")
            
            return compilation_report
            
        except Exception as e:
            error_report = {
                "operator": op_name,
                "test_case": test_case_name,
                "compilation_status": "FAILED",
                "error_message": str(e),
                "error_traceback": traceback.format_exc(),
                "compilation_time_seconds": round(time.perf_counter() - start_time, 6),
                "parameters": test_case,
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
            }
            
            self._save_compilation_report(error_report, case_output_dir)
            logger.error(f"❌ {op_name}.{test_case_name} 编译失败: {e}")
            
            return error_report
    
    def _compile_operator(self, op_name: str, op_config: Dict, test_case: Dict, 
                         addresses: Dict, insn_file: Path, vcucode_file: Optional[Path] = None) -> int:
        """执行算子编译"""
        
        function_name = op_config["function_name"]
        
        if op_name == "gemm":
            return self.npu_core.Gemm(
                str(insn_file),
                m=test_case["m"], 
                n=test_case["n"], 
                k=test_case["k"],
                tile_m=test_case["tile_m"],
                block_n_group=test_case["block_n_group"],
                block_k_group=test_case["block_k_group"],
                ifmap_addr=addresses["ifmap_addr"],
                weight_addr=addresses["weight_addr"],
                output_addr=addresses["output_addr"],
                all_done=1
            )
        
        elif op_name == "rmsnorm":
            return self.npu_core.RMSNorm(
                str(insn_file), str(vcucode_file),
                seq_len=test_case["seq_len"],
                d_model=test_case["d_model"],
                tile_m=test_case["tile_m"],
                block_oc_group=test_case["block_oc_group"],
                epsilon=test_case["epsilon"],
                dtype=getattr(DType, test_case["dtype"]),
                input_ddr_base_address=addresses["input_ddr_base_address"],
                gamma_ddr_base_address=addresses["gamma_ddr_base_address"],
                output_ddr_base_address=addresses["output_ddr_base_address"],
                vcucode_ddr_base_address=addresses["vcucode_ddr_base_address"],
                rec_lut_ddr_base_address=addresses["rec_lut_ddr_base_address"],
                log_lut_ddr_base_address=addresses["log_lut_ddr_base_address"],
                exp_lut_ddr_base_address=addresses["exp_lut_ddr_base_address"],
                rsqrt_lut_ddr_base_address=addresses["rsqrt_lut_ddr_base_address"],
                all_done=1
            )
        
        elif op_name == "softmax":
            return self.npu_core.Softmax(
                str(insn_file), str(vcucode_file),
                seq_len=test_case["seq_len"],
                d_model=test_case["d_model"],
                tile_m=test_case["tile_m"],
                block_oc_group=test_case["block_oc_group"],
                input_addr=addresses["input_addr"],
                output_addr=addresses["output_addr"],
                vcu_code_addr=addresses["vcu_code_addr"],
                exp_lut_addr=addresses["exp_lut_addr"],
                rec_lut_addr=addresses["rec_lut_addr"],
                all_done=1
            )
        
        elif op_name == "llama_block":
            return self.npu_core.LlamaBlock(
                str(insn_file), str(vcucode_file),
                seq_len=test_case["seq_len"],
                hidden_size=test_case["hidden_size"],
                intermediate_size=test_case["intermediate_size"],
                num_attention_heads=test_case["num_attention_heads"],
                rmsnorm_epsilon=test_case["rmsnorm_epsilon"],
                hidden_dtype=getattr(DType, test_case["hidden_dtype"]),
                weight_dtype=getattr(DType, test_case["weight_dtype"]),
                **addresses,  # 展开所有地址参数
                all_done=1
            )
        
        else:
            raise ValueError(f"不支持的算子类型: {op_name}")
    
    def _collect_file_info(self, insn_file: Path, vcucode_file: Optional[Path] = None) -> Dict:
        """收集文件信息"""
        file_info = {}
        
        if insn_file.exists():
            size_bytes = insn_file.stat().st_size
            file_info["instruction_file"] = {
                "path": str(insn_file),
                "size_bytes": size_bytes,
                "size_kb": round(size_bytes / 1024, 2),
                "exists": True
            }
        else:
            file_info["instruction_file"] = {"exists": False}
        
        if vcucode_file:
            if vcucode_file.exists():
                size_bytes = vcucode_file.stat().st_size
                file_info["vcucode_file"] = {
                    "path": str(vcucode_file),
                    "size_bytes": size_bytes,
                    "size_kb": round(size_bytes / 1024, 2),
                    "exists": True
                }
            else:
                file_info["vcucode_file"] = {"exists": False}
        
        return file_info
    
    def _save_compilation_report(self, report: Dict, output_dir: Path):
        """保存编译报告"""
        report_file = output_dir / "compilation_report.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
    def run_all_compilation_tests(self) -> Dict:
        """运行所有编译测试"""
        logger.info("🚀 开始指令编译测试")
        logger.info("=" * 60)
        
        all_results = {}
        total_tests = 0
        passed_tests = 0
        
        for op_name, op_config in self.operators_config.items():
            logger.info(f"\n📋 测试算子: {op_name} ({op_config['description']})")
            all_results[op_name] = {}
            
            for test_case_name in op_config["test_cases"]:
                if test_case_name in self.test_cases_config[op_name]:
                    total_tests += 1
                    result = self.test_operator_compilation(op_name, test_case_name)
                    all_results[op_name][test_case_name] = result
                    
                    if result["compilation_status"] == "SUCCESS":
                        passed_tests += 1
                else:
                    logger.warning(f"⚠️  测试用例 {test_case_name} 未在配置中找到")
        
        # 生成综合报告
        summary_report = self._generate_summary_report(all_results, passed_tests, total_tests)
        self._save_summary_report(summary_report)
        
        logger.info(f"\n{'='*60}")
        logger.info(f"📊 编译测试完成: {passed_tests}/{total_tests} 通过")
        
        if passed_tests == total_tests:
            logger.info("🎉 所有指令编译测试通过！")
        else:
            logger.warning(f"⚠️  有 {total_tests - passed_tests} 项测试失败")
        
        return all_results
    
    def _generate_summary_report(self, all_results: Dict, passed_tests: int, total_tests: int) -> Dict:
        """生成综合报告"""
        summary = {
            "test_summary": {
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
                "total_operators": len(all_results),
                "total_test_cases": total_tests,
                "passed_tests": passed_tests,
                "failed_tests": total_tests - passed_tests,
                "success_rate": round(passed_tests / total_tests * 100, 2) if total_tests > 0 else 0
            },
            "operator_results": {},
            "performance_summary": {
                "total_instructions_generated": 0,
                "total_compilation_time": 0,
                "average_compilation_speed": 0
            }
        }
        
        total_instructions = 0
        total_time = 0
        
        for op_name, op_results in all_results.items():
            op_summary = {
                "total_cases": len(op_results),
                "passed_cases": 0,
                "failed_cases": 0,
                "total_instructions": 0,
                "total_time": 0
            }
            
            for case_name, result in op_results.items():
                if result["compilation_status"] == "SUCCESS":
                    op_summary["passed_cases"] += 1
                    op_summary["total_instructions"] += result["instruction_count"]
                    op_summary["total_time"] += result["compilation_time_seconds"]
                    
                    total_instructions += result["instruction_count"]
                    total_time += result["compilation_time_seconds"]
                else:
                    op_summary["failed_cases"] += 1
            
            op_summary["pass_rate"] = round(op_summary["passed_cases"] / op_summary["total_cases"] * 100, 2)
            summary["operator_results"][op_name] = op_summary
        
        # 性能汇总
        summary["performance_summary"]["total_instructions_generated"] = total_instructions
        summary["performance_summary"]["total_compilation_time"] = round(total_time, 3)
        if total_time > 0:
            summary["performance_summary"]["average_compilation_speed"] = round(total_instructions / total_time, 2)
        
        summary["detailed_results"] = all_results
        
        return summary
    
    def _save_summary_report(self, summary_report: Dict):
        """保存综合报告"""
        report_file = self.reports_dir / "compilation_summary.json"
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(summary_report, f, indent=2, ensure_ascii=False)
        
        logger.info(f"📄 综合报告已保存: {report_file}")


def main():
    """主函数：运行完整的指令编译测试"""
    try:
        tester = InstructionCompilationTester()
        results = tester.run_all_compilation_tests()
        
        # 检查是否所有测试通过
        total_success = all(
            all(case["compilation_status"] == "SUCCESS" for case in op_results.values())
            for op_results in results.values()
        )
        
        if total_success:
            print("\n🎉 所有指令编译测试成功完成！")
            return True
        else:
            print("\n❌ 部分指令编译测试失败！")
            return False
            
    except Exception as e:
        logger.error(f"❌ 指令编译测试框架执行异常: {e}")
        logger.error(traceback.format_exc())
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
