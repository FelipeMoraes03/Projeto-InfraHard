module mux_numbershift(input wire [31:0] reg_B,
                 input wire [4:0] instruction_10_6,
                 input wire sel,
                 output reg [4:0] out
                 );
  
  always@(*) begin
    case (sel)
      1'b0: out = reg_B[4:0];
      1'b1: out = instruction_10_6;
    endcase
  end
endmodule