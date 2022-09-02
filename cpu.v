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
    wire LoadALUOUT;
    wire LoadMDR;
    wire MultDiv;
    wire LoadHi;
    wire LoadLo;
    wire LoadDiv;
    wire NumberShift;
    wire InputShift;

    //flags
    wire Of;
    wire Ng;
    wire Zr;
    wire Eq;
    wire Gt;
    wire Lt;
    wire DivZero;

    //2 bits
    wire [1:0] RegDST;
    wire [1:0] ALUSrB;
    wire [1:0] RegReadOne;

    //3 bits
    wire [2:0] IordD;
    wire [2:0] ALUOp;
    wire [2:0] PCSource;
    wire [2:0] MemToReg;
    wire [2:0] ShiftControl;

    //Instrucoes
    wire [5:0] OPCode;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] Immediate;
    wire [25:0] OFFSET = {RS, RT, Immediate};

    wire [28:0] OFFSET_SHIFT;

    //wires 32 bits
    wire [31:0] ALUOUT_Out;
    wire [31:0] PC_out;
    wire [31:0] IordD_out;
    wire [31:0] DataMemIn;
    wire [31:0] DataMemOut;
    wire [31:0] WriteData;
    wire [31:0] Data1Out;
    wire [31:0] Data2Out;
    wire [31:0] A_Out;
    wire [31:0] B_Out;
    wire [31:0] MuxA_Out;
    wire [31:0] ImmediateSign;
    wire [31:0] ImmediateSignShift;
    wire [31:0] MuxB_Out;
    wire [31:0] PC_in;
    wire [31:0] MDR_out;
    wire [31:0] ALU_result;
    wire [31:0] HighIn;
    wire [31:0] LowIn;
    wire [31:0] Hi_Out;
    wire [31:0] Lo_Out;
    wire [31:0] MuxInputShift_out;
    wire [31:0] RegisterShift_out;

    //wires de 5 bits
    wire [4:0] ReadR1Out;
    wire [4:0] MuxRDSTOut;
    wire [4:0] MuxNumberShift_out;
    
    wire LoadPC = ((PCWriteCond && CondControlOutput) || PCWrite);
    

    Registrador PC(
        clk,
        reset,
        LoadPC,
        PC_in,
        PC_out
    );

    mux_iord mux_Iord(
        PC_out,
        ALUOUT_Out,
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

    Registrador MDR(
        clk,
        reset,
        LoadMDR,
        DataMemOut,
        MDR_out
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
        WriteData,
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

    Registrador Hi(
        clk,
        reset,
        LoadHi,
        HighIn,
        Hi_Out
    );

    Registrador Lo(
        clk,
        reset,
        LoadLo,
        LowIn,
        Lo_Out
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
        ALU_result,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );

    Registrador ALUOUT(
        clk,
        reset,
        LoadALUOUT,
        ALU_result,
        ALUOUT_Out
    );

    shift_left_2 ShiftLeft2(
        OFFSET,
        OFFSET_SHIFT
    );

    mult_div DivMult(
        clk,
        MultDiv,
        reset,
        A_Out,
        B_Out,
        HighIn,
        LowIn,
        DivZero,
        LoadDiv
    );

    mux_memtoreg MuxMTR(
        ALUOUT_Out,
        MDR_Out,
        Hi_Out,  //Hi_Out
        Lo_Out,  //Lo_Out
        RegisterShift_out,  //RegShift_Out
        32'd0,  //Demux_Out
        32'd0,  //ImmediateLui <- Immediate shiftado 16
        MemToReg,
        WriteData
    );

    mux_pcsource MuxPCSource(
        ALU_result,
        PC_out,
        OFFSET_SHIFT,
        DataMemOut,
        ALUOUT_Out,
        32'd0,   //Saida de EPC
        PCSource,
        PC_in
    );

    // SSL/SRL/SRA
    mux_2to1 MuxInputShift(
        A_Out,
        B_Out,        
        InputShift, //
        MuxInputShift_out //
    );

    mux_numbershift MuxNumberShift(
        B_Out,
        Immediate,
        NumberShift, //
        MuxNumberShift_out //
    );

    RegDesloc RegisterShift(
        clk,
        reset,
        ShiftControl,//
        MuxNumberShift_out,//
        MuxInputShift_out,//
        RegisterShift_out//
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
        LoadALUOUT,
        LoadMDR,
        MultDiv,
        LoadHi,
        LoadLo,
        LoadDiv,

        //flags
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        DivZero,

        //2 bits
        RegDST,
        ALUSrB,
        RegReadOne,

        //3 bits
        IordD,
        ALUOp,
        PCSource,
        MemToReg,
        ShiftControl,

        //Instrucoes
        OPCode,
        Immediate[5:0],
        reset
    );

    
endmodule