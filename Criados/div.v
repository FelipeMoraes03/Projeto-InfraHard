module div (clk, div_control, reset, high, low, div_zero, a, b);

    output reg [31:0] high;
    output reg [31:0] low;
    output reg div_zero;

    input wire [31:0] a;
    input wire [31:0] b;
    input wire clk;
    input wire div_control;
    input wire reset;

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

    initial begin
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

        //RESET ATIVO
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

        //DIV_CONTROL ATIVO
        else if (div_control)
        begin
            if (!div_end)
            begin
                if (!div_start)
                begin
                    //EXCEÇÃO DE DIVISÃO POR 0
                    if (b == 32'b0)
                    begin
                        div_zero = 1'b1;
                        div_end = 1'b1;
                    end

                    //NÃO TEM EXCEÇÃO
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
            
                //INÍCIO DA DIVISÃO
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

                    //FIM DA DIVISÃO
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
endmodule