import logging

bank_idx = 0

# ---------------------------------------------------------------------------------------------------------- #
#                                                  ren raddr                                                 #
# ---------------------------------------------------------------------------------------------------------- #

# for bank in range(16):
#   if bank < 10:
#     bank_name = bank
#   else:
#     bank_name = chr(bank + 87)
#   for pp in range(4):
#     bank_idx = pp + bank * 4
#     pad_len = len("assign read_request_") + len(str(bank_idx)) + len(" = {")
#     align_len = len(str(bank_idx)) + 1 + len("request_")
#     if bank == 0:
#       print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_0_rvalid && vcu_raddr_high_0 == {bank_idx},
# {" "*pad_len}pea_0_rvalid && pea_raddr_high_0 == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     elif bank == 4:
#       print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_4_rvalid && vcu_raddr_high_4 == {bank_idx},
# {" "*pad_len}pea_4_rvalid && pea_raddr_high_4 == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     elif bank == 8:
#       print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_8_rvalid && vcu_raddr_high_8 == {bank_idx},
# {" "*pad_len}pea_8_rvalid && pea_raddr_high_8 == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     elif bank == 12:
#       print(f"""
# wire [4:0] read_request_{bank_idx};
# wire [4:0] read_grant_{bank_idx};
# reg  [4:0] read_grant_{bank_idx}_reg;

# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_c_rvalid && vcu_raddr_high_c == {bank_idx},
# {" "*pad_len}pea_c_rvalid && pea_raddr_high_c == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 5 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     elif bank < 4:
#       print(f"""
# wire [6:0] read_request_{bank_idx};
# wire [6:0] read_grant_{bank_idx};
# reg  [6:0] read_grant_{bank_idx}_reg;
                        
# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_{bank_name}_rvalid && vcu_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}pea_{bank_name}_rvalid && pea_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}vcu_0_rvalid && vcu_raddr_high_0 == {bank_idx},
# {" "*pad_len}pea_0_rvalid && pea_raddr_high_0 == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 7 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     elif bank < 8:
#       print(f"""
# wire [6:0] read_request_{bank_idx};
# wire [6:0] read_grant_{bank_idx};
# reg  [6:0] read_grant_{bank_idx}_reg;
                        
# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_{bank_name}_rvalid && vcu_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}pea_{bank_name}_rvalid && pea_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}vcu_4_rvalid && vcu_raddr_high_4 == {bank_idx},
# {" "*pad_len}pea_4_rvalid && pea_raddr_high_4 == {bank_idx},
# {" "*pad_len}master_0_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 7 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     elif bank < 12:
#       print(f"""
# wire [6:0] read_request_{bank_idx};
# wire [6:0] read_grant_{bank_idx};
# reg  [6:0] read_grant_{bank_idx}_reg;
                        
# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_{bank_name}_rvalid && vcu_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}pea_{bank_name}_rvalid && pea_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}vcu_c_rvalid && vcu_raddr_high_c == {bank_idx},
# {" "*pad_len}pea_c_rvalid && pea_raddr_high_c == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 7 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
#     else:
#       print(f"""
# wire [6:0] read_request_{bank_idx};
# wire [6:0] read_grant_{bank_idx};
# reg  [6:0] read_grant_{bank_idx}_reg;
                        
# assign read_request_{bank_idx} = {{slave_rvalid && slave_raddr_high == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_1_raddr_high == {bank_idx},
# {" "*pad_len}vcu_{bank_name}_rvalid && vcu_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}pea_{bank_name}_rvalid && pea_raddr_high_{bank_name} == {bank_idx},
# {" "*pad_len}vcu_c_rvalid && vcu_raddr_high_c == {bank_idx},
# {" "*pad_len}pea_c_rvalid && pea_raddr_high_c == {bank_idx},
# {" "*pad_len}master_1_rvalid && master_0_raddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH ( 7 )
# ) u_round_robin_arbiter_read_{bank_idx} (
#   .clk     ( clk  {" "*align_len}),
#   .rst_n   ( rst_n{" "*align_len}),
#   .request ( read_request_{bank_idx} ),
#   .grant   ( read_grant_{bank_idx}   )
# );""")
    
#     print(f"""
# always @(posedge clk or negedge rst_n) begin
#   if (!rst_n) begin
#     read_grant_{bank_idx}_reg <= 'd0;
#   end
#   else begin
#     read_grant_{bank_idx}_reg <= read_grant_{bank_idx};
#   end
# end
# """)
    
#     print(f"assign ren[{bank_idx}] = |read_request_{bank_idx};")
#     pad_len = len("assign raddr[") + len(str(bank_idx)) + len("] = ")
#     if bank == 0:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     elif bank == 4:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_4_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_4_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     elif bank == 8:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_8_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_8_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     elif bank == 12:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_c_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_c_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     elif bank < 4:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? pea_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? vcu_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[5] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[6] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     elif bank < 8:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_4_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_4_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? pea_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? vcu_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[5] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[6] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     elif bank < 12:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_8_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_8_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? pea_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? vcu_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[5] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[6] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#     else:
#       print(f"""
# assign raddr[{bank_idx}] = read_grant_{bank_idx}[0] ? master_0_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[1] ? pea_c_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[2] ? vcu_c_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[3] ? pea_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[4] ? vcu_{bank_name}_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[5] ? master_1_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*pad_len}read_grant_{bank_idx}[6] ? slave_raddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
  
# ---------------------------------------------------------------------------------------------------------- #
#                                                   rready                                                   #
# ---------------------------------------------------------------------------------------------------------- #
  
print("assign master_0_rready = ", end="")    
for i in range(64):
  if i == 0:
    print(f"read_grant_{i}[0]", end="")
  else:
    print(f" | read_grant_{i}[0]", end="")
print(";")
print("assign master_1_rready = ", end="")    
for i in range(64):
  if i == 0:
    print(f"read_grant_{i}[3]", end="")
  elif i % 4 == 0:
    print(f" | read_grant_{i}[3]", end="")
  else:
    print(f" | read_grant_{i}[5]", end="")
print(";")
print("assign slave_rready = ", end="")    
for i in range(64):
  if i == 0:
    print(f"read_grant_{i}[4]", end="")
  elif i % 4 == 0:
    print(f" | read_grant_{i}[4]", end="")
  else:
    print(f" | read_grant_{i}[6]", end="")
print(";")

bank_idx = 0
for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign vcu_{bank_name}_rready = ", end="")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 0 and pp == 0:
          print(f"read_grant_{bank_idx}[2]", end="")
        else:
          print(f" | read_grant_{bank_idx}[2]", end="")
    print(";")
  elif bank == 4:
    for i in range(4, 8):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 4 and pp == 0:
          print(f"read_grant_{bank_idx}[2]", end="")
        else:
          print(f" | read_grant_{bank_idx}[2]", end="")
    print(";")
  elif bank == 8:
    for i in range(8, 12):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 8 and pp == 0:
          print(f"read_grant_{bank_idx}[2]", end="")
        else:
          print(f" | read_grant_{bank_idx}[2]", end="")
    print(";")
  elif bank == 12:
    for i in range(12, 16):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 12 and pp == 0:
          print(f"read_grant_{bank_idx}[2]", end="")
        else:
          print(f" | read_grant_{bank_idx}[2]", end="")
    print(";")
  else:
    for pp in range(4):
      bank_idx = pp + bank * 4
      if pp == 0:
        print(f"read_grant_{bank_idx}[4]", end="")
      else:
        print(f" | read_grant_{bank_idx}[4]", end="")
    print(";")
    

bank_idx = 0
for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign pea_{bank_name}_rready = ", end="")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 0 and pp == 0:
          print(f"read_grant_{bank_idx}[1]", end="")
        else:
          print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 4:
    for i in range(4, 8):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 4 and pp == 0:
          print(f"read_grant_{bank_idx}[1]", end="")
        else:
          print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 8:
    for i in range(8, 12):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 8 and pp == 0:
          print(f"read_grant_{bank_idx}[1]", end="")
        else:
          print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 12:
    for i in range(12, 16):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 12 and pp == 0:
          print(f"read_grant_{bank_idx}[1]", end="")
        else:
          print(f" | read_grant_{bank_idx}[1]", end="")
    print(";")
  else:
    for pp in range(4):
      bank_idx = pp + bank * 4
      if pp == 0:
        print(f"read_grant_{bank_idx}[3]", end="")
      else:
        print(f" | read_grant_{bank_idx}[3]", end="")
    print(";")

# ---------------------------------------------------------------------------------------------------------- #
#                                                    rdata                                                   #
# ---------------------------------------------------------------------------------------------------------- #
    
print("assign master_0_rdata = ", end="")
pad_len = len("assign master_0_rdata = ")
for i in range(64):
  if i == 0:
    print(f"read_grant_{i}_reg[0] ? rdata[{i}] :")
  elif i == 63:
    print(f"{' '*pad_len}read_grant_{i}_reg[0] ? rdata[{i}] : 0;")
  else:
    print(f"{' '*pad_len}read_grant_{i}_reg[0] ? rdata[{i}] :")
print()
print("assign master_1_rdata = ", end="")
pad_len = len("assign master_1_rdata = ")
for i in range(64):
  if i == 0:
    print(f"read_grant_{i}_reg[3] ? rdata[{i}] :")
  elif i % 4 == 0:
    print(f"{' '*pad_len}read_grant_{i}_reg[3] ? rdata[{i}] :")
  elif i == 63:
    print(f"{' '*pad_len}read_grant_{i}_reg[5] ? rdata[{i}] : 0;")
  else:
    print(f"{' '*pad_len}read_grant_{i}_reg[5] ? rdata[{i}] :")
print()
print("assign slave_rdata = ", end="")
pad_len = len("assign slave_rdata = ")
for i in range(64):
  if i == 0:
    print(f"read_grant_{i}_reg[4] ? rdata[{i}] :")
  elif i % 4 == 0:
    print(f"{' '*pad_len}read_grant_{i}_reg[4] ? rdata[{i}] :")
  elif i == 63:
    print(f"{' '*pad_len}read_grant_{i}_reg[6] ? rdata[{i}] : 0;")
  else:
    print(f"{' '*pad_len}read_grant_{i}_reg[6] ? rdata[{i}] :")
print()

for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign pea_{bank_name}_rdata = ", end="")
  pad_len = len("assign pea_") + len(str(bank_name)) + len("_rdata = ")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 0 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
        elif i == 3 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  elif bank == 4:
    for i in range(4, 8):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 4 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
        elif i == 7 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  elif bank == 8:
    for i in range(8, 12):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 8 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
        elif i == 11 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  elif bank == 12:
    for i in range(12, 16):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 12 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
        elif i == 15 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[1] ? rdata[{bank_idx}] :")
  else:
    for pp in range(4):
      bank_idx = pp + bank * 4
      if pp == 0:
        print(f"read_grant_{bank_idx}_reg[3] ? rdata[{bank_idx}] :")
      elif pp == 3:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[3] ? rdata[{bank_idx}] : 0;")
      else:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[3] ? rdata[{bank_idx}] :")
  print()

for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign vcu_{bank_name}_rdata = ", end="")
  pad_len = len("assign vcu_") + len(str(bank_name)) + len("_rdata = ")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 0 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
        elif i == 3 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
  elif bank == 4:
    for i in range(4, 8):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 4 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
        elif i == 7 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
  elif bank == 8:
    for i in range(8, 12):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 8 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
        elif i == 11 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
  elif bank == 12:
    for i in range(12, 16):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 12 and pp == 0:
          print(f"read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
        elif i == 15 and pp == 3:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] : 0;")
        else:
          print(f"{' '*pad_len}read_grant_{bank_idx}_reg[2] ? rdata[{bank_idx}] :")
  else:
    for pp in range(4):
      bank_idx = pp + bank * 4
      if pp == 0:
        print(f"read_grant_{bank_idx}_reg[4] ? rdata[{bank_idx}] :")
      elif pp == 3:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[4] ? rdata[{bank_idx}] : 0;")
      else:
        print(f"{' '*pad_len}read_grant_{bank_idx}_reg[4] ? rdata[{bank_idx}] :")
  print()

# ---------------------------------------------------------------------------------------------------------- #
#                                               wen waddr wdata                                              #
# ---------------------------------------------------------------------------------------------------------- #

# for bank in range(16):
#   if bank < 10:
#     bank_name = bank
#   else:
#     bank_name = chr(bank + 87)
#   for pp in range(4):
#     bank_idx = pp + bank * 4
#     req_pad_len = len("assign write_request_") + len(str(bank_idx)) + len(" = {")
#     arbiter_pad_len = len("request_") + len(str(bank_idx)) + 1
#     if bank == 0:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_0_wvalid && vcu_waddr_high_0 == {bank_idx},
# {" "*req_pad_len}pea_0_wvalid && pea_waddr_high_0 == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(5)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#     elif bank == 4:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_4_wvalid && vcu_waddr_high_4 == {bank_idx},
# {" "*req_pad_len}pea_4_wvalid && pea_waddr_high_4 == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(5)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#     elif bank == 8:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_8_wvalid && vcu_waddr_high_8 == {bank_idx},
# {" "*req_pad_len}pea_8_wvalid && pea_waddr_high_8 == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(5)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#     elif bank == 12:
#       print(f"""
# wire [4:0] write_request_{bank_idx};
# wire [4:0] write_grant_{bank_idx};

# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_c_wvalid && vcu_waddr_high_c == {bank_idx},
# {" "*req_pad_len}pea_c_wvalid && pea_waddr_high_c == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(5)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );""")
#     elif bank < 4:
#       print(f"""wire [6:0] write_request_{bank_idx};
# wire [6:0] write_grant_{bank_idx};
# reg  [6:0] write_grant_{bank_idx}_reg;
                        
# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_{bank_name}_wvalid && vcu_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}pea_{bank_name}_wvalid && pea_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}vcu_0_wvalid && vcu_waddr_high_0 == {bank_idx},
# {" "*req_pad_len}pea_0_wvalid && pea_waddr_high_0 == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(7)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );
# """)
#     elif bank < 8:
#       print(f"""wire [6:0] write_request_{bank_idx};
# wire [6:0] write_grant_{bank_idx};
# reg  [6:0] write_grant_{bank_idx}_reg;
                        
# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_{bank_name}_wvalid && vcu_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}pea_{bank_name}_wvalid && pea_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}vcu_4_wvalid && vcu_waddr_high_4 == {bank_idx},
# {" "*req_pad_len}pea_4_wvalid && pea_waddr_high_4 == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(7)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );
# """)
#     elif bank < 12:
#       print(f"""wire [6:0] write_request_{bank_idx};
# wire [6:0] write_grant_{bank_idx};
# reg  [6:0] write_grant_{bank_idx}_reg;
                        
# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_{bank_name}_wvalid && vcu_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}pea_{bank_name}_wvalid && pea_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}vcu_8_wvalid && vcu_waddr_high_8 == {bank_idx},
# {" "*req_pad_len}pea_8_wvalid && pea_waddr_high_8 == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(7)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );
# """)
#     else:
#       print(f"""wire [6:0] write_request_{bank_idx};
# wire [6:0] write_grant_{bank_idx};
# reg  [6:0] write_grant_{bank_idx}_reg;
                        
# assign write_request_{bank_idx} = {{slave_wvalid && slave_waddr_high == {bank_idx},
# {" "*req_pad_len}master_1_wvalid && master_1_waddr_high == {bank_idx},
# {" "*req_pad_len}vcu_{bank_name}_wvalid && vcu_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}pea_{bank_name}_wvalid && pea_waddr_high_{bank_name} == {bank_idx},
# {" "*req_pad_len}vcu_c_wvalid && vcu_waddr_high_c == {bank_idx},
# {" "*req_pad_len}pea_c_wvalid && pea_waddr_high_c == {bank_idx},
# {" "*req_pad_len}master_0_wvalid && master_0_waddr_high == {bank_idx}}};

# round_robin_arbiter #(
#   .REQUEST_WIDTH(7)
# ) u_round_robin_arbiter_write_{bank_idx} (
#   .clk     ( clk  {" "*arbiter_pad_len}),
#   .rst_n   ( rst_n{" "*arbiter_pad_len}),
#   .request ( write_request_{bank_idx} ),
#   .grant   ( write_grant_{bank_idx}   )
# );
# """)
#     waddr_pad_len = len("assign waddr[") + len(str(bank_idx)) + len("] = ")
#     wdata_pad_len = len("assign wdata[") + len(str(bank_idx)) + len("] = ")
#     print(f"assign wen[{bank_idx}] = |write_request_{bank_idx};")
#     if bank == 0:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#     elif bank == 4:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_4_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_4_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_4_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_4_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#     elif bank == 8:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_8_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_8_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_8_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_8_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#     elif bank == 12:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_12_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_12_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_12_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_12_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? slave_wdata : 0;""")
#     elif bank < 4:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[5] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[6] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[5] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[6] ? slave_wdata : 0;""")
#     elif bank < 8:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_4_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_4_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[5] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[6] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_4_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_4_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[5] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[6] ? slave_wdata : 0;""")
#     elif bank < 12:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_8_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_8_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[5] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[6] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_8_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_8_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[5] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[6] ? slave_wdata : 0;""")
#     else:
#       print(f"""
# assign waddr[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[1] ? pea_c_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[2] ? vcu_c_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[5] ? master_1_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] :
# {" "*waddr_pad_len}write_grant_{bank_idx}[6] ? slave_waddr[PSUM_ADDR_BITS-BANK_BITS-3:0] : 0;""")
#       print(f"""
# assign wdata[{bank_idx}] = write_grant_{bank_idx}[0] ? master_0_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[1] ? pea_c_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[2] ? vcu_c_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[3] ? pea_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[4] ? vcu_{bank_name}_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[5] ? master_1_wdata :
# {" "*wdata_pad_len}write_grant_{bank_idx}[6] ? slave_wdata : 0;""")

# ---------------------------------------------------------------------------------------------------------- #
#                                                   wready                                                   #
# ---------------------------------------------------------------------------------------------------------- #

print("assign master_0_wready = ", end="")
for i in range(64):
  if i == 0:
    print(f"write_grant_{i}[0]", end="")
  else:
    print(f" | write_grant_{i}[0]", end="")
print(";")
print()
print("assign master_1_wready = ", end="")
for i in range(64):
  if i == 0:
    print(f"write_grant_{i}[3]", end="")
  elif i % 4 == 0:
    print(f" | write_grant_{i}[3]", end="")
  else:
    print(f" | write_grant_{i}[5]", end="")
print(";")
print()
print("assign slave_wready = ", end="")
for i in range(64):
  if i == 0:
    print(f"write_grant_{i}[4]", end="")
  elif i % 4 == 0:
    print(f" | write_grant_{i}[4]", end="")
  else:
    print(f" | write_grant_{i}[6]", end="")
print(";")
print()

bank_idx = 0
for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign pea_{bank_name}_wready = ", end="")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 0 and pp == 0:
          print(f"write_grant_{bank_idx}[1]", end="")
        else:
          print(f" | write_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 4:
    for i in range(4, 8):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 4 and pp == 0:
          print(f"write_grant_{bank_idx}[1]", end="")
        else:
          print(f" | write_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 8:
    for i in range(8, 12):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 8 and pp == 0:
          print(f"write_grant_{bank_idx}[1]", end="")
        else:
          print(f" | write_grant_{bank_idx}[1]", end="")
    print(";")
  elif bank == 12:
    for i in range(12, 16):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 12 and pp == 0:
          print(f"write_grant_{bank_idx}[1]", end="")
        else:
          print(f" | write_grant_{bank_idx}[1]", end="")
    print(";")
  else:
    for pp in range(4):
      bank_idx = pp + bank * 4
      if pp == 0:
        print(f"write_grant_{bank_idx}[3]", end="")
      else:
        print(f" | write_grant_{bank_idx}[3]", end="")
    print(";")
bank_idx = 0
for bank in range(16):
  if bank < 10:
    bank_name = bank
  else:
    bank_name = chr(bank + 87)
  print(f"assign vcu_{bank_name}_wready = ", end="")
  bank_idx = 0
  if bank == 0:
    for i in range(4):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 0 and pp == 0:
          print(f"write_grant_{bank_idx}[2]", end="")
        else:
          print(f" | write_grant_{bank_idx}[2]", end="")
    print(";")
  elif bank == 4:
    for i in range(4, 8):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 4 and pp == 0:
          print(f"write_grant_{bank_idx}[2]", end="")
        else:
          print(f" | write_grant_{bank_idx}[2]", end="")
    print(";")
  elif bank == 8:
    for i in range(8, 12):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 8 and pp == 0:
          print(f"write_grant_{bank_idx}[2]", end="")
        else:
          print(f" | write_grant_{bank_idx}[2]", end="")
    print(";")
  elif bank == 12:
    for i in range(12, 16):
      for pp in range(4):
        bank_idx = pp + i * 4
        if i == 12 and pp == 0:
          print(f"write_grant_{bank_idx}[2]", end="")
        else:
          print(f" | write_grant_{bank_idx}[2]", end="")
    print(";")
  else:
    for pp in range(4):
      bank_idx = pp + bank * 4
      if pp == 0:
        print(f"write_grant_{bank_idx}[4]", end="")
      else:
        print(f" | write_grant_{bank_idx}[4]", end="")
    print(";")