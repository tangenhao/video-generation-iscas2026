for i in range(33):
  str = f"""        6'b{i:05b}: begin\n"""
  if i == 0:
    str += f"""          if (!synchronize_fifo_full) begin\n"""
    str += f"""            synchronize_fifo_wen_reg   <= 1'b1;\n"""
    str += f"""            synchronize_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];\n"""
    str += f"""            insn_buffer_index <= insn_buffer_index + 1;\n"""
    str += f"""          end\n"""
    str += f"""          else begin\n"""
    str += f"""            synchronize_fifo_wen_reg   <= 1'b0;\n"""
    str += f"""            synchronize_fifo_wdata_reg <= 0;\n"""
    str += f"""          end\n"""
    for j in range(0, 33):
      if j == 0:
        continue
      elif j <= 8:
        str += f"""          load_{j-1}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          load_{j-1}_fifo_wdata_reg  <= 0;\n"""
      elif j <= 16:
        str += f"""          store_{j-9}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          store_{j-9}_fifo_wdata_reg <= 0;\n"""
      elif j <= 24:
        str += f"""          pea_{j-17}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          pea_{j-17}_fifo_wdata_reg  <= 0;\n"""
      elif j <= 32:
        str += f"""          vcu_{j-25}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          vcu_{j-25}_fifo_wdata_reg  <= 0;\n"""
    str += f"""        end\n"""
  elif i <= 8:
    str += f"""          if (!load_{i-1}_fifo_full) begin\n"""
    str += f"""            load_{i-1}_fifo_wen_reg   <= 1'b1;\n"""
    str += f"""            load_{i-1}_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];\n"""
    str += f"""            insn_buffer_index <= insn_buffer_index + 1;\n"""
    str += f"""          end\n"""
    str += f"""          else begin\n"""
    str += f"""            load_{i-1}_fifo_wen_reg   <= 1'b0;\n"""
    str += f"""            load_{i-1}_fifo_wdata_reg <= 0;\n"""
    str += f"""          end\n"""
    for j in range(0, 33):
      if j == 0:
        str += f"""          synchronize_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          synchronize_fifo_wdata_reg <= 0;\n"""
      elif j <= 8 and j != i:
        str += f"""          load_{j-1}_fifo_wen_reg   <= 1'b1;\n"""
        str += f"""          load_{j-1}_fifo_wdata_reg <= 0;\n"""
      elif j <= 16 and j != i:
        str += f"""          store_{j-9}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          store_{j-9}_fifo_wdata_reg <= 0;\n"""
      elif j <= 24 and j != i:
        str += f"""          pea_{j-17}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          pea_{j-17}_fifo_wdata_reg  <= 0;\n"""
      elif j <= 32 and j != i:
        str += f"""          vcu_{j-25}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          vcu_{j-25}_fifo_wdata_reg  <= 0;\n"""
    str += f"""        end\n"""
  elif i <= 16:
    str += f"""          if (!store_{i-9}_fifo_full) begin\n"""
    str += f"""            store_{i-9}_fifo_wen_reg   <= 1'b1;\n"""
    str += f"""            store_{i-9}_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];\n"""
    str += f"""            insn_buffer_index <= insn_buffer_index + 1;\n"""
    str += f"""          end\n"""
    str += f"""          else begin\n"""
    str += f"""            store_{i-9}_fifo_wen_reg   <= 1'b0;\n"""
    str += f"""            store_{i-9}_fifo_wdata_reg <= 0;\n"""
    str += f"""          end\n"""
    for j in range(0, 33):
      if j == 0:
        str += f"""          synchronize_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          synchronize_fifo_wdata_reg <= 0;\n"""
      elif j <= 8:
        str += f"""          load_{j-1}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          load_{j-1}_fifo_wdata_reg <= 0;\n"""
      elif j <= 16 and j != i:
        str += f"""          store_{j-9}_fifo_wen_reg   <= 1'b1;\n"""
        str += f"""          store_{j-9}_fifo_wdata_reg <= 0;\n"""
      elif j <= 24 and j != i:
        str += f"""          pea_{j-17}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          pea_{j-17}_fifo_wdata_reg  <= 0;\n"""
      elif j <= 32 and j != i:
        str += f"""          vcu_{j-25}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          vcu_{j-25}_fifo_wdata_reg  <= 0;\n"""
    str += f"""        end\n"""
  elif i <= 24:
    str += f"""          if (!pea_{i-17}_fifo_full) begin\n"""
    str += f"""            pea_{i-17}_fifo_wen_reg   <= 1'b1;\n"""
    str += f"""            pea_{i-17}_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];\n"""
    str += f"""            insn_buffer_index <= insn_buffer_index + 1;\n"""
    str += f"""          end\n"""
    str += f"""          else begin\n"""
    str += f"""            pea_{i-17}_fifo_wen_reg   <= 1'b0;\n"""
    str += f"""            pea_{i-17}_fifo_wdata_reg <= 0;\n"""
    str += f"""          end\n"""
    for j in range(0, 33):
      if j == 0:
        str += f"""          synchronize_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          synchronize_fifo_wdata_reg <= 0;\n"""
      elif j <= 8:
        str += f"""          load_{j-1}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          load_{j-1}_fifo_wdata_reg <= 0;\n"""
      elif j <= 16:
        str += f"""          store_{j-9}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          store_{j-9}_fifo_wdata_reg <= 0;\n"""
      elif j <= 24 and j != i:
        str += f"""          pea_{j-17}_fifo_wen_reg   <= 1'b1;\n"""
        str += f"""          pea_{j-17}_fifo_wdata_reg <= 0;\n"""
      elif j <= 32 and j != i:
        str += f"""          vcu_{j-25}_fifo_wen_reg    <= 1'b0;\n"""
        str += f"""          vcu_{j-25}_fifo_wdata_reg  <= 0;\n"""
    str += f"""        end\n"""
  elif i <= 32:
    str += f"""          if (!vcu_{i-25}_fifo_full) begin\n"""
    str += f"""            vcu_{i-25}_fifo_wen_reg   <= 1'b1;\n"""
    str += f"""            vcu_{i-25}_fifo_wdata_reg <= insn_buffer_wire[insn_buffer_index];\n"""
    str += f"""            insn_buffer_index <= insn_buffer_index + 1;\n"""
    str += f"""          end\n"""
    str += f"""          else begin\n"""
    str += f"""            vcu_{i-25}_fifo_wen_reg   <= 1'b0;\n"""
    str += f"""            vcu_{i-25}_fifo_wdata_reg <= 0;\n"""
    str += f"""          end\n"""
    for j in range(0, 33):
      if j == 0:
        str += f"""          synchronize_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          synchronize_fifo_wdata_reg <= 0;\n"""
      elif j <= 8:
        str += f"""          load_{j-1}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          load_{j-1}_fifo_wdata_reg <= 0;\n"""
      elif j <= 16:
        str += f"""          store_{j-9}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          store_{j-9}_fifo_wdata_reg <= 0;\n"""
      elif j <= 24:
        str += f"""          pea_{j-17}_fifo_wen_reg   <= 1'b0;\n"""
        str += f"""          pea_{j-17}_fifo_wdata_reg <= 0;\n"""
      elif j <= 32 and j != i:
        str += f"""          vcu_{j-25}_fifo_wen_reg   <= 1'b1;\n"""
        str += f"""          vcu_{j-25}_fifo_wdata_reg <= 0;\n"""
    str += f"""        end\n"""
  
  print(str, end="")