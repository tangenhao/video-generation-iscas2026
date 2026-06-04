# ========================== 编译模式选项 ==========================
option(CONFIG_FOR_FPGA "Config for FPGA target (default: OFF for simulation)" OFF)
option(DEBUG_MODE "Enable debug mode (default: OFF)" OFF)  
option(SIM_MODE "Enable simulation mode for file output (default: OFF)" OFF)

# ========================== 设置预处理宏 ==========================
if(CONFIG_FOR_FPGA)
    add_definitions(-DCONFIG_FOR_FPGA)
endif()

if(DEBUG_MODE)
    add_definitions(-DDEBUG_MODE)
endif()

if(SIM_MODE)
    add_definitions(-DSIM_MODE)
endif()

# ========================== 显示编译配置 ==========================
if(CONFIG_FOR_FPGA)
    message(STATUS "   🎯 FPGA模式: ON")
    message(STATUS "     - 使用FPGA配置的SRAM深度")
    message(STATUS "     - IFMAP_DEPTH:  8192")
    message(STATUS "     - WEIGHT_DEPTH: 4096") 
    message(STATUS "     - PSUM_DEPTH:   32768")
    message(STATUS "     - OFMAP_DEPTH:  8192")
    message(STATUS "     - VCURES_DEPTH: 2048")
else()
    message(STATUS "   🎯 仿真模式: ON")
    message(STATUS "     - 使用仿真配置的SRAM深度")
    message(STATUS "     - IFMAP_DEPTH:  512")
    message(STATUS "     - WEIGHT_DEPTH: 2048")
    message(STATUS "     - PSUM_DEPTH:   1024") 
    message(STATUS "     - OFMAP_DEPTH:  2048")
    message(STATUS "     - VCURES_DEPTH: 1024")
endif()

if(DEBUG_MODE)
    message(STATUS "   🐛 调试模式: ON")
    message(STATUS "     - 启用详细调试信息")
    message(STATUS "     - _DEBUG = true")
else()
    message(STATUS "   🐛 调试模式: OFF")
    message(STATUS "     - _DEBUG = false")
endif()

if(SIM_MODE)
    message(STATUS "   📄 输出格式: 文本格式 (仿真)")
    message(STATUS "     - 指令文件: .txt格式")
    message(STATUS "     - VCU代码: .txt格式")
    message(STATUS "     - SIM = true")
else()
    message(STATUS "   📄 输出格式: 二进制格式 (FPGA)")
    message(STATUS "     - 指令文件: .bin格式") 
    message(STATUS "     - VCU代码: .bin格式")
    message(STATUS "     - SIM = false")
endif()

# ========================== 创建共享库 ==========================
add_library(npu_interface SHARED interface.cpp)
target_link_libraries(npu_interface dl)

set_target_properties(npu_interface PROPERTIES 
    OUTPUT_NAME "npu_interface"
    PREFIX "lib"
)

# 设置RPATH，让动态库能找到依赖
set_target_properties(npu_interface PROPERTIES
    INSTALL_RPATH "${CMAKE_SOURCE_DIR}/lib"
    BUILD_WITH_INSTALL_RPATH TRUE
)

add_custom_command(TARGET npu_interface POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:npu_interface> ${CMAKE_SOURCE_DIR}/lib/
    COMMENT "Copying NPU interface library to lib directory"
)
