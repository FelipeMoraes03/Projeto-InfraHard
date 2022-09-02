module mux_iord(input wire [31:0] PC,
                     input wire [31:0] b,
                     input wire [2:0] sel,
                     output reg [31:0] out
                     );
  
  always@(*) begin
    case (sel)
      3'b000: out = PC;
      3'b001: out = b;
      3'b010: out = 32'b11111101; //253 
      3'b011: out = 32'b11111110; //254
      3'b100: out = 32'b11111111; //255
      3'b101: out = 32'b0; // entradas inutilizadas
      3'b110: out = 32'b0;
      3'b111: out = 32'b0;
    endcase
  end
endmodule