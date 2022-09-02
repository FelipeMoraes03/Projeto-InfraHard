module mux_numbershift(input wire [31:0] reg_B,
                 input wire [15:0] Immediate,
                 input wire sel,
                 output reg [4:0] out
                 );
  
  always@(*) begin
    case (sel)
      1'b0: out = reg_B[4:0];
      1'b1: out = instruction_15_0[10:6];
    endcase
  end
endmodule