module zero_extender_1 (
    input wire Data_in,
    output wire [31:0] Data_out
);

    assign Data_out = {31{0'b1}},Data_in;

endmodule