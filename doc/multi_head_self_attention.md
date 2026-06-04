# Multi-Head-Self-Attention

## 1. Input and Output

$$
\begin{align}
X&\in[\frac{d\_model}{k\_group\_size}, seq\_len, k\_group\_size]\\
W_Q&\in[\frac{d\_model}{n\_group\_size}, \frac{d\_model}{k\_group\_size}, n\_group\_size, k\_group\_size]\\
W_K&\in[\frac{d\_model}{n\_group\_size}, \frac{d\_model}{k\_group\_size}, n\_group\_size, k\_group\_size]\\
W_V&\in[\frac{d\_model}{n\_group\_size}, \frac{d\_model}{k\_group\_size}, n\_group\_size, k\_group\_size]\\
W_O&\in[\frac{d\_model}{n\_group\_size}, \frac{d\_model}{k\_group\_size}, n\_group\_size, k\_group\_size]\\
O&\in[\frac{d\_model}{k\_group\_size}, seq\_len, k\_group\_size]
\end{align}
$$

## 2. Q-Linear

- **Inputs**: 
  - $X\in[\frac{d\_model}{k\_group\_size}, seq\_len, k\_group\_size]$
  - $W_Q\in[\frac{d\_model}{n\_group\_size}, \frac{d\_model}{k\_group\_size}, n\_group\_size, k\_group\_size]$
- **Compute**
  - GEMM, $m = seq\_len, n\_group = \frac{d\_model}{n\_group\_size}, k = \frac{d\_model}{k\_group\_size}$
  - Original output shape: $[\frac{d\_model}{n\_group\_size}, seq\_len, n\_group\_size]$
  - Split Head: $[h, \frac{d\_model}{n\_group\_size\times h}, seq\_len, n\_group\_size]$
  - Parallelism Convert: $[h, \frac{d\_model}{n\_group\_size\times h \times n\_group\_scale}, seq\_len, n\_group\_size \times n\_group\_scale]$
    - $n\_group\_scale = \frac{k\_group\_size}{n\_group\_size}$
    - **In practice, this step is ignored due to the splited head is continuous in memory**

## 3. K-Linear

- **Inputs**: 
  - $X\in[\frac{d\_model}{k\_group\_size}, seq\_len, k\_group\_size]$
  - $W_K\in[\frac{d\_model}{n\_group\_size}, \frac{d\_model}{k\_group\_size}, n\_group\_size, k\_group\_size]$
  - **Compute**
    - GEMM, $m = seq\_len, n\_group = \frac{d\_model}{n\_group\_size}, k = \frac{d\_model}{k\_group\_size}$
    - Original output shape: $[\frac{d\_model}{n\_group\_size}, seq\_len, n\_group\_size]$
    - Parallelism Convert: $[h, \frac{d\_model}{k\_group\_size\times h}, seq\_len, k\_group\_size]$
    - Split head and seq_len: $[h, \frac{seq\_len}{n\_group\_size}, \frac{d\_model}{k\_group\_size\times h}, n\_group\_size, k\_group\_size]$
      - seq_len must be multiple of n_group_size
      - GEMM tile_m = n_group_size, 