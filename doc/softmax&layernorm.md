# Softmax与LayerNorm

## Softmax

### 0. 输入与输出

- 输入，(d_model/32, seq_len, 32)
- 输出，(d_model/32, seq_len, 32)

### 1. 将vcures sram对应地址洗成0

- 配置微码
  - config reg0为数值0
- 配置指令
  - 输出ram类型10
  - num_data = seq_len - 1
  - oc_group = 0
  - vcures_sram_valid = 1

### 2. 把所有数据求exp

- 配置微码
  - 乘常数，psum和log2(exp(1.0))相乘
  - exp2
- 配置指令
  - 输出ram类型0
  - num_data = seq_len - 1
  - oc_group = d_model/32
  - psum_sram_valid = 1

### 3. 求和

- 循环oc_group次
  - 配置微码
    - reduce_sum，psum，写到reg0
    - 加法，reg0，resadd
  - 配置指令
    - 输出ram类型10
    - num_data = seq_len - 1
    - oc_group = 0
    - vcures_sram_valid = 1
    - psum_sram_valid = 1
    - psum_in_addr = i * seq_len

### 4. 1/x

- 配置微码
  - 1/x，resadd
- 配置指令
  - 输出ram类型10
  - num_data = seq_len - 1
  - oc_group = 0
  - vcures_sram_valid = 1

### 5. 乘法

- 循环oc_group次
  - 配置微码
    - 乘法，psum，resadd
  - 配置指令
    - 输出ram类型0
    - num_data = seq_len - 1
    - oc_group = 0
    - vcures_sram_valid = 1
    - psum_sram_valid = 1

## LayerNorm

### 0. 输入与输出

- 输入，(d_model/32, seq_len, 32)
- 输出，(d_model/32, seq_len, 32)

### 1. 将vcures sram对应地址洗成0

- 配置微码
  - config reg0为数值0
- 配置指令
  - 输出ram类型10
  - num_data = seq_len - 1
  - oc_group = 0
  - vcures_sram_valid = 1

### 2. 求均值

- 循环oc_group次
  - 配置微码
    - reduce_sum，psum，写到reg0
    - 加法，reg0，resadd
  - 配置指令
    - 输出ram类型10
    - num_data = seq_len - 1
    - oc_group = 0
    - vcures_sram_valid = 1
    - psum_sram_valid = 1
    - psum_in_addr = i * seq_len

### 3. * 1/d_model

- 配置微码
  - 乘常数，resadd，1/d_model
- 配置指令
  - 输出ram类型10
  - num_data = seq_len - 1
  - oc_group = 0
  - vcures_sram_valid = 1

### 4. x-E(x)

- 循环oc_group次
  - 配置微码
    - inv，resadd，reg0
    - 加法，psum，reg0
  - 配置指令
    - 输出ram类型0
    - num_data = seq_len - 1
    - oc_group = 0
    - vcures_sram_valid = 1
    - psum_sram_valid = 1
    - psum_in_addr = i * seq_len

### 5. 求方差

- 循环oc_group次
  - 配置微码
    - 乘法，psum，psum，写道reg0
    - reduce_sum，reg0，写到reg1
    - 加法，reg1，resadd
  - 配置指令
    - 输出ram类型10
    - num_data = seq_len - 1
    - oc_group = 0
    - vcures_sram_valid = 1
    - psum_sram_valid = 1
    - psum_in_addr = i * seq_len

### 6. 求$\frac{1}{\sqrt{D(x)+\epsilon}}$

- 配置微码
  - 乘常数，resadd，1/d_model，存到reg0
  - 加常数，reg0，$\epsilon$
  - rsqrt
- 配置指令
  - 输出ram类型10
  - num_data = seq_len - 1
  - oc_group = 0
  - vcures_sram_valid = 1

### 7. 乘法

循环oc_group次

- 配置微码
  - 乘法，psum，resadd，写道reg0
  - 乘法，reg0，para，写到reg1，para里放的是gamma
- 配置指令
  - 输出ram类型0
  - num_data = seq_len - 1
  - oc_group = 0
  - vcures_sram_valid = 1
  - psum_sram_valid = 1
  - psum_in_addr = i * seq_len

### 8. 加beta

- 配置微码
  - 加法，psum，para
- 配置指令
  - 输出ram类型0
  - num_data = seq_len - 1
  - oc_group = d_model/32
  - psum_sram_valid = 1