module cpu (
    input wire clk,
    input wire reset
);
    //Control wires
    //1 Bit
    wire PCWrite;
    wire PCWriteCond;
    wire CondControlOutput;
    wire MemControl;
    wire IRWrite;
    wire RegWrite;
    wire LoadA;
    wire LoadB;
    wire ALUSrA;

    //flags
    wire Of;
    wire Ng;
    wire Zr;
    wire Eq;
    wire Gt;
    wire Lt;

    //2 bits
    wire [1:0] RegDST;
    wire [1:0] ALUSrB;
    wire [1:0] RegReadOne;

    //3 bits
    wire [2:0] IordD;
    wire [2:0] ALUOp;

    //Instrucoes
    wire [5:0] OPCode;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] Immediate;

    //wires 32 bits
    wire [31:0] ALU_Out;
    wire [31:0] PC_out;
    wire [31:0] IordD_out;
    wire [31:0] DataMemIn;
    wire [31:0] DataMemOut;
    //wire [31:0] WriteData;
    wire [31:0] Data1Out;
    wire [31:0] Data2Out;
    wire [31:0] A_Out;
    wire [31:0] B_Out;
    wire [31:0] MuxA_Out;
    wire [31:0] ImmediateSign;
    wire [31:0] ImmediateSignShift;
    wire [31:0] MuxB_Out;

    //wires de 5 bits
    wire [4:0] ReadR1Out;
    wire [4:0] MuxRDSTOut;
    
    wire PCW = ((PCWriteCond && CondControlOutput) || PCWrite);
    

    Registrador PC(
        clk,
        reset,
        PCW,
        ALU_Out,
        PC_out
    );

    mux_iord mux_Iord(
        PC_out,
        ALU_Out,
        IordD,
        IordD_out
    );

    Memoria Mem(
        IordD_out,
        clk,
        MemControl,
        DataMemIn,
        DataMemOut
    );

    Instr_Reg Inst_(
        clk,
        reset,
        IRWrite,
        DataMemOut,
        OPCode,
        RS,
        RT,
        Immediate
    );

    mux_regreadone MuxRR1(
        RS,
        RegReadOne,
        ReadR1Out
    );

    mux_regdest MuxRDST(
        RT,
        Immediate[15:11],
        RegDST,
        MuxRDSTOut
    );

    Banco_reg Banco(
        clk,
        reset,
        RegWrite,
        ReadR1Out,
        RT,
        MuxRDSTOut,
        ALU_Out,
        Data1Out,
        Data2Out
    );

    Registrador A(
        clk,
        reset,
        LoadA,
        Data1Out,
        A_Out
    );

    Registrador B(
        clk,
        reset,
        LoadB,
        Data2Out,
        B_Out
    );

    mux_2to1 MuxA(
        PC_out,
        A_Out,
        ALUSrA,
        MuxA_Out
    );

    sign_extend_16 sign16(
        Immediate,
        ImmediateSign
    );

    shift_left_2 shift2(
        ImmediateSign,
        ImmediateSignShift
    );

    mux_alusrb MuxB(
        B_Out,
        ImmediateSign,
        ImmediateSignShift,
        ALUSrB,
        MuxB_Out
    );

    ula32 ALU(
        MuxA_Out,
        MuxB_Out,
        ALUOp,
        ALU_Out,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );

    control_unit2 Controle(
        clk,
        reset,
        PCWrite,
        PCWriteCond,
        MemControl,
        IRWrite,
        RegWrite,
        LoadA,
        LoadB,
        ALUSrA,

        //flags
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,

        //2 bits
        RegDST,
        ALUSrB,
        RegReadOne,

        //3 bits
        IordD,
        ALUOp,

        //Instrucoes
        OPCode,
        Immediate[5:0],
        reset
    );
    
endmodule