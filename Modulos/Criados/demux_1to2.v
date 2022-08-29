module demux_1to2(input wire [31:0] a,
                 input wire sel,
                 output reg [31:0] out_1,
                 output reg [31:0] out_2
                 );

always@() begin
    case (sel)
      1'b0 out_1 = a;
      1'b1 out_2 = a;
    endcase
  end
endmodule