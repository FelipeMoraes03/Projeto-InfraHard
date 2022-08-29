module shift_left_2_PC (
  input wire [25:0] data_in; //veio de instruction[25:0]
  output wire [28:0] data_out; //vai para Mux 8x1 - PCSource (entrada 1)
);

  assign data_out = {data_in, {2{1'b0}}; //concatena data_in (MSB) com o número 0 extendido para 2 bits (LSB)

endmodule
