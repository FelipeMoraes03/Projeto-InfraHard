module mult_div (
    input wire clk,
    input wire mult_div_control,
    input wire reset,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] high,
    output reg [31:0] low,
    output reg div_zero,
    input wire divLoad
);
    //mult
    reg signed [63:0] Out;
    integer i;
    reg [31:0] Q1;
    reg Qres;
    reg mult_end;

    //div
    reg [31:0] aux_a;
    reg [31:0] aux_b;
    reg [31:0] comp_b;
    reg sign_a;
    reg sign_b;
    reg div_start;
    reg div_end;
    reg [31:0] aux_result;
    reg [31:0] aux_remainder;
    reg [32:0] aux_diff;
    integer counter;

    initial
    begin
        //mult
        Qres <= 1'd0;
        Out <= 64'd0;
        Q1 <= 32'd0;
        i <= 0;
        mult_end <= 0;
        //div
        sign_a <= 1'b0; //0 -> Positivo / 1 -> Negativo
        sign_b <= 1'b0; //0 -> Positivo / 1 -> Negativo
        div_zero <= 1'b0;
        div_start <= 1'b0;
        div_end <= 1'b0;
        aux_result <= 32'b0;
        aux_remainder <= 32'b0;
        aux_diff <= 33'b0;
        counter <= 31;
    end


    always @(posedge clk)
    begin
        if (mult_div_control) //mult -> mult_div_control = 1
        begin
            if (reset)
            begin
                Out <= 64'd0;
                Q1 <= 32'd0;
                Qres <= 0;
                i <= 0;
                mult_end <= 0;
            end

            if (!mult_end) 
            begin
                case({a[i], Qres})
                    2'b01: Out[63:32] = Out[63:32] + b;
                    2'b10:
                    begin
                        Q1 = - b;
                        Out[63:32] = Out[63:32] + Q1;
                    end
                endcase
                Out = Out >>> 1;
                Qres = a[i];
                i = i + 1;

                if (i == 32)
                begin
                    if (b == 32'h8000_0000)								
                        begin
                        Out = - Out;
                    end

                    high = Out[63:32];
                    low = Out[31:0];
                    mult_end = 1;     
                end
            end
        end

        else //div -> mult_div_control = 0
        begin
            //RESET ATIVO
        if (divLoad)
            begin
                if (reset)
                begin
                    high = 32'b0;
                    low = 32'b0;
                    div_zero = 1'b0;
                    div_start = 1'b0;
                    div_end = 1'b1;
                    sign_a = 1'b0;
                    sign_b = 1'b0;
                    aux_result = 32'b0;
                    aux_remainder = 32'b0;
                    aux_diff = 32'b0;
                    counter = 0;
                end

                if (!div_end)
                begin
                    if (!div_start)
                    begin
                        //EXCEวรO DE DIVISรO POR 0
                        if (b == 32'b0)
                        begin
                            div_zero = 1'b1;
                            div_end = 1'b1;
                        end

                        //NรO TEM EXCEวรO
                        else
                        begin //-> Passo 1
                            //TRANSFORMAR DIVIDENDO EM POSITIVO
                            if (a[31])
                            begin
                                aux_a = (~a + 1'b1);
                                sign_a = 1'b1;
                            end
                            else
                            begin
                                aux_a = a; 
                            end

                            //TRANSFORMAR DIVISOR EM POSITIVO
                            if (b[31])
                            begin
                                aux_b = (~b + 1'b1);
                                sign_b = 1'b1;
                            end
                            else
                            begin
                                aux_b = b; 
                            end
                        end
                        div_start = 1'b1;
                    end

                    //INอCIO DA DIVISรO
                    if (div_start)
                    begin
                        aux_remainder = aux_remainder << 1; //-> Passos 3, 4, 6 e 7
                        aux_remainder[0] = aux_a[counter];

                        comp_b = (~aux_b + 1'b1);
                        aux_diff = aux_remainder + comp_b; //-> Passos 8

                        if (aux_diff[32]) //-> Passo 10
                        begin
                            aux_remainder = aux_diff[31:0];
                        end

                        aux_result[counter] = aux_diff[32]; //-> Passo 11

                        counter = counter - 1;

                        //FIM DA DIVISรO
                        if (counter == -1)
                        begin
                            if (sign_a ^ sign_b)
                            begin
                                high = (~aux_result + 1'b1);
                            end
                            else
                            begin
                                high = aux_result;
                            end

                            if (sign_a)
                            begin
                                low = (~aux_remainder + 1'b1);
                            end
                            else
                            begin
                                low = aux_remainder;
                            end

                            div_end = 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule