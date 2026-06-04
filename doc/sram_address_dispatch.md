# SRAM Address Dispatch

| **SRAM**           | **Width(Bits)** | **Address Width(Bits)** | **Range(KB)** | **Master Base Address** | **Master High Adress** | **Slave Base Address** | **Slave High Address** |
|:------------------:|:---------------:|:-----------------------:|:-------------:|:-----------------------:|:----------------------:|:----------------------:|:-----------------------:|
| Regfile            | 32              | 4                       | 1             | 0x0                     | 0x400                  | 0x0                    | 0x400                   |
| Ifmap SRAM         | 512             | 12                      | 256           | 0x10000                  | 0x1FFFF                 | 0x400000               | 0x5FFFFF                |
| Ifmap Scale SRAM   | 32              | 12                      | 16            | 0x20000                 | 0x2FFFF                | 0x800000               | 0xBFFFFF                |
| Weight SRAM        | 512             | 15                      | 2048          | 0x30000                 | 0x3FFFF                | 0xC00000               | 0xFFFFFFF                |
| Weight Scale SRAM  | 16              | 14                      | 32            | 0x40000                 | 0x4FFFF                | 0x1000000               | 0x13FFFFF                |
| Outlier Index SRAM | 128             | 12                      | 64            | 0x50000                 | 0x5FFFF                | 0x1400000               | 0x17FFFFF                |
| Psum SRAM          | 2048            | 13                      | 2048          | 0x60000                 | 0x6FFFF                | 0x1800000               | 0x1BFFFFF                |
| Ofmap SRAM         | 512             | 12                      | 256           | 0x70000                 | 0x7FFFF                | 0x1C00000               | 0x1FFFFFF                |
| VcuCode SRAM       | 64              | 10                      | 8             | 0x80000                 | 0x8FFFF                | 0x2000000              | 0x23FFFFF               |
| VcuLUT SRAM        | 64              | 13                      | 64            | 0x90000                 | 0x9FFFF                | 0x2400000              | 0x27FFFFF               |
| VcuPara SRAM       | 2048            | 9                       | 128           | 0xA0000                 | 0xAFFFF                | 0x2800000              | 0x2BFFFFF               |
| VcuRes SRAM        | 2048            | 12                      | 1024          | 0xB0000                 | 0xBFFFF                | 0x2C00000              | 0x2FFFFFF               |

## Master Address Allocation

- Max address width: 15 bits
- Available address high width: 5 bits
- The address is aligned with bus width 512 bits or 64 bytes.
  - **For regfile, which is 32 bits wide, `0x0` indicates `control_reg[0]`, `0x40` indicates `control_reg[1]`, and so on.**
  - For SRAM with 512 bits width, `0x0` indicates `SRAM[0]`, `0x1` indicates `SRAM[1]`, and so on.
  - For SRAM with 2048 bits width, `0x0` indicates `SRAM[0]`, `0x4` indicates `SRAM[1]`, and so on.
  - For SRAM with 256 bits width, `0x0` indicates `SRAM[0]`, `0x1` indicates `SRAM[2]`, and so on.
  - For SRAM with 128 bits width, `0x0` indicates `SRAM[0]`, `0x1` indicates `SRAM[4]`, and so on.
  - For SRAM with 64 bits width, `0x0` indicates `SRAM[0]`, `0x1` indicates `SRAM[8]`, and so on.
  - For SRAM with 32 bits width, `0x0` indicates `SRAM[0]`, `0x1` indicates `SRAM[16]`, and so on.
  - For SRAM with 16 bits width, `0x0` indicates `SRAM[0]`, `0x1` indicates `SRAM[32]`, and so on.
- Address calculation:

```c++
for (int high_addr = 0; high_addr < 12; ++high_addr) {
  uint64_t master_base_addr = high_addr << 15;
  uint64_t master_high_addr = master_base_addr + range_kb * 1024 / 64 - 1;
}
```

## Slave Address Allocation

- The address is aligned with bytes.
  - **For regfile, which is 32 bits wide, `0x0` indicates `control_reg[0]`, `0x40` indicates `control_reg[1]`, and so on.**
  - For SRAM with 512 bits width, `0x0` indicates `SRAM[0]`, `0x40` indicates `SRAM[1]`, and so on.
  - For SRAM with 2048 bits width, `0x0` indicates `SRAM[0]`, `0x100` indicates `SRAM[1]`, and so on.
  - For SRAM with 256 bits width, `0x0` indicates `SRAM[0]`, `0x40` indicates `SRAM[2]`, and so on.
  - For SRAM with 128 bits width, `0x0` indicates `SRAM[0]`, `0x40` indicates `SRAM[4]`, and so on.
  - For SRAM with 64 bits width, `0x0` indicates `SRAM[0]`, `0x40` indicates `SRAM[8]`, and so on.
  - For SRAM with 32 bits width, `0x0` indicates `SRAM[0]`, `0x40` indicates `SRAM[16]`, and so on.
  - For SRAM with 16 bits width, `0x0` indicates `SRAM[0]`, `0x40` indicates `SRAM[32]`, and so on.
- Accessing low 6 bits of the address is **NOT ALLOWED**, the low 6 bit address will be **discarded**.
  - For example, if the address is `0x41`, the actual address will be `0x40`.
  - Therefore, **the minimal access granularity is 64 bytes**, which is the same as the bus width.
- Address calculation:

```c++
for (int high_addr = 0; high_addr < 12; ++high_addr) {
  // The first left shift is to align with the bus width.
  // The second left shift is to align with the byte width.
  uint64_t slave_base_addr = (high_addr << 15) << 7;
  uint64_t slave_high_addr = slave_base_addr + range_kb * 1024 - 1;
}
```