module gearbox_288_to_256 #(
  parameter WORD_W       = 32,
  parameter IN_WORDS     = 9,    // 9*32 = 288b
  parameter OUT_WORDS    = 8,    // 8*32 = 256b
  parameter BUFFER_WORDS = 18
)(
  input  wire                           clk,
  input  wire                           rst_n,
  input  wire                           restart,

  input  wire                           valid_data_in,
  output wire                           ready_data_in,
  input  wire [IN_WORDS*WORD_W-1:0]     data_in,

  output wire                           valid_data_out,
  output wire [OUT_WORDS*WORD_W-1:0]    data_out
);
  // 288b -> 256b has a higher output beat rate than input beat rate:
  // eight 288b inputs produce nine 256b outputs. ready_data_in must be
  // observed by the upstream for unbounded streams.

  function integer clog2;
    input integer value;
    integer tmp;
    begin
      tmp = value - 1;
      for (clog2 = 0; tmp > 0; clog2 = clog2 + 1) begin
        tmp = tmp >> 1;
      end
    end
  endfunction

  localparam integer ACC_W = clog2(BUFFER_WORDS + IN_WORDS + 1);

  reg [WORD_W-1:0] word_buf [0:BUFFER_WORDS-1];
  reg [ACC_W-1:0]  word_count;

  reg [OUT_WORDS*WORD_W-1:0] data_out_r;
  reg                        valid_data_out_r;

  wire                       output_fire_buffer;
  wire [ACC_W-1:0]           count_after_pop;
  wire                       input_fire;

  assign output_fire_buffer = (word_count >= OUT_WORDS);
  assign count_after_pop    = word_count - (output_fire_buffer ? OUT_WORDS : 0);
  assign ready_data_in   = (count_after_pop <= (BUFFER_WORDS - IN_WORDS));
  assign input_fire      = valid_data_in & ready_data_in;

  assign data_out        = data_out_r;
  assign valid_data_out  = valid_data_out_r;

  integer i;
  integer source_idx;
  integer total_words;
  reg     output_fire_next;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_data_out_r <= 1'b0;
      data_out_r       <= {OUT_WORDS*WORD_W{1'b0}};
      word_count       <= {ACC_W{1'b0}};
      for (i = 0; i < BUFFER_WORDS; i = i + 1) begin
        word_buf[i] <= {WORD_W{1'b0}};
      end
    end else begin
      if (restart) begin
        valid_data_out_r <= 1'b0;
        data_out_r       <= {OUT_WORDS*WORD_W{1'b0}};
        word_count       <= {ACC_W{1'b0}};
        for (i = 0; i < BUFFER_WORDS; i = i + 1) begin
          word_buf[i] <= {WORD_W{1'b0}};
        end
      end else begin
        total_words = word_count + (input_fire ? IN_WORDS : 0);
        output_fire_next = (total_words >= OUT_WORDS);

        valid_data_out_r <= output_fire_next;

        if (output_fire_next) begin
          for (i = 0; i < OUT_WORDS; i = i + 1) begin
            if (i < word_count) begin
              data_out_r[i*WORD_W +: WORD_W] <= word_buf[i];
            end else begin
              data_out_r[i*WORD_W +: WORD_W] <= data_in[(i - word_count)*WORD_W +: WORD_W];
            end
          end
        end

        for (i = 0; i < BUFFER_WORDS; i = i + 1) begin
          source_idx = i + (output_fire_next ? OUT_WORDS : 0);
          if (source_idx < word_count) begin
            word_buf[i] <= word_buf[source_idx];
          end else if (input_fire && source_idx < total_words) begin
            word_buf[i] <= data_in[(source_idx - word_count)*WORD_W +: WORD_W];
          end else begin
            word_buf[i] <= {WORD_W{1'b0}};
          end
        end

        word_count <= total_words - (output_fire_next ? OUT_WORDS : 0);
      end
    end
  end

endmodule
