module zero_extender_8 (
    input wire [7:0] Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = {24'b0, Data_in};

endmodule