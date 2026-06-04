create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_16x1024
set_property -dict [list \
  CONFIG.Component_Name {bram_16x1024} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Write_Width_A {16} \
] [get_ips bram_16x1024]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_16x2048
set_property -dict [list \
  CONFIG.Component_Name {bram_16x2048} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {2048} \
  CONFIG.Write_Width_A {16} \
] [get_ips bram_16x2048]


create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_32x512
set_property -dict [list \
  CONFIG.Component_Name {bram_32x512} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {512} \
  CONFIG.Write_Width_A {32} \
] [get_ips bram_32x512]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_64x128
set_property -dict [list \
  CONFIG.Component_Name {bram_64x128} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {128} \
  CONFIG.Write_Width_A {64} \
] [get_ips bram_64x128]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_64x512
set_property -dict [list \
  CONFIG.Component_Name {bram_64x512} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {512} \
  CONFIG.Write_Width_A {64} \
] [get_ips bram_64x512]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_128x8
set_property -dict [list \
  CONFIG.Component_Name {bram_128x8} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {8} \
  CONFIG.Write_Width_A {128} \
] [get_ips bram_128x8]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_128x128
set_property -dict [list \
  CONFIG.Component_Name {bram_128x128} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {128} \
  CONFIG.Write_Width_A {128} \
] [get_ips bram_128x128]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_128x1024
set_property -dict [list \
  CONFIG.Component_Name {bram_128x1024} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Write_Width_A {128} \
] [get_ips bram_128x1024]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_256x128
set_property -dict [list \
  CONFIG.Component_Name {bram_256x128} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {128} \
  CONFIG.Write_Width_A {256} \
] [get_ips bram_256x128]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_256x512
set_property -dict [list \
  CONFIG.Component_Name {bram_256x128} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {512} \
  CONFIG.Write_Width_A {256} \
] [get_ips bram_256x128]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_256x1024
set_property -dict [list \
  CONFIG.Component_Name {bram_256x1024} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Write_Width_A {256} \
] [get_ips bram_256x1024]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_512x128
set_property -dict [list \
  CONFIG.Component_Name {bram_512x128} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {128} \
  CONFIG.Write_Width_A {512} \
] [get_ips bram_512x128]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_512x1024
set_property -dict [list \
  CONFIG.Component_Name {bram_512x1024} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Write_Width_A {512} \
] [get_ips bram_512x1024]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_512x2048
set_property -dict [list \
  CONFIG.Component_Name {bram_512x2048} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {2048} \
  CONFIG.Write_Width_A {512} \
] [get_ips bram_512x2048]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_1024x64
set_property -dict [list \
  CONFIG.Component_Name {bram_1024x64} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {64} \
  CONFIG.Write_Width_A {1024} \
] [get_ips bram_1024x64]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_1024x512
set_property -dict [list \
  CONFIG.Component_Name {bram_1024x512} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {512} \
  CONFIG.Write_Width_A {1024} \
] [get_ips bram_1024x512]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_1024x1024
set_property -dict [list \
  CONFIG.Component_Name {bram_1024x1024} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Write_Width_A {1024} \
] [get_ips bram_1024x1024]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_8x128
set_property -dict [list \
  CONFIG.Component_Name {bram_8x128} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A {128} \
  CONFIG.Write_Width_A {8} \
] [get_ips bram_8x128]