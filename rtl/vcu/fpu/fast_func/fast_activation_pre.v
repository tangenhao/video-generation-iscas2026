module fast_activation_pre(
  data, index, data_out
);

input [31:0] data;
output [6:0] index;
output [18:0] data_out;

wire [22:0] dx;
wire [22:0] dx_shift;
wire [6:0] fake_index;

assign dx = {1'b1,data[22:1]};

assign dx_shift = (data[30:23] < 124 && data[30:23] >= 104) ? (dx >> (124 - data[30:23])) : 0;

assign fake_index = (data[30:23] < 104) ? 7'b0:
                                          (data[30:23] < 124) ? dx_shift[21:19] :
                                                                (data[30:23] > 130) ? 7'b0111111 : dx[21:19] + ((data[30:23] - 123) << 3);

assign data_out = (data[30:23] < 104) ? 19'b0 :
                                        (data[30:23] < 124) ? dx_shift[18:0] :
                                                              (data[30:23] > 130) ? 19'b0 : dx[18:0];

assign index = fake_index + ({7{!data[31]}} & 7'b1000000);

// always @(*) begin
//   if(~data[31]) begin
//     if(data[30:23]<104) begin
//       dx_shift = 0;
//       data_out = 19'b0;
//       index = 7'b1000000;
//     end
//     else if(data[30:23]<124) begin
//       dx_shift = dx >> (124 - data[30:23]);
//       data_out = dx_shift[18:0];
//       index = dx_shift[21:19] + 7'b1000000;      
//     end
//     else if(data[30:23]>130) begin
//       dx_shift = 0;
//       data_out = 19'b0;
//       index = 7'b1111111;
//     end
//     else begin
//       dx_shift = 0;
//       data_out = dx[18:0];
//       index = dx[21:19] + ((data[30:23] - 123) << 3) + 7'b1000000;
//     end
//   end
//   else begin
//     if(data[30:23]<104) begin
//       dx_shift = 0;
//       data_out = 19'b0;
//       index = 7'b0;
//     end
//     else if(data[30:23]<124) begin
//       dx_shift = dx >> (124 - data[30:23]);  
//       data_out = dx_shift[18:0];
//       index = dx_shift[21:19];      
//     end
//     else if(data[30:23]>130) begin
//       dx_shift = 0;
//       data_out = 19'b0;
//       index = 7'b0111111;
//     end
//     else begin
//       dx_shift = 0;
//       data_out = dx[18:0];
//       index = dx[21:19] + ((data[30:23] - 123) << 3);
//     end
//   end
// end
endmodule