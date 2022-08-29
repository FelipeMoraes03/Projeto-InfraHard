module shift_left_2 (
  input wire [31:0] data_in, //veio de sign_extend_16
  output wire [31:0] data_out //vai para c do mux_alusrb.v
);

  assign data_out = data_in << 2; //desloca data_in 2 bits para a esquerda, colocando zeros à direita

endmodule
