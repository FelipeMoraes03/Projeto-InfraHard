module shift_left_2 (
  input wire [31:0] data_in; //veio de sign_extend_16
  output wire [31:0] data_out; //vai para Mux 4x1 - ALUSrcB (entrada 1)
);

  assign data_out = data_in << 2; //desloca data_in 2 bits para a esquerda, colocando zeros à direita

endmodule
