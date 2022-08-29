module mux_2to1(input wire [31:0] a,
                input wire [31:0] b,
                input wire sel,
                output reg [31:0] out
                );
  
  always@() begin
    case (sel)
      1'b0 out = a;
      1'b1 out = b;
    endcase
  end
endmodule