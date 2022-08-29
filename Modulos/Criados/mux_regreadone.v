module mux_regreadone(input wire [31:0]instrucion_25_21,
                 input wire [1:0] sel,
                 output reg [31:0] out
                 );
  
  always@(*) begin
    case (sel)
      2'b00: out = instrucion_25_21;
      2'b01: out = 32'b11101; //reg 29
      2'b10: out = 32'b11111; //reg 31
      2'b11: out = 32'b0;
    endcase
  end
endmodule