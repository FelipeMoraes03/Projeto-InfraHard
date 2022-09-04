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
    output reg LoadALUOUT,
    output reg LoadMDR,
    output reg LoadHi,
    output reg LoadLo,
    output reg LoadEPC,
    output reg NumberShift,
    output reg InputShift,
    output reg LTout,
    output reg LSControl,

    //flags
    input wire Of,
    input wire Ng,
    input wire Zr,
    input wire Eq,
    input wire Gt,
    input wire Lt,
    input wire DivZero,

    //2 bits
    output reg [1:0] RegDST,
    output reg [1:0] ALUSrB,
    output reg [1:0] RegReadOne,
    output reg [1:0] CondControl,
    output reg [1:0] LSControlSignal,
    output reg [1:0] MultDiv,
    
    //3 bits
    output reg[2:0] IordD,
    output reg[2:0] ALUOp,
    output reg[2:0] PCSource,
    output reg[2:0] MemToReg,
    output reg[2:0] ShiftControl,

    //Instrucoes
    input wire [5:0] OPCode,
    input wire [5:0] Funct,
    output reg rst_out
);

//Variaveis
    reg [5:0] Counter;
    reg [5:0] State;

//Parametros
    //Estados
    parameter ST_COMMON = 6'd0;
    parameter ST_ADD = 6'd1;
    parameter ST_ADDI = 6'd2;
    parameter ST_ADDIU = 6'd3;
    parameter ST_AND = 6'd4;
    parameter ST_SUB = 6'd5;
    parameter ST_DIV = 6'd6;
    parameter ST_MULT = 6'd7;
    parameter ST_MFHI = 6'd8;
    parameter ST_MFLO = 6'd9;
    parameter ST_JR = 6'd10;
    parameter ST_RTE = 6'd11;

    parameter ST_BNE = 6'd12;
    parameter ST_BEQ = 6'd13;
    parameter ST_BLE = 6'd14;
    parameter ST_BGT = 6'd15;
    parameter ST_SLT = 6'd16;
    parameter ST_SLTI= 6'd17;

    parameter ST_LUI = 6'd18;

    parameter ST_J = 6'd19;
    parameter ST_JAL = 6'd20;

    parameter ST_SLL = 6'd21;
    parameter ST_SLLV = 6'd22;
    parameter ST_SRL = 6'd23;
    parameter ST_SRA = 6'd24;
    parameter ST_SRAV = 6'd25;

    parameter ST_SW = 6'd26;

    parameter ST_OF = 6'd27;
    parameter ST_DIVZ = 6'd28;

    parameter ST_LW = 6'd29;
    parameter ST_LH = 6'd30;
    parameter ST_LB = 6'd31;

    parameter ST_SB = 6'd34;
    parameter ST_SH = 6'd35;

    parameter ST_POP = 6'd36;
    parameter ST_PUSH = 6'd37;

    parameter ST_BREAK = 6'd32; //PENÚLTIMO ESTADO!
    parameter ST_RESET = 6'd33; //ÚLTIMO ESTADO!

    //Opcode
    parameter RESET = 6'b111111;
    //Type R
    parameter Type_R = 6'd0;
        //Funct dos Tipos R
        parameter ADD = 6'h20;
        parameter SUB = 6'h22;
        parameter AND = 6'h24;
        parameter DIV = 6'h1a;
        parameter MULT = 6'h18;
        parameter JR = 6'h8;
        parameter MFHI = 6'h10;
        parameter MFLO = 6'h12;
        parameter SLL = 6'h0;
        parameter SLLV = 6'h4;
        parameter SLT = 6'h2a;
        parameter SRA = 6'h3;
        parameter SRAV = 6'h7;
        parameter SRL = 6'h2;
        parameter BREAK = 6'hd;
        parameter RTE = 6'h13;
        parameter PUSH = 6'h5;
        parameter POP = 6'h6;

    //Type I
    parameter ADDI = 6'h8;
    parameter ADDIU = 6'h9;
    parameter BEQ = 6'h4;
    parameter BNE = 6'h5;
    parameter BLE = 6'h6;
    parameter BGT = 6'h7;
    parameter LB = 6'h20;
    parameter LH = 6'h21;
    parameter LUI = 6'hf;
    parameter LW = 6'h23;
    parameter SB = 6'h28;
    parameter SH = 6'h29;
    parameter SLTI = 6'ha;
    parameter SW = 6'h2b;

    //Type J
    parameter J = 6'h2;
    parameter JAL = 6'h3;

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
                RegWrite = 1'b1; //
                LoadA = 1'b0;
                LoadB = 1'b0;
                ALUSrA = 1'b0;
                LoadALUOUT = 1'b0;
                LoadMDR = 1'b0;
                MultDiv = 2'b00;
                LoadHi = 1'b0;
                LoadLo = 1'b0;
                LoadEPC = 1'b0;
                InputShift = 1'b0;
                NumberShift = 1'b0;
                LTout = 1'b0;
                LSControl = 1'b0;

                RegDST = 2'b10; //
                ALUSrB = 2'b00;
                RegReadOne = 2'b00;
                CondControl = 2'b00;
                LSControlSignal = 2'b00;
                
                IordD = 3'b000;
                ALUOp = 3'b000;
                PCSource = 3'b000;
                MemToReg = 3'b111; //
                ShiftControl = 3'b000;

                rst_out = 1'b1;

                Counter = 6'd0;
            end
            else begin
                State = ST_COMMON;

                PCWrite = 1'b0;
                PCWriteCond = 1'b0;
                MemControl = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1; //
                LoadA = 1'b0;
                LoadB = 1'b0;
                ALUSrA = 1'b0;
                LoadALUOUT = 1'b0;
                LoadMDR = 1'b0;
                MultDiv = 2'b00;
                LoadHi = 1'b0;
                LoadLo = 1'b0;
                LoadEPC = 1'b0;
                InputShift = 1'b0;
                NumberShift = 1'b0;
                LTout = 1'b0;
                LSControl = 1'b0;

                RegDST = 2'b10; //
                ALUSrB = 2'b00;
                RegReadOne = 2'b00;
                CondControl = 2'b00;
                LSControlSignal = 2'b00;
                
                IordD = 3'b000;
                ALUOp = 3'b000;
                PCSource = 3'b000;
                MemToReg = 3'b111; //
                ShiftControl = 3'b000;

                rst_out = 1'b0;

                Counter = 6'd0;
            end
        end
        else begin
            case(State)
                ST_COMMON: begin
                    if (Counter == 6'd0 || Counter == 6'd1 || Counter == 6'd2) begin
                        //Nesse if acontece parte do estado de busca e waiting
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd3) begin
                        //Nesse else o PC eh salvo
                        State = ST_COMMON;

                        PCWrite = 1'b1; 
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b1;  
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0; 
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11; //PC+4
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001; //SOMA
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd4) begin
                        //Nesse else acontece o estado de Decode
                        State = ST_COMMON;

                        PCWrite = 1'b0; 
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1;
                        LoadB = 1'b1;
                        ALUSrA = 1'b0; //PC
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b10; //Immediate
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001; //Soma
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd5) begin
                        case(OPCode)
                            Type_R: begin
                                case(Funct)
                                    ADD: begin
                                        State = ST_ADD;
                                    end
                                    AND: begin
                                        State = ST_AND;
                                    end
                                    SUB: begin
                                        State = ST_SUB;
                                    end
                                    DIV: begin
                                        State = ST_DIV;
                                    end
                                    MULT: begin
                                        State = ST_MULT;
                                    end
                                    MFHI: begin
                                        State = ST_MFHI;
                                    end
                                    MFLO: begin
                                        State = ST_MFLO;
                                    end
                                    JR: begin
                                        State = ST_JR;
                                    end
                                    RTE: begin
                                        State = ST_RTE;
                                    end
                                    BREAK: begin
                                        State = ST_BREAK;
                                    end
                                    SLL: begin
                                        State = ST_SLL;
                                    end
                                    SLLV: begin
                                        State = ST_SLLV;
                                    end
                                    SRL: begin
                                        State = ST_SRL;
                                    end
                                    SRA: begin
                                        State = ST_SRA;
                                    end
                                    SRAV: begin
                                        State = ST_SRAV;
                                    end
                                    SLT: begin
                                        State = ST_SLT;
                                    end
                                    PUSH: begin
                                        State = ST_PUSH;
                                    end
                                    POP: begin
                                        State = ST_POP;
                                    end
                                endcase
                            end
                            
                            ADDI: begin
                                State = ST_ADDI;
                            end

                            ADDIU: begin
                                State = ST_ADDIU;
                            end
                            
                            RESET: begin
                                State = ST_RESET;
                            end

                            BNE: begin
                                State = ST_BNE;
                            end

                            BEQ: begin
                                State = ST_BEQ;
                            end

                            BLE: begin
                                State = ST_BLE;
                            end

                            BGT: begin
                                State = ST_BGT;
                            end

                            SLTI: begin
                                State = ST_SLTI;
                            end

                            LUI: begin
                                State = ST_LUI;
                            end

                            J: begin
                                State = ST_J;
                            end

                            JAL: begin
                                State = ST_JAL;
                            end

                            SW: begin
                                State = ST_SW;
                            end

                            LW: begin
                                State = ST_LW;
                            end

                            LB: begin
                                State = ST_LB;
                            end

                            LH: begin
                                State = ST_LH;
                            end

                            SB: begin
                                State = ST_SB;
                            end

                        endcase

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_ADD: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADD;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;  
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;

                        if (Of == 1'b1) 
                        begin
                            State = ST_OF;
                        end

                    end
                end
                ST_ADDI: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADDI;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b01;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b01;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 3'b000;

                        if (Of == 1'b1) 
                        begin
                            State = ST_OF;
                        end

                    end
                end

                ST_OF: begin
                    if(Counter == 6'd0) 
                    begin
                        State = ST_OF;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0; //
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b1; //
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11; //
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b010; //
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;

                    end else if (Counter == 6'd1  || Counter == 6'd2) 
                    begin
                        State = ST_OF;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0; //
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b011; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;

                    end else if (Counter == 6'd3)
                    begin
                        State = ST_COMMON;

                        PCWrite = 1'b1; //
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b010; //
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_ADDIU: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADDIU;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b01;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b01;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;   
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 3'b000;
                    end
                end
                ST_AND: begin
                    if(Counter == 6'd0) begin
                        State = ST_AND;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;  
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b011;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b011;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;  
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_SUB: begin
                    if(Counter == 6'd0) begin
                        State = ST_SUB;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b010;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;  
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b010;  
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                        
                        if (Of == 1'b1) 
                        begin
                            State = ST_OF;
                        end

                    end
                end
                ST_DIV: begin
                    if(Counter < 6'd33) begin
                        State = ST_DIV;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;  
                        LoadB = 1'b0;  
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b10;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000; 
                        PCSource = 3'b000;
                        MemToReg = 3'b000;  
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd33) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;  
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b10;
                        LoadHi = 1'b1; 
                        LoadLo =  1'b1;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000; 
                        ShiftControl = 3'b000;  
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;

                        if (DivZero == 1'b1)
                        begin
                            State = ST_DIVZ;
                        end
                    end
                end
                ST_DIVZ: begin
                    if(Counter == 6'd0) 
                    begin
                        State = ST_DIVZ;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0; //
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b1; //
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11; //
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b010; //
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;

                    end else if (Counter == 6'd1  || Counter == 6'd2) 
                    begin
                        State = ST_DIVZ;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0; //
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b100; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;

                    end else if (Counter == 6'd3)
                    begin
                        State = ST_COMMON;

                        PCWrite = 1'b1; //
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b010; //
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_MULT: begin
                    if(Counter < 6'd33) begin
                        State = ST_MULT;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b01;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;  
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;  
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd33) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;  
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b01;
                        LoadHi = 1'b1; 
                        LoadLo =  1'b1;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;   
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_MFHI: begin
                    if(Counter == 6'd0) begin
                        State = ST_MFHI;

                        PCWrite = 1'b0; 
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0; 
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;   
                        MemToReg = 3'b010;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;  
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;  
                        MemToReg = 3'b010;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_MFLO: begin
                    if(Counter == 6'd0) begin
                        State = ST_MFLO;

                        PCWrite = 1'b0;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b0;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;  
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;  
                        MemToReg = 3'b011;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;   
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;   
                        RegWrite = 1'b1;
                        LoadA = 1'b0;   
                        LoadB = 1'b0;   
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0; 
                        LoadLo =  1'b0; 
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;  
                        ALUSrB = 2'b00;   
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;  
                        MemToReg = 3'b011;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_JR: begin
                    if(Counter == 6'd0) begin
                        State = ST_JR; 

                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0; 
                        LoadLo =  1'b0; 
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 1'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0; 
                        LoadLo =  1'b0; 
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b011;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_RTE: begin
                    if(Counter == 6'd0) begin
                        State = ST_RTE;

                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b100;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b100;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;
                        
                        Counter = 6'd0;
                    end
                end
                ST_BNE: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0; 
                    LoadLo =  1'b0; 

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b0;
                    LSControl = 1'b0;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b011;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_BEQ: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0; 
                    LoadLo =  1'b0; 

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b0;
                    LSControl = 1'b0;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b01;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b011;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_BLE: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0; 
                    LoadLo =  1'b0; 

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b0;
                    LSControl = 1'b0;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b10;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b011;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_BGT: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b1;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0; 
                    LoadLo =  1'b0; 

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b0;
                    LSControl = 1'b0;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b11;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b011;
                    MemToReg = 3'b011;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_SLTI: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0;
                    LoadLo = 1'b0;

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b1;
                    LSControl = 1'b0;

                    RegDST = 2'b00;
                    ALUSrB = 2'b01;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b000;
                    MemToReg = 3'b000;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_LUI: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b0;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0;
                    LoadLo = 1'b0;

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b0;
                    LSControl = 1'b0;

                    RegDST = 2'b00;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    LSControlSignal = 2'b00;

                    IordD = 3'b000;
                    ALUOp = 3'b000;
                    PCSource = 3'b000;
                    MemToReg = 3'b110;
                    ShiftControl = 3'b000;
                        
                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_J: begin
                    if(Counter == 6'd0) begin
                        State = ST_J;

                        PCWrite = 1'b1; //segundo
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b001; //primeiro
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                            
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1; //segundo
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b001; //primeiro
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                            
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_JAL: begin
                    if(Counter == 6'd0) begin
                        State = ST_JAL;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_J;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b11;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_SLL: begin
                    if(Counter == 6'd0) begin
                        State = ST_SLL;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b1;   ///
                        NumberShift = 1'b1;   ///
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b001;   ///
                        
                        rst_out = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SLL;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;   ///
                        NumberShift = 1'b0;   ///
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b010;   ///
                        
                        rst_out = 1'b0;
                        
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   ///
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b100;   ///
                        ShiftControl = 3'b000;   ///
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;   ///
                    end
                end
                ST_SRL: begin
                    if(Counter == 6'd0) begin
                        State = ST_SRL;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b1;   ///
                        NumberShift = 1'b1;   ///
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b001;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SRL;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;   ///
                        NumberShift = 1'b0;   ///
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b011;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   ///
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b100;   ///
                        ShiftControl = 3'b000;   ///
                        
                        rst_out = 1'b0;
                        
                        Counter = 6'd0;   ///
                    end
                end
                ST_SRA: begin
                    if(Counter == 6'd0) begin
                        State = ST_SRA;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b1;   ///
                        NumberShift = 1'b1;   ///
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b001;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SRA;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b100;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   ///
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b100;   ///
                        ShiftControl = 3'b000;   ///
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;   ///
                    end
                end
                ST_SLLV: begin
                    if(Counter == 6'd0) begin
                        State = ST_SLLV;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b001;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SLLV;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b010;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;
                        
                        RegDST = 2'b01;   ///
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b100;   ///
                        ShiftControl = 3'b000;   ///
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;   ///
                    end
                end
                ST_SRAV: begin
                    if(Counter == 6'd0) begin
                        State = ST_SRAV;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b001;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SRAV;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b100;   ///
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;
                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadHi = 1'b0;
                        LoadLo =  1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b01;   ///
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        MemToReg = 3'b100;   ///
                        ShiftControl = 3'b000;   ///
                        
                        rst_out = 1'b0;
                        Counter = 6'd0;   ///
                    end
                end
                ST_SLT: begin
                    State = ST_COMMON;

                    PCWrite = 1'b0;
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b1;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b1;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0;
                    LoadLo = 1'b0;

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b1;
                    LSControl = 1'b0;

                    RegDST = 2'b01;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b111;
                    PCSource = 3'b000;
                    MemToReg = 3'b000;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_SW: begin
                    if(Counter == 6'd0) begin
                        State = ST_SW;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0; //
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b01; //
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b1;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b1;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b11;

                        IordD = 3'b001; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 0;
                    end
                end

                ST_SB: begin
                    if(Counter == 6'd0) begin
                        State = ST_SB;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0; //
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b01; //
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end

                    else if (Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b1;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b1;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b01;

                        IordD = 3'b001; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 0;
                    end
                end

                ST_SH: begin
                    if(Counter == 6'd0) begin
                        State = ST_SH;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0; //
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b01; //
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b1;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b1;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b10;

                        IordD = 3'b001; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 0;
                    end
                end
                ST_LW: begin
                    if (Counter == 6'd0) begin
                        State = ST_LW; 

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b01;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1 || Counter == 6'd2 || Counter == 6'd3) begin
                        State = ST_LW; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0; //MemRead
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b1;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b001;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b101;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd4) begin
                        State = ST_COMMON; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b11;

                        IordD = 3'b001;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b101;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_LB: begin
                    if (Counter == 6'd0) begin
                        State = ST_LB; 

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b1;
                        LoadALUOUT = 1'b1;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b01;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b001;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1 || Counter == 6'd2 || Counter == 6'd3) begin
                        State = ST_LB; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0; //MemRead
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b1;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b001;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd4) begin
                        State = ST_COMMON; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b01;

                        IordD = 3'b001;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b101;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_BREAK: begin
                    State = ST_BREAK;

                    PCWrite = 1'b1;
                    PCWriteCond = 1'b0;
                    MemControl = 1'b0;
                    IRWrite = 1'b0;
                    RegWrite = 1'b0;
                    LoadA = 1'b0;
                    LoadB = 1'b0;
                    ALUSrA = 1'b0;
                    LoadALUOUT = 1'b0;
                    LoadMDR = 1'b0;
                    MultDiv = 2'b00;
                    LoadHi = 1'b0; 
                    LoadLo =  1'b0; 

                    LoadEPC = 1'b0;
                    InputShift = 1'b0;
                    NumberShift = 1'b0;
                    LTout = 1'b0;
                    LSControl = 1'b0;

                    RegDST = 2'b00;
                    ALUSrB = 2'b00;
                    RegReadOne = 2'b00;
                    CondControl = 2'b00;
                    LSControlSignal = 2'b00;
                    
                    IordD = 3'b000;
                    ALUOp = 3'b000;
                    PCSource = 3'b000;
                    MemToReg = 3'b000;
                    ShiftControl = 3'b000;

                    rst_out = 1'b0;

                    Counter = 6'd0;
                end
                ST_POP: begin
                    if (Counter == 6'd0 || Counter == 6'd1) begin
                        State = ST_POP; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1; //
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1; //
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b01; //
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000; //
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end

                    else if (Counter == 6'd2 || Counter == 6'd3 || Counter == 6'd4) begin
                        State = ST_POP; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0; //MemRead
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b1; //
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b001; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd5) begin
                        State = ST_POP; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1; //
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0; //

                        RegDST = 2'b00; //
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b01; //

                        IordD = 3'b000; //
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b001; //
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1; //
                    end

                    else if(Counter == 6'd6 || Counter == 6'd7) begin
                        State = ST_POP;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1; //
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1; //
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11; //
                        RegReadOne = 2'b01; //
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b001; //
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1; //
                    end

                    else if(Counter == 6'd8) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1; //
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0; //
                        LSControl = 1'b0;

                        RegDST = 2'b10; //
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b000; //
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd0;
                    end
                end
                ST_PUSH: begin
                    if (Counter == 6'd0 || Counter == 6'd1) begin
                        State = ST_PUSH; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1; //
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1; //
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b11; //
                        RegReadOne = 2'b01; //
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b010; //
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end

                    else if(Counter == 6'd2) begin
                        State = ST_PUSH; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1; //
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0; //
                        LSControl = 1'b0;

                        RegDST = 2'b10; //
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000; 
                        PCSource = 3'b000;
                        MemToReg = 3'b000; //
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = Counter + 1;
                    end

                    else if(Counter == 6'd3) begin
                        State = ST_SW;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b0;
                        LoadA = 1'b1; //
                        LoadB = 1'b0;
                        ALUSrA = 1'b1; //
                        LoadALUOUT = 1'b1; //
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b00;
                        ALUSrB = 2'b01; //
                        RegReadOne = 2'b01; //
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;
                        
                        IordD = 3'b000;
                        ALUOp = 3'b000; //
                        PCSource = 3'b000;
                        MemToReg = 3'b000;
                        ShiftControl = 3'b000;

                        rst_out = 1'b0;

                        Counter = 6'd1;
                    end
                end
                ST_RESET: begin
                    if (Counter == 6'd0) begin
                        State = ST_RESET; //

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        MemControl = 1'b0;
                        IRWrite = 1'b0;
                        RegWrite = 1'b1; //
                        LoadA = 1'b0;
                        LoadB = 1'b0;
                        ALUSrA = 1'b0;
                        LoadALUOUT = 1'b0;
                        LoadMDR = 1'b0;
                        MultDiv = 2'b00;
                        LoadHi = 1'b0;
                        LoadLo = 1'b0;
    
                        LoadEPC = 1'b0;
                        InputShift = 1'b0;
                        NumberShift = 1'b0;
                        LTout = 1'b0;
                        LSControl = 1'b0;

                        RegDST = 2'b10; //
                        ALUSrB = 2'b00;
                        RegReadOne = 2'b00;
                        CondControl = 2'b00;
                        LSControlSignal = 2'b00;

                        IordD = 3'b000;
                        ALUOp = 3'b000;
                        PCSource = 3'b000;
                        MemToReg = 3'b111; //
                        ShiftControl = 3'b000;
                        
                        rst_out = 1'b1;

                        Counter = 6'd0;
                    end
                end
            endcase
        end
    end
    
endmodule