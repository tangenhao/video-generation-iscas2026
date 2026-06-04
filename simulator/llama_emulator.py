from gemm import GemmSimulator
from softmax import SoftmaxEmulator
from layernorm import LayerNormEmulator


class LLaMaEmulator():

    def __init__(
            self, hidden_size: int, head_num: int, mlp_size: int, vocab_size: int, prefill_seq_len: int, destination_seq_len: int, num_layers: int,
            dtype: str,
            outlier: bool = False, pvsq: bool = False, 
            num_cores: int = 8, bandwidth: int = 25, bandwidth_factor: float = 0.5, core_frequency: int = 800, debug = False
    ):
        self.hidden_size = hidden_size
        self.head_num = head_num
        self.d_h = hidden_size // head_num
        self.mlp_size = mlp_size
        self.vocab_size = vocab_size
        self.prefill_seq_len = prefill_seq_len
        self.destination_seq_len = destination_seq_len
        self.outlier = outlier
        self.pvsq = pvsq
        self.num_cores = num_cores
        self.bandwidth = bandwidth
        self.bandwidth_factor = bandwidth_factor
        self.core_frequency = core_frequency
        self.debug = debug
        self.dtype = dtype
        self.num_layers = num_layers

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

    def prefill(self):
        time = 0
        self.token_emb_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.hidden_size, k=self.vocab_size, dtype=self.dtype,
                                               tile_m=int(min(self.prefill_seq_len, 128)),
                                               block_k_group=int(min(512/min(self.prefill_seq_len, 128), self.vocab_size/self.k_group_size)),
                                               block_n_group=int(min(32/min(512/min(self.prefill_seq_len, 128), self.vocab_size/self.k_group_size) * self.num_cores, self.hidden_size/self.n_group_size)),
                                               outlier=False, transpose=False, pvsq=False, activation=False, num_cores=self.num_cores,
                                               bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
        time += self.token_emb_prefill.run()
        if self.debug:
            print(f"Token embedding prefill time: {self.token_emb_prefill.run()} s")

        for i in range(self.num_layers):
            self.q_proj_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 128),
                                                block_k_group=min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size) * self.num_cores, self.hidden_size/self.n_group_size),
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.q_proj_prefill.run()
            if self.debug:
                print(f"Q projection prefill time: {self.q_proj_prefill.run()} s")

            self.k_proj_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 32),
                                                block_k_group=min(512/min(self.prefill_seq_len, 32), self.hidden_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 32), self.hidden_size/self.k_group_size) * self.num_cores, self.hidden_size/self.n_group_size),
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.k_proj_prefill.run()
            if self.debug:
                print(f"K projection prefill time: {self.k_proj_prefill.run()} s")
            
            self.v_proj_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 32),
                                                block_k_group=min(512/min(self.prefill_seq_len, 32), self.hidden_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 32), self.hidden_size/self.k_group_size) * self.num_cores, self.hidden_size/self.n_group_size),
                                                outlier=self.outlier, transpose=True, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.v_proj_prefill.run()
            if self.debug:
                print(f"V projection prefill time: {self.v_proj_prefill.run()} s")
            
            self.qkt_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.prefill_seq_len, k=self.d_h, dtype=self.dtype,
                                            tile_m=min(self.prefill_seq_len, 128),
                                            block_k_group=min(512/min(self.prefill_seq_len, 128), self.d_h/self.k_group_size),
                                            block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.d_h/self.k_group_size), self.prefill_seq_len/self.n_group_size),
                                            outlier=False, transpose=False, pvsq=self.pvsq, activation=False, num_cores=1,
                                            bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            for _ in range(0, self.head_num, 8):
                time += self.qkt_prefill.run()
                if self.debug:
                    print(f"QK^T prefill time: {self.qkt_prefill.run()} s")
            
            self.softmax_prefill = SoftmaxEmulator(seq_len=self.prefill_seq_len, d_model=self.prefill_seq_len, num_cores=1, 
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            for _ in range(0, self.head_num, 8):
                time += self.softmax_prefill.Run()
                if self.debug:
                    print(f"Softmax prefill time: {self.softmax_prefill.Run()} s")
            
            self.pv_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.d_h, k=self.prefill_seq_len, dtype=self.dtype,
                                            tile_m=min(self.prefill_seq_len, 128),
                                            block_k_group=min(512/min(self.prefill_seq_len, 128), self.prefill_seq_len/self.k_group_size),
                                            block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.prefill_seq_len/self.k_group_size), self.d_h/self.n_group_size),
                                            outlier=False, transpose=False, pvsq=self.pvsq, activation=False, num_cores=1,
                                            bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            for _ in range(0, self.head_num, 8):
                time += self.pv_prefill.run()
                if self.debug:
                    print(f"PV prefill time: {self.pv_prefill.run()} s")
            
            self.o_proj_prefill = GemmSimulator(m=self.prefill_seq_len, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 128),
                                                block_k_group=min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size) * self.num_cores, self.hidden_size/self.n_group_size),
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.o_proj_prefill.run()
            if self.debug:
                print(f"O projection prefill time: {self.o_proj_prefill.run()} s")
            
            self.ln_prefill = LayerNormEmulator(seq_len=self.prefill_seq_len, d_model=self.hidden_size, num_cores=1,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.ln_prefill.run()
            if self.debug:
                print(f"Layer normalization prefill time: {self.ln_prefill.run()} s")
            
            self.mlp_prefill_0 = GemmSimulator(m=self.prefill_seq_len, n=self.mlp_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 128),
                                                block_k_group=min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size) * self.num_cores, self.mlp_size/self.n_group_size),
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.mlp_prefill_0.run()
            if self.debug:
                print(f"MLP prefill 0 time: {self.mlp_prefill_0.run()} s")
            
            self.mlp_prefill_1 = GemmSimulator(m=self.prefill_seq_len, n=self.mlp_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 128),
                                                block_k_group=min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.hidden_size/self.k_group_size) * self.num_cores, self.mlp_size/self.n_group_size),
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.mlp_prefill_1.run()
            if self.debug:
                print(f"MLP prefill 1 time: {self.mlp_prefill_1.run()} s")
            
            self.mlp_prefill_1 = GemmSimulator(m=self.prefill_seq_len, n=self.hidden_size, k=self.mlp_size, dtype=self.dtype,
                                                tile_m=min(self.prefill_seq_len, 128),
                                                block_k_group=min(512/min(self.prefill_seq_len, 128), self.mlp_size/self.k_group_size),
                                                block_n_group=min(32/min(512/min(self.prefill_seq_len, 128), self.mlp_size/self.k_group_size) * self.num_cores, self.hidden_size/self.n_group_size),
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=True, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.mlp_prefill_1.run()
            if self.debug:
                print(f"MLP prefill 1 time: {self.mlp_prefill_1.run()} s")

            if self.debug:
                print(f"==== Layer {i} time: {time} s ====")

        return time
    
    def decode(self, seq_len: int):
        time = 0
        self.token_emb_decode = GemmSimulator(m=1, n=self.hidden_size, k=self.vocab_size, dtype=self.dtype,
                                              tile_m=1,
                                              block_k_group=32,
                                              block_n_group=self.num_cores,
                                              outlier=False, transpose=False, pvsq=False, activation=False, num_cores=self.num_cores,
                                              bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
        time += self.token_emb_decode.run()
        if self.debug:
            print(f"Token embedding decode time: {self.token_emb_decode.run()} s")
        
        for i in range(self.num_layers):
            self.q_proj_decode = GemmSimulator(m=1, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=1,
                                                block_k_group=32,
                                                block_n_group=self.num_cores,
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.q_proj_decode.run()
            if self.debug:
                print(f"Q projection decode time: {self.q_proj_decode.run()} s")

            self.k_proj_decode = GemmSimulator(m=1, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                               tile_m=1,
                                               block_k_group=32,
                                               block_n_group=self.num_cores,
                                               outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                               bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.k_proj_decode.run()
            if self.debug:
                print(f"K projection decode time: {self.k_proj_decode.run()} s")
            
            self.v_proj_decode = GemmSimulator(m=1, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                               tile_m=1,
                                               block_k_group=32,
                                               block_n_group=self.num_cores,
                                               outlier=self.outlier, transpose=True, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                               bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.v_proj_decode.run()
            if self.debug:
                print(f"V projection decode time: {self.v_proj_decode.run()} s")
            
            round_off_seq = (seq_len + 31) // 32 * 32

            self.qkt_decode = GemmSimulator(m=1, n=round_off_seq, k=self.d_h, dtype=self.dtype,
                                            tile_m=1,
                                            block_k_group=4,
                                            block_n_group=min(8, round_off_seq/self.n_group_size),
                                            outlier=False, transpose=False, pvsq=self.pvsq, activation=False, num_cores=1,
                                            bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            for _ in range(0, self.head_num, 8):
                time += self.qkt_decode.run()
                if self.debug:
                    print(f"QK^T decode time: {self.qkt_decode.run()} s, round_off_seq: {round_off_seq}")
            
            self.softmax_decode = SoftmaxEmulator(seq_len=1, d_model=round_off_seq, num_cores=1, 
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            for _ in range(0, self.head_num, 8):
                time += self.softmax_decode.Run()
                if self.debug:
                    print(f"Softmax decode time: {self.softmax_decode.Run()} s")
            
            self.pv_decode = GemmSimulator(m=1, n=self.d_h, k=round_off_seq, dtype=self.dtype,
                                            tile_m=min(1, 128),
                                            block_k_group=min(16, round_off_seq/self.k_group_size),
                                            block_n_group=min(32/min(16, round_off_seq/self.k_group_size), self.d_h/self.n_group_size),
                                            outlier=False, transpose=False, pvsq=self.pvsq, activation=False, num_cores=1,
                                            bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            for _ in range(0, self.head_num, 8):
                time += self.pv_decode.run()
                if self.debug:
                    print(f"PV decode time: {self.pv_decode.run()} s")
            
            self.o_proj_decode = GemmSimulator(m=1, n=self.hidden_size, k=self.hidden_size, dtype=self.dtype,
                                               tile_m=1,
                                               block_k_group=32,
                                               block_n_group=self.num_cores,
                                               outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                               bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.o_proj_decode.run()
            if self.debug:
                print(f"O projection decode time: {self.o_proj_decode.run()} s")
            
            self.ln_decode = LayerNormEmulator(seq_len=1, d_model=self.hidden_size, num_cores=1,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.ln_decode.run()
            if self.debug:
                print(f"Layer normalization decode time: {self.ln_decode.run()} s")
            
            self.mlp_decode_0 = GemmSimulator(m=1, n=self.mlp_size, k=self.hidden_size, dtype=self.dtype,
                                                tile_m=1,
                                                block_k_group=32,
                                                block_n_group=self.num_cores,
                                                outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                                bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.mlp_decode_0.run()
            if self.debug:
                print(f"MLP decode 0 time: {self.mlp_decode_0.run()} s")
            
            self.mlp_decode_1 = GemmSimulator(m=1, n=self.mlp_size, k=self.hidden_size, dtype=self.dtype,
                                              tile_m=1,
                                              block_k_group=32,
                                              block_n_group=self.num_cores,
                                              outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=False, num_cores=self.num_cores,
                                              bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.mlp_decode_1.run()
            if self.debug:
                print(f"MLP decode 1 time: {self.mlp_decode_1.run()} s")
            
            self.mlp_decode_1 = GemmSimulator(m=1, n=self.hidden_size, k=self.mlp_size, dtype=self.dtype,
                                              tile_m=1,
                                              block_k_group=32,
                                              block_n_group=self.num_cores,
                                              outlier=self.outlier, transpose=False, pvsq=self.pvsq, activation=True, num_cores=self.num_cores,
                                              bandwidth=self.bandwidth, bandwidth_factor=self.bandwidth_factor, core_frequency=self.core_frequency, debug=False)
            time += self.mlp_decode_1.run()
            if self.debug:
                print(f"MLP decode 1 time: {self.mlp_decode_1.run()} s")
            
            if self.debug:
                print(f"==== Layer {i} time: {time} s ====")

        return time
    
    def run(self):  
        time = 0
        time += self.prefill()
        print(f"==== Prefill time: {time} s ====")
        
        for i in range(self.prefill_seq_len, self.destination_seq_len):
            decode_time = self.decode(i)
            time += decode_time
            print(f"==== Decode {i} time: {decode_time} s ====")
        
        return time


prefill_seq_len = 128
destination_seq_len = 256

llama_t = LLaMaEmulator(4096, 32, 11008, 32000, prefill_seq_len, destination_seq_len, 32, "int4xint4", True, False, 16, 50, 0.5, 800, True)
time = llama_t.run()
print(f"Total time: {time} s")
print(f"Tokens/s: {destination_seq_len - prefill_seq_len} / {time} = {(destination_seq_len - prefill_seq_len) / time}")

