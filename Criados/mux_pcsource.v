module mux_pcsource(input wire [31:0] aluResult,
                     input wire [3:0] PC_sig,
                     input wire [27:0] output_shift_left_2,
                     input wire [31:0] memData,
		                 input wire [31:0] aluOut,
                     input wire [31:0] epc,
                     input wire [2:0] sel,
                     output reg [31:0] out
                     );
  
  always@(*) begin
    case (sel)
      3'b000: out = aluResult;
      3'b001: out = {PC_sig, output_shift_left_2};
      3'b010: out = memData;
      3'b011: out = aluOut;
      3'b100: out = epc;
      3'b101: out = 32'b0;
      3'b110: out = 32'b0;
      3'b111: out = 32'b0;
    endcase
  end
endmodule