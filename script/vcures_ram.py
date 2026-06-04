bank_idx = 0

# ---------------------------------------------------------------------------------------------------------- #
#                                                  ren raddr                                                 #
# ---------------------------------------------------------------------------------------------------------- #

# for bank in range(16):
#   if bank < 10:
#     bank_name = bank
#   else:
#     bank_name = chr(bank + 87)
#   bank_idx = bank
#   pad_len = len("assign write_request_") + len(str(bank_idx)) + len(" = {")
#   align_len = len(str(bank_idx)) + 1 + len("_request_")
#   if bank == 0:
#     print(f"""
# wire [3:0] write_request_{bank_idx};
# wire [3:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_0_wvalid && vcures_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   elif bank == 4:
#     print(f"""
# wire [3:0] write_request_{bank_idx};
# wire [3:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_4_wvalid && vcures_4_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   elif bank == 8:
#       print(f"""
# wire [3:0] write_request_{bank_idx};
# wire [3:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_8_wvalid && vcures_8_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   elif bank == 12:
#       print(f"""
# wire [3:0] write_request_{bank_idx};
# wire [3:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_c_wvalid && vcures_c_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   elif bank < 4:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};
# reg  [4:0] write_grant_{bank_idx}_reg;

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_wvalid && vcures_{bank_name}_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_0_wvalid && vcures_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   elif bank < 8:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};
# reg  [4:0] write_grant_{bank_idx}_reg;

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_wvalid && vcures_{bank_name}_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_4_wvalid && vcures_4_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   elif bank < 12:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};
# reg  [4:0] write_grant_{bank_idx}_reg;

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_wvalid && vcures_{bank_name}_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_8_wvalid && vcures_8_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#   else:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};
# reg  [4:0] write_grant_{bank_idx}_reg;

# assign write_request_{bank_idx} = {{slave_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_1_wvalid && master_1_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_wvalid && vcures_{bank_name}_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}vcures_c_wvalid && vcures_c_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx},
# {" "*pad_len}master_0_wvalid && master_0_waddr[(VCURES_ADDR_BITS-2):(VCURES_ADDR_BITS-BANK_BITS-1)] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
    
#   print(f"assign wen[{bank_idx}] = |write_request_{bank_idx};")
#   pad_len = len("assign waddr[") + len(str(bank_idx)) + len("] = ")
#   if bank == 0:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_0_waddr[VCURES_ADDR_BITS-1], vcures_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_0_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[3] ? slave_wdata : 0;""")
#   elif bank == 4:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_4_waddr[VCURES_ADDR_BITS-1], vcures_4_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_4_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[3] ? slave_wdata : 0;""")
#   elif bank == 8:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_8_waddr[VCURES_ADDR_BITS-1], vcures_8_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_8_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[3] ? slave_wdata : 0;""")
#   elif bank == 12:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_c_waddr[VCURES_ADDR_BITS-1], vcures_c_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_c_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[3] ? slave_wdata : 0;""")
#   elif bank < 4:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_0_waddr[VCURES_ADDR_BITS-1], vcures_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[4] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_{bank_name}_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? vcures_0_data :
# {" "*pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#   elif bank < 8:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_4_waddr[VCURES_ADDR_BITS-1], vcures_4_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[4] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_{bank_name}_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? vcures_0_data :
# {" "*pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#   elif bank < 12:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_8_waddr[VCURES_ADDR_BITS-1], vcures_8_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[4] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_{bank_name}_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? vcures_0_data :
# {" "*pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#   else:
#     print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? {{master_0_waddr[VCURES_ADDR_BITS-1], master_0_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[1] ? {{vcures_c_waddr[VCURES_ADDR_BITS-1], vcures_c_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[2] ? {{vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[3] ? {{master_1_waddr[VCURES_ADDR_BITS-1], master_1_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} :
# {" "*pad_len}write_grant_{bank_idx}[4] ? {{slave_waddr[VCURES_ADDR_BITS-1], slave_waddr[VCURES_ADDR_BITS-1-BANK_BITS-1:0]}} : 0;
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*pad_len}write_grant_{bank_idx}[1] ? vcures_{bank_name}_data :
# {" "*pad_len}write_grant_{bank_idx}[2] ? vcures_0_data :
# {" "*pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")

# ---------------------------------------------------------------------------------------------------------- #
#                                                   wready                                                   #
# ---------------------------------------------------------------------------------------------------------- #
  
# print("assign master_0_wready = ", end="")    
# for i in range(16):
#   if i == 0:
#     print(f"write_grant_{i}[0]", end="")
#   else:
#     print(f" | write_grant_{i}[0]", end="")
# print(";")
# print("assign master_1_wready = ", end="")    
# for i in range(16):
#   if i == 0:
#     print(f"write_grant_{i}[2]", end="")
#   elif i % 4 == 0:
#     print(f" | write_grant_{i}[2]", end="")
#   else:
#     print(f" | write_grant_{i}[3]", end="")
# print(";")
# print("assign slave_wready = ", end="")    
# for i in range(16):
#   if i == 0:
#     print(f"write_grant_{i}[3]", end="")
#   elif i % 4 == 0:
#     print(f" | write_grant_{i}[3]", end="")
#   else:
#     print(f" | write_grant_{i}[4]", end="")
# print(";")

# bank_idx = 0
# for bank in range(16):
#   if bank < 10:
#     bank_name = bank
#   else:
#     bank_name = chr(bank + 87)
#   print(f"assign vcures_{bank_name}_wready = ", end="")
#   bank_idx = 0
#   if bank == 0:
#     for i in range(4):
#       bank_idx = i
#       if i == 0:
#         print(f"write_grant_{bank_idx}[1]", end="")
#       else:
#         print(f" | write_grant_{bank_idx}[1]", end="")
#     print(";")
#   elif bank == 4:
#     for i in range(4, 8):
#       bank_idx = i
#       if i == 4:
#         print(f"write_grant_{bank_idx}[1]", end="")
#       else:
#         print(f" | write_grant_{bank_idx}[1]", end="")
#     print(";")
#   elif bank == 8:
#     for i in range(8, 12):
#       bank_idx = i
#       if i == 8:
#         print(f"write_grant_{bank_idx}[1]", end="")
#       else:
#         print(f" | write_grant_{bank_idx}[1]", end="")
#     print(";")
#   elif bank == 12:
#     for i in range(12, 16):
#       bank_idx = i
#       if i == 12:
#         print(f"write_grant_{bank_idx}[1]", end="")
#       else:
#         print(f" | write_grant_{bank_idx}[1]", end="")
#     print(";")
#   else:
#     bank_idx = bank
#     print(f"write_grant_{bank_idx}[2]", end="")
#     print(";")


bank_idx = 0

# ---------------------------------------------------------------------------------------------------------- #
#                                                  ren raddr                                                 #
# ---------------------------------------------------------------------------------------------------------- #

# for bank in range(16):
#   if bank < 10:
#     bank_name = bank
#   else:
#     bank_name = chr(bank + 87)
#   bank_idx = bank
#   pad_len = len("assign read_request_") + len(str(bank_idx)) + len(" = {")
#   align_len = len(str(bank_idx)) + 1 + len("request_")
#   if bank == 0:
#     print(f"""
# wire [3:0] read_request_{bank_idx};
# wire [3:0] read_grant_{bank_idx};
# reg  [3:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_0_rvalid && vcures_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   elif bank == 4:
#     print(f"""
# wire [3:0] read_request_{bank_idx};
# wire [3:0] read_grant_{bank_idx};
# reg  [3:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_4_rvalid && vcures_4_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   elif bank == 8:
#     print(f"""
# wire [3:0] read_request_{bank_idx};
# wire [3:0] read_grant_{bank_idx};
# reg  [3:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_8_rvalid && vcures_8_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   elif bank == 12:
#     print(f"""
# wire [3:0] read_request_{bank_idx};
# wire [3:0] read_grant_{bank_idx};
# reg  [3:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_c_rvalid && vcures_c_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 4 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   elif bank < 4:
#     print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_rvalid && vcures_{bank_name}_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_0_rvalid && vcures_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   elif bank < 8:
#     print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_rvalid && vcures_{bank_name}_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_4_rvalid && vcures_4_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   elif bank < 12:
#     print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_rvalid && vcures_{bank_name}_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_8_rvalid && vcures_8_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#   else:
#     print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_{bank_name}_rvalid && vcures_{bank_name}_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}vcures_c_rvalid && vcures_c_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr[VCURES_ADDR_BITS-2:VCURES_ADDR_BITS-BANK_BITS-1] == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
    
#   print(f"""
# always @(posedge clk or negedge rst_n) begin
#   if (!rst_n) begin
#     read_grant_{bank_idx}_reg <= 'd0;
#   end
#   else begin
#     read_grant_{bank_idx}_reg <= read_grant_{bank_idx};
#   end
# end
# """)
    
#   print(f"assign ren[{bank_idx}] = |read_request_{bank_idx};")
#   pad_len = len("assign raddr[") + len(str(bank_idx)) + len("] = ")
#   if bank == 0:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_0_raddr[VCURES_ADDR_BITS-1], vcures_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   elif bank == 4:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_4_raddr[VCURES_ADDR_BITS-1], vcures_4_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   elif bank == 8:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_8_raddr[VCURES_ADDR_BITS-1], vcures_8_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   elif bank == 12:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_c_raddr[VCURES_ADDR_BITS-1], vcures_c_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   elif bank < 4:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_0_raddr[VCURES_ADDR_BITS-1], vcures_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{vcures_{bank_name}_raddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[4] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   elif bank < 8:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_4_raddr[VCURES_ADDR_BITS-1], vcures_4_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{vcures_{bank_name}_raddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[4] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   elif bank < 12:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_8_raddr[VCURES_ADDR_BITS-1], vcures_8_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{vcures_{bank_name}_raddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[4] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
#   else:
#     print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? {{master_0_raddr[VCURES_ADDR_BITS-1], master_0_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[1] ? {{vcures_c_raddr[VCURES_ADDR_BITS-1], vcures_c_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[2] ? {{vcures_{bank_name}_raddr[VCURES_ADDR_BITS-1], vcures_{bank_name}_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[3] ? {{master_1_raddr[VCURES_ADDR_BITS-1], master_1_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} :
# {" "*pad_len}read_grant_{bank_idx}[4] ? {{slave_raddr[VCURES_ADDR_BITS-1], slave_raddr[VCURES_ADDR_BITS-BANK_BITS-2:0]}} : 0;""")
  
# ---------------------------------------------------------------------------------------------------------- #
#                                                   rready                                                   #
# ---------------------------------------------------------------------------------------------------------- #
  
print("assign master_0_rready = ", end="")    
for i in range(16):
  if i == 0:
    print(f"read_grant_{i}[0]", end="")
  else:
    print(f" | read_grant_{i}[0]", end="")
print(";")
print("assign master_1_rready = ", end="")    
for i in range(16):
  if i == 0:
    print(f"read_grant_{i}[2]", end="")
  elif i % 4 == 0:
    print(f" | read_grant_{i}[2]", end="")
  else:
    print(f" | read_grant_{i}[3]", end="")
print(";")
print("assign slave_rready = ", end="")    
for i in range(16):
  if i == 0:
    print(f"read_grant_{i}[3]", end="")
  elif i % 4 == 0:
    print(f" | read_grant_{i}[3]", end="")
  else:
    print(f" | read_grant_{i}[4]", end="")
print(";")

bank_idx = 0
for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign vcures_{bank_name}_rready = ", end="")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      bank_idx = i
      if i == 0:
        print(f"read_grant_{bank_idx}[1]", end="")
      else:
        print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 4:
    for i in range(4, 8):
      bank_idx = i
      if i == 4:
        print(f"read_grant_{bank_idx}[1]", end="")
      else:
        print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 8:
    for i in range(8, 12):
      bank_idx = i
      if i == 8:
        print(f"read_grant_{bank_idx}[1]", end="")
      else:
        print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 12:
    for i in range(12, 16):
      bank_idx = i
      if i == 12:
        print(f"read_grant_{bank_idx}[1]", end="")
      else:
        print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  else:
    bank_idx = bank
    print(f"read_grant_{bank_idx}[2]", end="")
    print(";")
    
# ---------------------------------------------------------------------------------------------------------- #
#                                                    rdata                                                   #
# ---------------------------------------------------------------------------------------------------------- #
    
print("assign master_0_rdata = ", end="")
pad_len = len("assign master_0_rdata = ")
for i in range(16):
  if i == 0:
    print(f"read_grant_{i}_reg[0] ? rdata[{i}] :")
  elif i == 15:
    print(f"{' '*pad_len}read_grant_{i}_reg[0] ? rdata[{i}] : 0;")
  else:
    print(f"{' '*pad_len}read_grant_{i}_reg[0] ? rdata[{i}] :")
print()
print("assign master_1_rdata = ", end="")
pad_len = len("assign master_1_rdata = ")
for i in range(16):
  if i == 0:
    print(f"read_grant_{i}_reg[2] ? rdata[{i}] :")
  elif i % 4 == 0:
    print(f"{' '*pad_len}read_grant_{i}_reg[2] ? rdata[{i}] :")
  elif i == 15:
    print(f"{' '*pad_len}read_grant_{i}_reg[3] ? rdata[{i}] : 0;")
  else:
    print(f"{' '*pad_len}read_grant_{i}_reg[3] ? rdata[{i}] :")
print()
print("assign slave_rdata = ", end="")
pad_len = len("assign slave_rdata = ")
for i in range(16):
  if i == 0:
    print(f"read_grant_{i}_reg[3] ? rdata[{i}] :")
  elif i % 4 == 0:
    print(f"{' '*pad_len}read_grant_{i}_reg[3] ? rdata[{i}] :")
  elif i == 15:
    print(f"{' '*pad_len}read_grant_{i}_reg[4] ? rdata[{i}] : 0;")
  else:
    print(f"{' '*pad_len}read_grant_{i}_reg[4] ? rdata[{i}] :")
print()

for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign vcures_{bank_name}_rdata = ", end="")
  pad_len = len("assign vcures_") + len(str(bank_name)) + len("_rdata = ")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      bank_idx = i
      if i == 0:
        print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
      elif i == 3:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
      else:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  elif bank == 4:
    for i in range(4, 8):
      bank_idx = i
      if i == 4:
        print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
      elif i == 7:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
      else:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  elif bank == 8:
    for i in range(8, 12):
      bank_idx = i
      if i == 8:
        print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
      elif i == 11:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
      else:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  elif bank == 12:
    for i in range(12, 16):
      bank_idx = i
      if i == 12:
        print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
      elif i == 15:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
      else:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  else:
      bank_idx = bank
      print(f"read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] : 0;")
  print()
