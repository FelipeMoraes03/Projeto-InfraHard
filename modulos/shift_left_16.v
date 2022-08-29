module shift_left_16 (
  input wire [15:0] data_in, //vem de Instr15_0	do Instr_Reg.vhd
  output wire [31:0] data_out //vai para f do mux_memtoreg.v
);

  assign data_out = {data_in, {16{1'b0}}}; //concatena data_in (MSB) com o número 0 extendido em 16 bits (LSB)

endmodule
