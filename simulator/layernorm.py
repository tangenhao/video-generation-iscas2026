
class LayerNormEmulator():
    
    def __init__(self, seq_len: int, d_model: int, num_cores: int,
                 bandwidth: int = 25, bandwidth_factor: float = 0.5, core_frequency: int = 800, debug = False) -> None:
        self.seq_len = seq_len
        self.d_model = d_model
        self.num_cores = num_cores
        
        self.core_frequency = core_frequency
        self.bus_bandwidth_factor = bandwidth_factor

        self.debug = debug
        
        self.n_group_size = 32
        self.max_n_groups = 512 // self.seq_len
        if self.max_n_groups == 0:
            self.max_n_groups = 1
        
        self.iterations = self.d_model // (self.max_n_groups * self.n_group_size)
        if self.d_model % (512 / self.seq_len) != 0:
            self.iterations += 1
        
        if self.iterations == 0:
            self.iterations = 1
            
        self.bus_bandwidth = bandwidth * bandwidth_factor * 1000000000 * 8
        
    def LoadPsum(self):
        sram_bandwidth = 1024 * self.core_frequency / 8 * 1000000
        
        real_bandwidth = min(self.bus_bandwidth, sram_bandwidth)
        psum_size = self.seq_len * self.d_model * 4
        
        time = psum_size / real_bandwidth
        
        return time
      
    def VCU(self):
        # config
        total_cycles = self.seq_len * 7
        
        # cal mean
        for i in range(self.seq_len * self.max_n_groups):
            total_cycles += 7 # reduce
            total_cycles += 32 # reduce
            
        # multiply
        for i in range(self.seq_len):
            total_cycles += 7
            total_cycles += 7 # add
            total_cycles += 8 # rsqrt
        
        # norm
        for i in range(self.seq_len * self.max_n_groups):
            total_cycles += 7 # multiply
            total_cycles += 7 # multiply
            
        return total_cycles / self.core_frequency / 1000000
      
    def Store(self):
        sram_bandwidth = 256 * self.core_frequency / 8 * 1000000
        
        real_bandwidth = min(self.bus_bandwidth, sram_bandwidth)
        
        output_size = self.seq_len * self.d_model * 4
        
        time = output_size / real_bandwidth
        
        return time
      
    def run(self):
      
        total_time = 0
        
        for _ in range(self.iterations):
            total_time += max(self.LoadPsum(), self.VCU(), self.Store())
        
        return total_time
      

ln_t = LayerNormEmulator(1, 4096, 1, 25, 0.5, 800, True)
print(ln_t.run())