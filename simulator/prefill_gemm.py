
class GemmSimulatorPrefill():
    
    def __init__(
            self, m: int, n: int, k: int, dtype: str, tile_m: int, block_n_group: int, block_k_group: int,
            outlier: bool = False, transpose: bool = False, pvsq: bool = False, activation: bool = False,
            num_cores: int = 8, bandwidth: int = 25, bandwidth_factor: float = 0.5, core_frequency: int = 800, debug = False
    ) -> None:
        
        self.m = m
        self.n = n
        self.k = k
        self.dtype = dtype
        self.tile_m = int(tile_m)
        self.block_n_group = int(block_n_group)
        self.block_k_group = int(block_k_group)
        self.num_cores = num_cores
        self.outlier = outlier
        self.transpose = transpose
        self.pvsq = pvsq
        self.core_frequency = core_frequency
        self.activation = activation

        if "float32" in dtype:
            self.k_group_size = 8
        elif "float16" in dtype:
            self.k_group_size = 16
            self.convert = 1
        elif "bfloat16" in dtype:
            self.k_group_size = 16
            self.convert = 1
        elif "int8" in dtype:
            self.k_group_size = 32
            self.convert = 0
        elif dtype == "int4xint4":
            self.k_group_size = 64
            self.convert = 1

        self.n_group_size = 32

        self.k_iterations = self.k // (self.k_group_size * self.block_k_group)
        self.n_iterations = self.n // (self.n_group_size * self.block_n_group)
        self.m_iterations = (self.m + self.tile_m - 1) // self.tile_m

        self.bus_bandwidth = bandwidth * bandwidth_factor * 1000000000 * 8

        input_type = dtype.split("x")[0]
        weight_type = dtype.split("x")[1]

        if input_type == "float32":
            self.input_bytes = 4
        elif input_type == "float16":
            self.input_bytes = 2
        elif input_type == "bfloat16":
            self.input_bytes = 2
        elif input_type == "int8":
            self.input_bytes = 1
        elif input_type == "int4":
            self.input_bytes = 0.5

        if weight_type == "float32":
            self.weight_bytes = 4
        elif weight_type == "float16":
            self.weight_bytes = 2
        elif weight_type == "bfloat16":
            self.weight_bytes = 2
        elif weight_type == "int8":
            self.weight_bytes = 1
        elif weight_type == "int4":
            self.weight_bytes = 0.5

        if "float32" in dtype:
            self.gemm_type = "float32"
        elif "float16" in dtype or "bfloat16" in dtype:
            self.gemm_type = "float16"
        elif "int8" in dtype:
            self.gemm_type = "int8"
        elif "int4" in dtype:
            self.gemm_type = "int4"

        if debug:
            print("Type: ", dtype)
            print("GEMM Type: ", self.gemm_type)
            print("Input Bytes: ", self.input_bytes)
            print("Weight Bytes: ", self.weight_bytes)
            print("m: ", self.m)
            print("n: ", self.n)
            print("k: ", self.k)
            print("block_n_group: ", self.block_n_group)
            print("block_k_group: ", self.block_k_group)
            print("tile_m: ", self.tile_m)
            print("k iterations: ", self.k_iterations)
            print("m iterations: ", self.m_iterations)
            print("n iterations: ", self.n_iterations)
            print("k group size: ", self.k_group_size)
            print("n group size: ", self.n_group_size)

        self.debug = debug

    def LoadWeight(self):
        sram_bandwidth = 256 * self.num_cores * self.core_frequency / 8 * 1000000
        
        real_bandwidth = min(self.bus_bandwidth, sram_bandwidth)
        weight_size = self.block_n_group * self.block_k_group * self.n_group_size * self.k_group_size * self.weight_bytes
        time = weight_size / real_bandwidth
        
        return time
    
    def LoadInput(self):
        sram_bandwidth = 256 * self.core_frequency / 8 * 1000000
        
        real_bandwidth = min(self.bus_bandwidth, sram_bandwidth)
        input_size = self.tile_m * self.k_group_size * self.input_bytes * self.num_cores / 2
        time = input_size / real_bandwidth

        return time
    
    def Gemm(self):
        pipeline_cycles = 0
        if self.gemm_type == "float32":
            pipeline_cycles = 14
        elif self.gemm_type == "float16":
            pipeline_cycles = 14
        elif self.gemm_type == "int8":
            pipeline_cycles = 14
        elif self.gemm_type == "int4":
            pipeline_cycles = 14
        
        if self.pvsq:
            pipeline_cycles += 2
        
        weight_pingpang_cycles = 32

        num_cycles = 0
        if self.tile_m < weight_pingpang_cycles:
            if self.outlier:
                num_cycles = pipeline_cycles + weight_pingpang_cycles * self.block_k_group * self.block_n_group / self.num_cores * 2 + weight_pingpang_cycles
            else:
                num_cycles = pipeline_cycles + weight_pingpang_cycles * self.block_k_group * self.block_n_group / self.num_cores + weight_pingpang_cycles
        else:
            if self.outlier:
                num_cycles = pipeline_cycles + self.tile_m * self.block_k_group * self.block_n_group / self.num_cores * 2 + weight_pingpang_cycles
            else:
                num_cycles = pipeline_cycles + self.tile_m * self.block_k_group * self.block_n_group / self.num_cores + weight_pingpang_cycles
        
        return num_cycles / self.core_frequency / 1000000
    
    def VCU(self):
        base_activation_cycle = 0
        num_data = self.block_n_group * self.tile_m / self.num_cores
        
        if self.activation:
            base_activation_cycle += 4
        if self.convert:
            base_activation_cycle += 1
            
        time = base_activation_cycle * num_data / self.core_frequency / 1000000

        if self.transpose:
            time += self.block_n_group / self.num_cores * (1024 + 32) / self.core_frequency / 100000

        return time
    
    def Store(self):
        sram_bandwidth = 256 * self.core_frequency / 8 * 1000000
        
        real_bandwidth = min(self.bus_bandwidth, sram_bandwidth)
        
        output_size = self.tile_m * self.n_group_size * self.block_n_group * self.input_bytes * self.num_cores
        
        time = output_size / real_bandwidth
        
        return time
    
    def run(self):
        total_time = 0
        
        # Load the first tile of weight and input
        total_time += max(self.LoadWeight(), self.LoadInput())
        
        # Begin iteration
        true_inner_iterations = self.m_iterations * self.k_iterations + 1
        if true_inner_iterations < 0:
            true_inner_iterations = 0
        if self.n_iterations <= 0:
            self.n_iterations = 1
        for n in range(0, self.n_iterations):
            for k in range(int(true_inner_iterations)):
                if n != 0 and k == 0:
                    total_time += max(self.Gemm(), self.LoadInput(), self.LoadWeight(), self.Store())
                    if self.debug:
                        print(f"n: {n}, k: {k}, time: {max(self.Gemm(), self.LoadInput(), self.LoadWeight(), self.Store())}, total time: {total_time}")
                        print(f"gemm: {self.Gemm()}, load input: {self.LoadInput()}, load weight: {self.LoadWeight()}, store: {self.Store()}")
                else:
                    if k == true_inner_iterations - 1:
                        total_time += max(self.VCU(), self.Gemm(), self.LoadInput(), self.LoadWeight())
                        
                        if self.debug:
                            print(f"n: {n}, k: {k}, time: {max(self.VCU(), self.Gemm(), self.LoadInput(), self.LoadWeight())}, total time: {total_time}")
                            print(f"gemm: {self.Gemm()}, load input: {self.LoadInput()}, load weight: {self.LoadWeight()}, store: {self.Store()}")
                    else:
                        total_time += max(self.Gemm(), self.LoadInput(), self.LoadWeight())
                        if self.debug:
                            print(f"n: {n}, k: {k}, time: {max(self.Gemm(), self.LoadInput(), self.LoadWeight())}, total time: {total_time}")
        total_time += self.VCU()
        total_time += self.Store()

        return total_time
        

gemm_t = GemmSimulatorPrefill(1, 4096, 4096, "int4xint4", 1, 16, 32, True, False, False, False, 16, 50, 0.5, 800, True)
print(gemm_t.run())