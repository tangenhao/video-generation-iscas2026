module fast_func(
    input clk,
    input rst_n,
    input valid,
    input [5:0] opcode, 
    input [31:0] din, output [31:0] dout, output done
);

// localparam SIN       = 6'b001000; 
// localparam COS       = 6'b001001;
localparam REC       = 6'b001010;
// localparam LOG2      = 6'b001011;
localparam EXP2      = 6'b001100;
localparam RSQRT     = 6'b001101;
// localparam FTANH     = 6'b100010;
// localparam FSIGMOID  = 6'b100011;
localparam FSILU     = 6'b100100;
// localparam FMISH     = 6'b100101;
localparam FGELU     = 6'b100110;
reg    [10:0]   func;

always@(*) begin
    case (opcode)
        // SIN:       func = 11'b00000000001;
        // COS:       func = 11'b00000000010;
        REC:       func = 11'b00000000100;
        // LOG2:      func = 11'b00000001000;
        EXP2:      func = 11'b00000010000;
        RSQRT:     func = 11'b00000100000;
        // FTANH:     func = 11'b00001000000;
        // FSIGMOID:  func = 11'b00010000000;
        FSILU:    func = 11'b00100000000;
        // FMISH:     func = 11'b01000000000;
        FGELU:     func = 11'b10000000000;
        default:   func = 11'b00000000000;
    endcase
end

sfu u_sfu(
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .func(func), 
    .din(din), 
    .dout(dout), 
    .done(done)
);

endmodule