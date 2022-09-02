module sign_extend_26 (
    input wire [26:0] Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = {6'b0, Data_in};

endmodule