module mux_regdest(input wire [4:0] instruction_20_16,
                 input wire [4:0] instruction_15_11,
                 input wire [1:0] sel,
                 output reg [4:0] out
                 );
  
  always@(*) begin
    case (sel)
      2'b00: out = instruction_20_16;
      2'b01: out = instruction_15_11;
      2'b10: out = 5'b11101; //reg 29 
      2'b11: out = 5'b11111; //reg 31
    endcase
  end
endmodule