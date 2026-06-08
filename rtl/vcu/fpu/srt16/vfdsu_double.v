/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// &Depend("cpu_cfig.h"); @22
// &ModuleBeg; @23
module vfdsu_double(
  rst_n,
  ex1_div,
  ex1_pipedown,
  ex1_scalar,
  ex1_sqrt,
  ex1_src0,
  ex1_src1,
  ex2_pipedown,
  ex2_srt_first_round,
  ex3_pipedown,
  ex4_out_out_expt,
  ex4_out_result,
  clk,
  srt_ctrl_rem_zero,
  srt_ctrl_skip_srt,
  srt_secd_round,
  srt_sm_on
);
                                           
input           rst_n;  
input           ex1_div;                              
input           ex1_pipedown;                         
input           ex1_scalar;                           
input           ex1_sqrt;                             
input   [31:0]  ex1_src0;                             
input   [31:0]  ex1_src1;                             
input           ex2_pipedown;                         
input           ex2_srt_first_round;                  
input           ex3_pipedown;                         
input           clk;                        
input           srt_secd_round;                       
input           srt_sm_on;                               
output  [4 :0]  ex4_out_out_expt;                         
output  [31:0]  ex4_out_result;                       
output          srt_ctrl_rem_zero;                    
output          srt_ctrl_skip_srt;                    
                                       
wire            rst_n;  
wire            ex1_div;                              
wire    [23:0]  ex1_divisor;                          
wire            ex1_pipedown;                         
wire    [30:0]  ex1_remainder;                        
wire            ex1_scalar;                            
wire            ex1_sqrt;                             
wire    [31:0]  ex1_src0;                             
wire    [31:0]  ex1_src1;                              
wire            ex2_pipedown;                         
wire            ex2_srt_first_round;                  
wire            ex3_pipedown;                         
wire    [4 :0]  ex4_out_out_expt;                         
wire    [31:0]  ex4_out_result;                       
wire            clk;                       
wire            srt_ctrl_rem_zero;                    
wire            srt_ctrl_skip_srt;                    
wire            srt_secd_round;                       
wire            srt_sm_on;                            
wire    [31:0]  total_qt_rt_58;                       
wire            vfdsu_ex2_div;                        
wire            vfdsu_ex2_dz;                         
wire    [9 :0]  vfdsu_ex2_expnt_add0;                 
wire    [9 :0]  vfdsu_ex2_expnt_add1;                 
wire            vfdsu_ex2_nv;                         
wire            vfdsu_ex2_of_rm_lfn;                  
wire            vfdsu_ex2_op0_norm;                   
wire            vfdsu_ex2_op1_norm;                   
wire    [22:0]  vfdsu_ex2_qnan_f;                     
wire            vfdsu_ex2_qnan_sign;                  
wire            vfdsu_ex2_result_inf;                 
wire            vfdsu_ex2_result_qnan;                
wire            vfdsu_ex2_result_sign;                
wire            vfdsu_ex2_result_zero;                
wire    [2 :0]  vfdsu_ex2_rm;                        
wire            vfdsu_ex2_sqrt;                       
wire            vfdsu_ex2_srt_skip;                           
wire            vfdsu_ex3_dz;                         
wire    [9 :0]  vfdsu_ex3_expnt_rst;             
wire            vfdsu_ex3_id_srt_skip;                
wire            vfdsu_ex3_nv;                         
wire            vfdsu_ex3_of;                         
wire            vfdsu_ex3_potnt_of;                   
wire            vfdsu_ex3_potnt_uf;                   
wire    [22:0]  vfdsu_ex3_qnan_f;                     
wire            vfdsu_ex3_qnan_sign;                  
wire            vfdsu_ex3_rem_sign;                   
wire            vfdsu_ex3_rem_zero;                   
wire    [23:0]  vfdsu_ex3_result_denorm_round_add_num; 
wire            vfdsu_ex3_result_inf;                 
wire            vfdsu_ex3_result_lfn;                 
wire            vfdsu_ex3_result_qnan;                
wire            vfdsu_ex3_result_sign;                
wire            vfdsu_ex3_result_zero;                
wire    [2 :0]  vfdsu_ex3_rm;                         
wire            vfdsu_ex3_rslt_denorm;                
wire            vfdsu_ex3_uf;                         
wire            vfdsu_ex4_denorm_to_tiny_frac;       
wire            vfdsu_ex4_dz;                         
wire    [9 :0]  vfdsu_ex4_expnt_rst;                  
wire    [25:0]  vfdsu_ex4_frac;                       
wire            vfdsu_ex4_nv;                         
wire            vfdsu_ex4_nx;                         
wire            vfdsu_ex4_of;                         
wire            vfdsu_ex4_of_rst_lfn;                 
wire    [1 :0]  vfdsu_ex4_potnt_norm;                 
wire            vfdsu_ex4_potnt_of;                   
wire            vfdsu_ex4_potnt_uf;                   
wire    [22:0]  vfdsu_ex4_qnan_f;                     
wire            vfdsu_ex4_qnan_sign;                  
wire            vfdsu_ex4_result_inf;                 
wire            vfdsu_ex4_result_lfn;                 
wire            vfdsu_ex4_result_nor;                 
wire            vfdsu_ex4_result_qnan;                
wire            vfdsu_ex4_result_sign;                
wire            vfdsu_ex4_result_zero;                
wire            vfdsu_ex4_rslt_denorm;                
wire            vfdsu_ex4_uf;                           

vfdsu_prepare  x_vfdsu_prepare (
  .rst_n              (rst_n             ),
  .ex1_div               (ex1_div              ),
  .ex1_divisor           (ex1_divisor          ),
  .ex1_pipedown          (ex1_pipedown         ),
  .ex1_remainder         (ex1_remainder        ),
  .ex1_scalar            (ex1_scalar           ),
  .ex1_sqrt              (ex1_sqrt             ),
  .ex1_src0              (ex1_src0             ),
  .ex1_src1              (ex1_src1             ),
  .clk        (clk       ),
  .vfdsu_ex2_div         (vfdsu_ex2_div        ),
  .vfdsu_ex2_dz          (vfdsu_ex2_dz         ),
  .vfdsu_ex2_expnt_add0  (vfdsu_ex2_expnt_add0 ),
  .vfdsu_ex2_expnt_add1  (vfdsu_ex2_expnt_add1 ),
  .vfdsu_ex2_nv          (vfdsu_ex2_nv         ),
  .vfdsu_ex2_of_rm_lfn   (vfdsu_ex2_of_rm_lfn  ),
  .vfdsu_ex2_op0_norm    (vfdsu_ex2_op0_norm   ),
  .vfdsu_ex2_op1_norm    (vfdsu_ex2_op1_norm   ),
  .vfdsu_ex2_qnan_f      (vfdsu_ex2_qnan_f     ),
  .vfdsu_ex2_qnan_sign   (vfdsu_ex2_qnan_sign  ),
  .vfdsu_ex2_result_inf  (vfdsu_ex2_result_inf ),
  .vfdsu_ex2_result_qnan (vfdsu_ex2_result_qnan),
  .vfdsu_ex2_result_sign (vfdsu_ex2_result_sign),
  .vfdsu_ex2_result_zero (vfdsu_ex2_result_zero),
  .vfdsu_ex2_rm          (vfdsu_ex2_rm         ),
  .vfdsu_ex2_sqrt        (vfdsu_ex2_sqrt       ),
  .vfdsu_ex2_srt_skip    (vfdsu_ex2_srt_skip   )
);

vfdsu_srt  x_vfdsu_srt (
  .rst_n                              (rst_n                             ),
  .ex1_div                               (ex1_div                              ),
  .ex1_divisor                           (ex1_divisor                          ),
  .ex1_pipedown                          (ex1_pipedown                         ),
  .ex1_remainder                         (ex1_remainder                        ),
  .ex1_sqrt                              (ex1_sqrt                             ),
  .ex2_pipedown                          (ex2_pipedown                         ),
  .ex2_srt_first_round                   (ex2_srt_first_round                  ),
  .clk                        (clk                       ),
  .srt_ctrl_rem_zero                     (srt_ctrl_rem_zero                    ),
  .srt_ctrl_skip_srt                     (srt_ctrl_skip_srt                    ),
  .srt_secd_round                        (srt_secd_round                       ),
  .srt_sm_on                             (srt_sm_on                            ),
  .total_qt_rt_58                        (total_qt_rt_58                       ),
  .vfdsu_ex2_div                         (vfdsu_ex2_div                        ),
  .vfdsu_ex2_dz                          (vfdsu_ex2_dz                         ),
  .vfdsu_ex2_expnt_add0                  (vfdsu_ex2_expnt_add0                 ),
  .vfdsu_ex2_expnt_add1                  (vfdsu_ex2_expnt_add1                 ),
  .vfdsu_ex2_nv                          (vfdsu_ex2_nv                         ),
  .vfdsu_ex2_of_rm_lfn                   (vfdsu_ex2_of_rm_lfn                  ),
  .vfdsu_ex2_op0_norm                    (vfdsu_ex2_op0_norm                   ),
  .vfdsu_ex2_op1_norm                    (vfdsu_ex2_op1_norm                   ),
  .vfdsu_ex2_qnan_f                      (vfdsu_ex2_qnan_f                     ),
  .vfdsu_ex2_qnan_sign                   (vfdsu_ex2_qnan_sign                  ),
  .vfdsu_ex2_result_inf                  (vfdsu_ex2_result_inf                 ),
  .vfdsu_ex2_result_qnan                 (vfdsu_ex2_result_qnan                ),
  .vfdsu_ex2_result_sign                 (vfdsu_ex2_result_sign                ),
  .vfdsu_ex2_result_zero                 (vfdsu_ex2_result_zero                ),
  .vfdsu_ex2_rm                          (vfdsu_ex2_rm                         ),
  .vfdsu_ex2_sqrt                        (vfdsu_ex2_sqrt                       ),
  .vfdsu_ex2_srt_skip                    (vfdsu_ex2_srt_skip                   ),
  .vfdsu_ex3_dz                          (vfdsu_ex3_dz                         ),
  .vfdsu_ex3_expnt_rst                   (vfdsu_ex3_expnt_rst                  ),
  .vfdsu_ex3_id_srt_skip                 (vfdsu_ex3_id_srt_skip                ),
  .vfdsu_ex3_nv                          (vfdsu_ex3_nv                         ),
  .vfdsu_ex3_of                          (vfdsu_ex3_of                         ),
  .vfdsu_ex3_potnt_of                    (vfdsu_ex3_potnt_of                   ),
  .vfdsu_ex3_potnt_uf                    (vfdsu_ex3_potnt_uf                   ),
  .vfdsu_ex3_qnan_f                      (vfdsu_ex3_qnan_f                     ),
  .vfdsu_ex3_qnan_sign                   (vfdsu_ex3_qnan_sign                  ),
  .vfdsu_ex3_rem_sign                    (vfdsu_ex3_rem_sign                   ),
  .vfdsu_ex3_rem_zero                    (vfdsu_ex3_rem_zero                   ),
  .vfdsu_ex3_result_denorm_round_add_num (vfdsu_ex3_result_denorm_round_add_num),
  .vfdsu_ex3_result_inf                  (vfdsu_ex3_result_inf                 ),
  .vfdsu_ex3_result_lfn                  (vfdsu_ex3_result_lfn                 ),
  .vfdsu_ex3_result_qnan                 (vfdsu_ex3_result_qnan                ),
  .vfdsu_ex3_result_sign                 (vfdsu_ex3_result_sign                ),
  .vfdsu_ex3_result_zero                 (vfdsu_ex3_result_zero                ),
  .vfdsu_ex3_rm                          (vfdsu_ex3_rm                         ),
  .vfdsu_ex3_rslt_denorm                 (vfdsu_ex3_rslt_denorm                ),
  .vfdsu_ex3_uf                          (vfdsu_ex3_uf                         )
);

vfdsu_round  x_vfdsu_round (
  .rst_n                              (rst_n                             ),
  .ex3_pipedown                          (ex3_pipedown                         ),
  .clk                        (clk                       ),
  .total_qt_rt_58                        (total_qt_rt_58                       ),
  .vfdsu_ex2_of_rm_lfn                   (vfdsu_ex2_of_rm_lfn                  ),
  .vfdsu_ex3_expnt_rst                   (vfdsu_ex3_expnt_rst                  ),
  .vfdsu_ex3_dz                          (vfdsu_ex3_dz                         ),
  .vfdsu_ex3_id_srt_skip                 (vfdsu_ex3_id_srt_skip                ),
  .vfdsu_ex3_nv                          (vfdsu_ex3_nv                         ),
  .vfdsu_ex3_of                          (vfdsu_ex3_of                         ),
  .vfdsu_ex3_potnt_of                    (vfdsu_ex3_potnt_of                   ),
  .vfdsu_ex3_potnt_uf                    (vfdsu_ex3_potnt_uf                   ),
  .vfdsu_ex3_qnan_f                      (vfdsu_ex3_qnan_f                     ),
  .vfdsu_ex3_qnan_sign                   (vfdsu_ex3_qnan_sign                  ),
  .vfdsu_ex3_rem_sign                    (vfdsu_ex3_rem_sign                   ),
  .vfdsu_ex3_rem_zero                    (vfdsu_ex3_rem_zero                   ),
  .vfdsu_ex3_result_denorm_round_add_num (vfdsu_ex3_result_denorm_round_add_num),
  .vfdsu_ex3_result_inf                  (vfdsu_ex3_result_inf                 ),
  .vfdsu_ex3_result_lfn                  (vfdsu_ex3_result_lfn                 ),
  .vfdsu_ex3_result_qnan                 (vfdsu_ex3_result_qnan                ),
  .vfdsu_ex3_result_sign                 (vfdsu_ex3_result_sign                ),
  .vfdsu_ex3_result_zero                 (vfdsu_ex3_result_zero                ),
  .vfdsu_ex3_rm                          (vfdsu_ex3_rm                         ),
  .vfdsu_ex3_rslt_denorm                 (vfdsu_ex3_rslt_denorm                ),
  .vfdsu_ex3_uf                          (vfdsu_ex3_uf                         ),
  .vfdsu_ex4_denorm_to_tiny_frac         (vfdsu_ex4_denorm_to_tiny_frac        ),
  .vfdsu_ex4_dz                          (vfdsu_ex4_dz                         ),
  .vfdsu_ex4_expnt_rst                   (vfdsu_ex4_expnt_rst                  ),
  .vfdsu_ex4_frac                        (vfdsu_ex4_frac                       ),
  .vfdsu_ex4_nv                          (vfdsu_ex4_nv                         ),
  .vfdsu_ex4_nx                          (vfdsu_ex4_nx                         ),
  .vfdsu_ex4_of                          (vfdsu_ex4_of                         ),
  .vfdsu_ex4_of_rst_lfn                  (vfdsu_ex4_of_rst_lfn                 ),
  .vfdsu_ex4_potnt_norm                  (vfdsu_ex4_potnt_norm                 ),
  .vfdsu_ex4_potnt_of                    (vfdsu_ex4_potnt_of                   ),
  .vfdsu_ex4_potnt_uf                    (vfdsu_ex4_potnt_uf                   ),
  .vfdsu_ex4_qnan_f                      (vfdsu_ex4_qnan_f                     ),
  .vfdsu_ex4_qnan_sign                   (vfdsu_ex4_qnan_sign                  ),
  .vfdsu_ex4_result_inf                  (vfdsu_ex4_result_inf                 ),
  .vfdsu_ex4_result_lfn                  (vfdsu_ex4_result_lfn                 ),
  .vfdsu_ex4_result_nor                  (vfdsu_ex4_result_nor                 ),
  .vfdsu_ex4_result_qnan                 (vfdsu_ex4_result_qnan                ),
  .vfdsu_ex4_result_sign                 (vfdsu_ex4_result_sign                ),
  .vfdsu_ex4_result_zero                 (vfdsu_ex4_result_zero                ),
  .vfdsu_ex4_rslt_denorm                 (vfdsu_ex4_rslt_denorm                ),
  .vfdsu_ex4_uf                          (vfdsu_ex4_uf                         )
);

vfdsu_pack  x_vfdsu_pack (
  .ex4_out_out_expt                  (ex4_out_out_expt                 ),
  .ex4_out_result                (ex4_out_result               ),
  .vfdsu_ex4_denorm_to_tiny_frac (vfdsu_ex4_denorm_to_tiny_frac),
  .vfdsu_ex4_dz                  (vfdsu_ex4_dz                 ),
  .vfdsu_ex4_expnt_rst           (vfdsu_ex4_expnt_rst          ),
  .vfdsu_ex4_frac                (vfdsu_ex4_frac               ),
  .vfdsu_ex4_nv                  (vfdsu_ex4_nv                 ),
  .vfdsu_ex4_nx                  (vfdsu_ex4_nx                 ),
  .vfdsu_ex4_of                  (vfdsu_ex4_of                 ),
  .vfdsu_ex4_of_rst_lfn          (vfdsu_ex4_of_rst_lfn         ),
  .vfdsu_ex4_potnt_norm          (vfdsu_ex4_potnt_norm         ),
  .vfdsu_ex4_potnt_of            (vfdsu_ex4_potnt_of           ),
  .vfdsu_ex4_potnt_uf            (vfdsu_ex4_potnt_uf           ),
  .vfdsu_ex4_qnan_f              (vfdsu_ex4_qnan_f             ),
  .vfdsu_ex4_qnan_sign           (vfdsu_ex4_qnan_sign          ),
  .vfdsu_ex4_result_inf          (vfdsu_ex4_result_inf         ),
  .vfdsu_ex4_result_lfn          (vfdsu_ex4_result_lfn         ),
  .vfdsu_ex4_result_nor          (vfdsu_ex4_result_nor         ),
  .vfdsu_ex4_result_qnan         (vfdsu_ex4_result_qnan        ),
  .vfdsu_ex4_result_sign         (vfdsu_ex4_result_sign        ),
  .vfdsu_ex4_result_zero         (vfdsu_ex4_result_zero        ),
  .vfdsu_ex4_rslt_denorm         (vfdsu_ex4_rslt_denorm        ),
  .vfdsu_ex4_uf                  (vfdsu_ex4_uf                 )
);



// &ModuleEnd; @34
endmodule


