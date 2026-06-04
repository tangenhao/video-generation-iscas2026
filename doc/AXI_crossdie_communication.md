# AXI Crossdie Communication

## 1. Address Routing

### 1.1 DDR与SRAM

通过35bit的地位地址指示

### 1.2 Serdes0, Serdes1, NPU Slave, ddr以及多die

```c++
/*
    2bit      16bit          1bit         35bit
 _________________________________________________
|          |         |                |          |
|issue_port|high_addr|destination_port|local_addr|
|__________|_________|________________|__________|

*/

```

- **sync指令配置的高位地址19bit, 需要指定全部的高位地址**
  - `issue_port`, 2bit, 指定发往的端口
    - `00`: local
    - `01`: serdes1
    - `10`: serdes0
  - `high_addr`, 16bit, chip的高位地址, 由APB配进来
  - `destination_port`, 1bit, 指定目的端口
    - `0`: ddr
    - `1`: npu slave
- 转发规则
  - `issue_port`配置为0时, crossbar转发进入本地ddr或npu slave
  - `issue_port`配置不为0时, crossbar根据配置转发到serdes0或serdes1
    - 与当前die相连的npu的serdes slave接受到信息后，会根据`high_addr`是否匹配, 决定继续转发serdes或本地
      - 匹配, 则根据`destination_port`决定转发到ddr或npu slave, **截断高2bit地址, 丢进crossbar, 让crossbar自己去转发**
      - 不匹配, 则修改`issue_port`, 走另一个serdes转发到下一个die
        - `10` -> `01`
        - `01` -> `10`
  - **缺点**
    - 最好提前根据拓扑以及APB配置的地址高位确定走哪个serdes, 防止死锁
    - 或者将所有的NPU chiplet连成环形, 保证这种路由策略不会出现死锁

```verilog
module address_router(
  in_address,
  out_address,
  local_highaddr
);

parameter ADDR_WIDTH = 64;
parameter HIGHADDR_BITS = 16;
parameter VALIDADDR_BITS = 36;

input  [ADDR_WIDTH-1:0] in_address;
output [ADDR_WIDTH-1:0] out_address;
input  [HIGHADDR_BITS-1:0] local_highaddr;

wire match;

assign match = in_address[VALIDADDR_BITS+:HIGHADDR_BITS] == local_highaddr;

wire [1:0] ori_issue_addr;
wire [1:0] dst_issue_addr;
assign ori_issue_addr = in_address[VALIDADDR_BITS+1+HIGHADDR_BITS+:2];
assign dst_issue_addr = ori_issue_addr == 2'b01 ? 2'b10
                      : ori_issue_addr == 2'b10 ? 2'b01
                      : 2'b00;

assign out_address = match ? in_address[VALIDADDR_BITS+HIGHADDR_BITS-1:0] : {{(ADDR_WIDTH-HIGHADDR_BITS-VALIDADDR_BITS-2){1'b0}}, dst_issue_addr, in_address[0+:(VALIDADDR_BITS+HIGHADDR_BITS+1)]};

endmodule
```

## 2. Outstanding与ID

### 2.1 Die内部的ID位宽以及不做额外处理会出现的问题

NPU内部有一个2to1的crossbar, 用于转发指令AXI与数据AXI的请求, 这个crossbar的输入ID为1bit, 输出ID为2bit.

进入npu_chiplet层, 有一个3to4的crossbar, 在这里要用16bit的地址高位拼接出ID, 拼接完毕后master的ID为18bit

```verilog
assign axi4_full_M_AXI_AWID = {local_highaddr, local_aw_id};
assign axi4_full_M_AXI_ARID = {local_highaddr, local_ar_id};
```

经过3to4的crossbar后, master的ID会变成20bit, 而slave的ID只需要18bit, 在本地master访问ddr时, 两块ddr还会再拓展1bit变成21bit, 这样简单地拓展在本地master访问本地ddr slave时不会有问题, 但涉及跨die访问出现ID位宽不匹配导致crossbar仲裁转发失效的问题.

目前存在3to4访问情况, 以读为例

- NPU Master访问DDR slave
  - NPU Master ARID 18bit -> Crossbar Master ARID 20bit -> 2to1 R&W ARID 21bit -> DDR Slave ARID 21bit
  - DDR Slave RID 21bit -> 2to1 R&W RID 21bit -> Crossbar Master RID 20bit -> NPU Master RID 18bit
  - 能够正确转发
- NPU Master访问本地NPU Slave
  - NPU Master ARID 18bit -> Crossbar Master RID 20bit -> NPU Slave ARID 20bit
  - NPU Slave RID 20bit -> Crossbar Master RID 20bit -> NPU Master RID 18bit
  - 能够正确转发
- NPU Master经过Serdes访问其他die的slave
  - NPU Master ARID 18bit -> Crossbar0 Master ARID 20bit -> **Crossbar1 Slave ARID 18bit** -> Crossbar1 Master ARID 20bit
  - 这一步会丢失部分信息, **导致Crossbar0无法正确转发**

### 2.2 解决方案

由于默认不支持乱序, 可以简单地为serdes的ID做FIFO缓存, 深度为配置的outstanding数目, 这样可以保证ID的位宽不会发生变化, 从而保证crossbar的正确转发.

```verilog
sync_fifo_regfile #(
  .width(M_ID_WIDTH),
  .depth(AXI4_FULL_OUTSTANDING_DEPTH)
) u_sync_fifo_regfile_serdes0_read_id(
  .clk      ( axi4_clk                                                          ),
  .rst_n    ( axi4_rst_n                                                        ),
  .w_en     ( serdes0_S_AXI_ARVALID & serdes0_S_AXI_ARREADY                     ),
  .w_data   ( serdes0_S_AXI_ARID                                                ),
  .r_en     ( serdes0_S_AXI_RVALID & serdes0_S_AXI_RREADY & serdes0_S_AXI_RLAST ),
  .r_data   ( cached_serdes0_AXI_RID                                            ),
  .full     (                                                                   ),
  .empty    (                                                                   ),
  .hfull    (                                                                   ),
  .hempty   (                                                                   ),
  .afull    (                                                                   ),
  .aempty   (                                                                   ),
  .capacity (                                                                   )
);

assign serdes0_S_AXI_RID = cached_serdes0_AXI_RID | {2'b00, crossbar_serdes0_AXI_RID};
```