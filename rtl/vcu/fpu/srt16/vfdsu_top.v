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
module vfdsu_top(
  clk,                 // clk
  rst_n,               // rst_n
  op0,                 // op0
  op1,                 // op1
  in_valid,            // input valid
  func,                // 10: sqrt; 01: div
  out_expt,            // expt output
  out_data,            // output
  out_valid,           // output valid
  busy                 // busy
);
  
input           clk;                            
input           rst_n;  
input   [31:0]  op0;     
input   [31:0]  op1;     
input           in_valid;                
input   [1 :0]  func;       
output  [4 :0]  out_expt;     
output  [31:0]  out_data;     
output          out_valid;        
output          busy;            
                 
wire            rst_n;   
wire    [31:0]  op0;     
wire    [31:0]  op1;    
wire            in_valid;      
wire            ex1_data_clk;                 
wire            ex1_div;                     
wire            ex1_pipedown;                 
wire            ex1_scalar;                   
wire            ex1_sqrt;                     
wire    [31:0]  ex1_src0;                     
wire    [31:0]  ex1_src1;                     
wire            ex2_data_clk;                 
wire            ex2_pipedown;                 
wire            ex2_srt_first_round;          
wire            ex3_data_clk;                 
wire            ex3_pipedown;                 
wire    [4 :0]  ex4_out_out_expt;                 
wire    [31:0]  ex4_out_result;               
wire            clk;               
wire    [1 :0]  func;       
wire    [4 :0]  out_expt;     
wire    [31:0]  out_data;     
wire            out_valid;      
wire            srt_ctrl_rem_zero;            
wire            srt_ctrl_skip_srt;            
wire            srt_secd_round;               
wire            srt_sm_on;                    
wire            busy;              

vfdsu_ctrl  x_vfdsu_ctrl (
  .rst_n                    (rst_n                   ),
  .in_valid     (in_valid    ),
  .ex1_data_clk                (ex1_data_clk               ),
  .ex1_pipedown                (ex1_pipedown               ),
  .ex2_data_clk                (ex2_data_clk               ),
  .ex2_pipedown                (ex2_pipedown               ),
  .ex2_srt_first_round         (ex2_srt_first_round        ),
  .ex3_data_clk                (ex3_data_clk               ),
  .ex3_pipedown                (ex3_pipedown               ),
  .clk              (clk             ),
  .out_valid     (out_valid    ),
  .srt_ctrl_rem_zero           (srt_ctrl_rem_zero          ),
  .srt_ctrl_skip_srt           (srt_ctrl_skip_srt          ),
  .srt_secd_round              (srt_secd_round             ),
  .srt_sm_on                   (srt_sm_on                  ),
  .busy          (busy         )
);

vfdsu_double  x_vfdsu_double (
  .rst_n            (rst_n           ),
  .ex1_div             (ex1_div            ),
  .ex1_pipedown        (ex1_pipedown       ),
  .ex1_scalar          (ex1_scalar         ),
  .ex1_sqrt            (ex1_sqrt           ),
  .ex1_src0            (ex1_src0           ),
  .ex1_src1            (ex1_src1           ),
  .ex2_pipedown        (ex2_pipedown       ),
  .ex2_srt_first_round (ex2_srt_first_round),
  .ex3_pipedown        (ex3_pipedown       ),
  .ex4_out_out_expt        (ex4_out_out_expt       ),
  .ex4_out_result      (ex4_out_result     ),
  .clk      (clk     ),
  .srt_ctrl_rem_zero   (srt_ctrl_rem_zero  ),
  .srt_ctrl_skip_srt   (srt_ctrl_skip_srt  ),
  .srt_secd_round      (srt_secd_round     ),
  .srt_sm_on           (srt_sm_on          )
);

vfdsu_scalar_dp  x_vfdsu_scalar_dp (
  .rst_n                      (rst_n                     ),
  .op0      (op0     ),
  .op1      (op1     ),
  .ex1_data_clk                  (ex1_data_clk                 ),
  .ex1_div                       (ex1_div                      ),
  .ex1_pipedown                  (ex1_pipedown                 ),
  .ex1_scalar                    (ex1_scalar                   ),
  .ex1_sqrt                      (ex1_sqrt                     ),
  .ex1_src0                      (ex1_src0                     ),
  .ex1_src1                      (ex1_src1                     ),
  .ex2_data_clk                  (ex2_data_clk                 ),
  .ex2_pipedown                  (ex2_pipedown                 ),
  .ex3_data_clk                  (ex3_data_clk                 ),
  .ex3_pipedown                  (ex3_pipedown                 ),
  .ex4_out_out_expt                  (ex4_out_out_expt                 ),
  .ex4_out_result                (ex4_out_result               ),
  .clk                (clk               ),
  .func        (func       ),
  .out_expt      (out_expt     ),
  .out_data      (out_data     )
);


// &ModuleEnd; @137
endmodule


