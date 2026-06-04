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
module vfdsu_ff1(
  fanc_shift_num,
  frac_bin_val,
  frac_num
);

input   [22:0]  frac_num;      
output  [22:0]  fanc_shift_num; 
output  [9:0]  frac_bin_val;  

reg     [22:0]  fanc_shift_num; 
reg     [9:0]  frac_bin_val;  

wire    [22:0]  frac_num;      

always @( frac_num[22:0])
begin
casez(frac_num[22:0])
  23'b1??????????????????????: begin frac_bin_val[9:0] = 10'h0;   fanc_shift_num[22:0] =  frac_num[22:0]      ;end
  23'b01?????????????????????: begin frac_bin_val[9:0] = 10'h3ff; fanc_shift_num[22:0] = {frac_num[21:0],1'b0};end
  23'b001????????????????????: begin frac_bin_val[9:0] = 10'h3fe; fanc_shift_num[22:0] = {frac_num[20:0],2'b0};end
  23'b0001???????????????????: begin frac_bin_val[9:0] = 10'h3fd; fanc_shift_num[22:0] = {frac_num[19:0],3'b0};end
  23'b00001??????????????????: begin frac_bin_val[9:0] = 10'h3fc; fanc_shift_num[22:0] = {frac_num[18:0],4'b0};end
  23'b000001?????????????????: begin frac_bin_val[9:0] = 10'h3fb; fanc_shift_num[22:0] = {frac_num[17:0],5'b0};end
  23'b0000001????????????????: begin frac_bin_val[9:0] = 10'h3fa; fanc_shift_num[22:0] = {frac_num[16:0],6'b0};end
  23'b00000001???????????????: begin frac_bin_val[9:0] = 10'h3f9; fanc_shift_num[22:0] = {frac_num[15:0],7'b0};end
  23'b000000001??????????????: begin frac_bin_val[9:0] = 10'h3f8; fanc_shift_num[22:0] = {frac_num[14:0],8'b0};end
  23'b0000000001?????????????: begin frac_bin_val[9:0] = 10'h3f7; fanc_shift_num[22:0] = {frac_num[13:0],9'b0};end
  23'b00000000001????????????: begin frac_bin_val[9:0] = 10'h3f6; fanc_shift_num[22:0] = {frac_num[12:0],10'b0};end
  23'b000000000001???????????: begin frac_bin_val[9:0] = 10'h3f5; fanc_shift_num[22:0] = {frac_num[11:0],11'b0};end
  23'b0000000000001??????????: begin frac_bin_val[9:0] = 10'h3f4; fanc_shift_num[22:0] = {frac_num[10:0],12'b0};end
  23'b00000000000001?????????: begin frac_bin_val[9:0] = 10'h3f3; fanc_shift_num[22:0] = {frac_num[9 :0],13'b0};end
  23'b000000000000001????????: begin frac_bin_val[9:0] = 10'h3f2; fanc_shift_num[22:0] = {frac_num[8 :0],14'b0};end
  23'b0000000000000001???????: begin frac_bin_val[9:0] = 10'h3f1; fanc_shift_num[22:0] = {frac_num[7 :0],15'b0};end
  23'b00000000000000001??????: begin frac_bin_val[9:0] = 10'h3f0; fanc_shift_num[22:0] = {frac_num[6 :0],16'b0};end
  23'b000000000000000001?????: begin frac_bin_val[9:0] = 10'h3ef; fanc_shift_num[22:0] = {frac_num[5 :0],17'b0};end
  23'b0000000000000000001????: begin frac_bin_val[9:0] = 10'h3ee; fanc_shift_num[22:0] = {frac_num[4 :0],18'b0};end
  23'b00000000000000000001???: begin frac_bin_val[9:0] = 10'h3ed; fanc_shift_num[22:0] = {frac_num[3 :0],19'b0};end
  23'b000000000000000000001??: begin frac_bin_val[9:0] = 10'h3ec; fanc_shift_num[22:0] = {frac_num[2 :0],20'b0};end
  23'b0000000000000000000001?: begin frac_bin_val[9:0] = 10'h3eb; fanc_shift_num[22:0] = {frac_num[1 :0],21'b0};end
  23'b00000000000000000000001: begin frac_bin_val[9:0] = 10'h3ea; fanc_shift_num[22:0] = {frac_num[0]   ,22'b0};end
  23'b00000000000000000000000: begin frac_bin_val[9:0] = 10'h3e9; fanc_shift_num[22:0] =                 23'b0 ;end
  default:begin frac_bin_val[9:0] = 10'h000;     fanc_shift_num[22:0] = {23'b0};end
endcase 

end

endmodule


