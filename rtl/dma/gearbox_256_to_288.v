module gearbox_256_to_288 #(
  parameter WORD_W      = 32,
  parameter IN_WORDS    = 8,   // 8*32 = 256b
  parameter OUT_WORDS   = 9    // 9*32 = 288b
)(
  input  wire                           clk,
  input  wire                           rst_n,
  input  wire                           restart,

  input  wire                           valid_data_in,
  input  wire [IN_WORDS*WORD_W-1:0]     data_in,

  output wire                           valid_data_out,
  output wire [OUT_WORDS*WORD_W-1:0]    data_out
);
  // Fixed 256b -> 288b gearbox: two 256b frames (prev/curr), 8 output phases.
  reg [255:0] prev_data;
  reg [255:0] curr_data;
  reg         prev_valid, curr_valid;
  reg [3:0]   phase; // 8..1 are output phases; 0 is the refill bubble.

  reg [287:0] stitch_pc;
  always @(*) begin
    case (phase)
      4'd8: stitch_pc = {curr_data[ 31:  0], prev_data[255:  0]};
      4'd7: stitch_pc = {curr_data[ 63:  0], prev_data[255: 32]};
      4'd6: stitch_pc = {curr_data[ 95:  0], prev_data[255: 64]};
      4'd5: stitch_pc = {curr_data[127:  0], prev_data[255: 96]};
      4'd4: stitch_pc = {curr_data[159:  0], prev_data[255:128]};
      4'd3: stitch_pc = {curr_data[191:  0], prev_data[255:160]};
      4'd2: stitch_pc = {curr_data[223:  0], prev_data[255:192]};
      4'd1: stitch_pc = {curr_data[255:  0], prev_data[255:224]};
      default: stitch_pc = 288'd0;
    endcase
  end

  // outputs
  reg [OUT_WORDS*WORD_W-1:0] data_out_r;
  reg                        valid_data_out_r;
  assign data_out       = data_out_r;
  assign valid_data_out = valid_data_out_r;

  wire have_frames  = prev_valid & curr_valid;
  wire need_next_w0 = (phase == 4'd0);
  localparam integer ACC_W = 6;
  localparam [ACC_W-1:0] IN_WORDS_C  = 6'd8;
  localparam [ACC_W-1:0] OUT_WORDS_C = 6'd9;
  reg [ACC_W-1:0]    word_acc;
  wire               will_output = have_frames & (word_acc >= OUT_WORDS_C) & (phase != 4'd0);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_data_out_r <= 1'b0;
      prev_valid       <= 1'b0;
      curr_valid       <= 1'b0;
      phase            <= 4'd8; // start from 8: take 8 from prev + 1 from curr
      word_acc         <= {ACC_W{1'b0}};
    end else begin
      if (restart) begin
        valid_data_out_r <= 1'b0;
        prev_valid       <= 1'b0;
        curr_valid       <= 1'b0;
        phase            <= 4'd8;
        word_acc         <= {ACC_W{1'b0}};
      end 
      else begin
        valid_data_out_r <= 1'b0;

        if (will_output) begin
          data_out_r <= stitch_pc;
          valid_data_out_r <= 1'b1;
          phase <= (phase == 4'd0) ? 4'd8 : (phase - 1'b1);
        end else if (need_next_w0) begin
          phase <= 4'd8;
        end

        if (valid_data_in) begin
          prev_data  <= curr_data;
          curr_data  <= data_in[255:0];
          prev_valid <= curr_valid | prev_valid;
          curr_valid <= 1'b1;
        end

        word_acc <= word_acc
                  + (valid_data_in ? IN_WORDS_C  : {ACC_W{1'b0}})
                  - (will_output   ? OUT_WORDS_C : {ACC_W{1'b0}});
      end
    end
  end

endmodule