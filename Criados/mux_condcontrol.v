module mux_condcontrol(input wire zero,
                      input wire gt,
                      input wire [1:0] sel,
                      output reg out
                      );
  
  always@(*) begin
    case (sel)
      2'b00: out = ~zero;
      2'b01: out = zero;
      2'b10: out = ~gt;
      2'b11: out = gt;
    endcase
  end

endmodule