module zero_extender_1 (
    input wire Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = {31'b0, Data_in};

endmodule