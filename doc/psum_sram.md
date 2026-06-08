# psum sram地址分配

## 1. 物理bank

分为64个物理bank，每个bank位宽1024，深度256.

## 2. 地址分配

### 2.1 逻辑地址

{ping_pang_identifier[1:0], bank[3:0], addr[7:0]}

### 2.2 物理高位地址

{bank[3:0], ping_pang_identifier[1:0]}, 用于选择物理bank。

## 3. 特殊处理

核0、4可以访问核0~7的bank，核8、12可以访问核8~15的bank，其他核只能访问自己的bank。

对于核0、4，逻辑地址为

{1'b0, bank[2:0], ping_pang_identifier[1:0], addr[7:0]}

对于核8、12，逻辑地址为

{1'b1, bank[2:0], ping_pang_identifier[1:0], addr[7:0]}

对于其他核，逻辑地址为

{core_id[3:0], ping_pang_identifier[1:0], addr[7:0]}，其中core_id为核id，不可动态改变。
