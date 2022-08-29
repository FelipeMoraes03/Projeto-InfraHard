module shift_left_2_PC (
  input wire [25:0] data_in; //veio de Instr20_16 com Instr15_0 do Instr_Reg
  output wire [28:0] data_out; //vai para jump_address_31_0 do mux_pcsource
);

  assign data_out = {data_in, {2{1'b0}}; //concatena data_in (MSB) com o número 0 extendido para 2 bits (LSB)

endmodule