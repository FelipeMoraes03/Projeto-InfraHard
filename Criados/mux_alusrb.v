module mux_alusrb(input wire [31:0] reg_B,
                     input wire [31:0] instruction_15_11,
                     input wire [31:0] c,
                     input wire [1:0] sel,
                     output reg [31:0] out
                     );
  
  always@(*) begin
    case (sel)
      2'b00: out = reg_B; 
      2'b01: out = instruction_15_11; 
      2'b10: out = c;
      2'b11: out = 32'b100; //4
    endcase
  end
endmodule