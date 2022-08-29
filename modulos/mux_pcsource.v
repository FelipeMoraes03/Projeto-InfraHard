module mux_pcsource(input wire [31:0] aluResult,
                     input wire [31:0] jump_address_31_0,
                     input wire [31:0] memData_extended,
		     input wire [31:0] aluOut,
                     input wire [31:0] epc,
                     input wire [2:0] sel,
                     output reg [31:0] out
                     );
  
	always@(*) begin
		case (sel)
			3'b000: out = aluResult;
			3'b001: out = jump_address_31_0;
			3'b010: out = memData_extended;
			3'b011: out = aluOut;
			3'b100: out = epc;
			3'b101: out = 32'b0;
			3'b110: out = 32'b0;
			3'b111: out = 32'b0;
		endcase
	end
endmodule
