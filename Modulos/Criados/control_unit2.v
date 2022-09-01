module control_unit2 (
    input wire clk,
    input wire reset,
    output reg PCWrite,
    output reg PCWriteCond,
    output reg MemControl,
    output reg IRWrite,
    output reg RegWrite,
    output reg LoadA,
    output reg LoadB,
    output reg ALUSrA,

        //flags
    input wire Of,
    input wire Ng,
    input wire Zr,
    input wire Eq,
    input wire Gt,
    input wire Lt,

        //2 bits
    output reg [1:0] RegDST,
    output reg [1:0] ALUSrB,
    output reg [1:0] RegReadOne,

        //3 bits
    output reg[2:0] IordD,
    output reg[2:0] ALUOp,

        //Instrucoes
    input wire [5:0] OPCode,
    output reg rst_out
);

//Variaveis
    reg [2:0] Counter;
    reg [2:0] State;

//Parametros
    //Estados
    parameter ST_COMMON = 3'b101;
    parameter ST_DECODE = 3'b001;
    parameter ST_ADD = 3'b010;
    parameter ST_ADDI = 3'b011;
    parameter ST_RESET = 3'b100;
    //Opcode
    parameter ADD = 6'b000000;
    parameter ADDI = 6'b001000;
    parameter RESET = 6'b111111;

    initial begin
        //Da o reset inicial na maquina
        rst_out = 1'b1;
        State = ST_ADD;
    end

    always @(posedge clk) begin
        if (reset == 1'b1) begin
            if (State != ST_RESET) begin
                State = ST_RESET;

                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                MemControl = 1'b0;
                IRWrite = 1'b0;
                RegReadOne = 1'b0;
                RegWrite = 1'b0;
                LoadA = 1'b0;
                LoadB = 1'b0;
                ALUSrA = 1'b0;

                RegDST = 2'b00;
                ALUSrB = 2'b00;
                IordD = 3'b000;
                ALUOp = 3'b000;
                rst_out = 1'b1;

                Counter = 3'b000;
            end
            else begin
                State = ST_COMMON; //

                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                MemControl = 1'b0;
                IRWrite = 1'b0;
                RegReadOne = 1'b0;
                RegWrite = 1'b0;
                LoadA = 1'b0;
                LoadB = 1'b0;
                ALUSrA = 1'b0;

                RegDST = 2'b00;
                ALUSrB = 2'b00;
                IordD = 3'b000;
                ALUOp = 3'b000;
                rst_out = 1'b0; //

                Counter = 3'b000;
            end
        end
        else begin
            case(State)
                ST_COMMON: begin
                    if (Counter == 3'b000 || Counter == 3'b001 || Counter == 3'b010) begin
                        //Nesse if acontece o estado de busca e waiting
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegReadOne = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b001;   ///
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 3'b011) begin
                        //Nesse else o PC eh salvo
                        State = ST_COMMON;

                        PCWrite = 1'b1;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b1;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11;
                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 3'b100) begin
                        //Nesse else acontece o estado de Decode
                        State = ST_COMMON;

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1;   ///
                        LoadB = 1'b1;   ///
                        ALUSrA = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b000;   ///
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 3'b101) begin
                        case(OPCode)
                            ADD: begin
                                State = ST_ADD;
                            end
                            ADDI: begin
                                State = ST_ADDI;
                            end
                            RESET: begin
                                State = ST_RESET;
                            end
                        endcase

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   ///
                        LoadB = 1'b0;   ///
                        ALUSrA = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b000;   ///
                        rst_out = 1'b0;

                        Counter = 3'b000;
                    end
                end
                ST_ADD: begin
                    if(Counter == 3'b000) begin
                        State = ST_ADD;

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   ///
                        LoadB = 1'b0;   ///
                        ALUSrA = 1'b1;

                        RegDST = 2'b01;   ////
                        ALUSrB = 2'b00;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b001;   ///
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 3'b001) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   ///
                        LoadB = 1'b0;   ///
                        ALUSrA = 1'b1;

                        RegDST = 2'b01;   ////
                        ALUSrB = 2'b00;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b001;   ///
                        rst_out = 1'b0;

                        Counter = 3'b000;
                    end
                end
                ST_ADDI: begin
                    if(Counter == 3'b000) begin
                        State = ST_ADDI;

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   ///
                        LoadB = 1'b0;   ///
                        ALUSrA = 1'b1;

                        RegDST = 2'b00;   ////
                        ALUSrB = 2'b01;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b001;   ///
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 3'b001) begin
                        State = ST_ADDI;

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   ///
                        LoadB = 1'b0;   ///
                        ALUSrA = 1'b1;

                        RegDST = 2'b00;   ////
                        ALUSrB = 2'b01;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b001;   ///
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 3'b010) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   ///
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   ///
                        RegReadOne = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   ///
                        LoadB = 1'b0;   ///
                        ALUSrA = 1'b1;

                        RegDST = 2'b00;   ////
                        ALUSrB = 2'b01;   ///
                        IordD = 3'b000;
                        ALUOp = 3'b001;   ///
                        rst_out = 1'b0;

                        Counter = 3'b000;
                    end
                end
                ST_RESET: begin
                    if(Counter == 3'b000) begin
                        State = ST_RESET;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegReadOne = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        rst_out = 1'b1;

                        Counter = 3'b000;
                    end
                end
            endcase
        end
    end
    
endmodule