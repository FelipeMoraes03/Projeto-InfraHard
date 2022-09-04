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
    wire LoadHi;
    wire LoadLo;
    wire LoadEPC;
    wire NumberShift;
    wire InputShift;
    wire LTout;
    wire LSControl;

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
    wire [1:0] CondControl;
    wire [1:0] LSControlSignal;
    wire [1:0] MultDiv;

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

    wire [27:0] OFFSET_SHIFT;

    //wires 32 bits
    wire [31:0] ALUOUT_Out;
    wire [31:0] PC_Out;
    wire [31:0] IordD_Out;
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
    wire [31:0] MDR_Out;
    wire [31:0] ALU_result;
    wire [31:0] HighIn;
    wire [31:0] LowIn;
    wire [31:0] Hi_Out;
    wire [31:0] Lo_Out;
    wire [31:0] EPC_Out;
    wire [31:0] ImmediateLui;
    wire [31:0] MuxInputShift_Out;
    wire [31:0] RegisterShift_Out;
    wire [31:0] Lt_extended;
    wire [31:0] LSControl1_Out;
    wire [31:0] LSControl2_Out;
    wire [31:0] LTout_Out;
    wire [31:0] LSControl_Out;

    //wires de 5 bits
    wire [4:0] ReadR1Out;
    wire [4:0] MuxRDSTOut;
    wire [4:0] MuxNumberShift_Out;
    
    wire LoadPC = ((PCWriteCond && CondControlOutput) || PCWrite);
    

    Registrador PC(
        clk,
        reset,
        LoadPC,
        PC_in,
        PC_Out
    );

    mux_iord mux_Iord(
        PC_Out,
        LTout_Out, //mudei tava ALUOUT_out
        IordD,
        IordD_Out
    );
    
    zero_extender_1 zeroExtender1(
        Lt,
        Lt_extended
    );

    mux_2to1 mux_LTout (
        ALUOUT_Out,
        Lt_extended,
        LTout,
        LTout_Out
    );

    mux_2to1 mux_LSControl1 (
        MDR_Out,
        B_Out,
        LSControl,
        LSControl1_Out
    );

    mux_2to1 mux_LSControl2 (
        B_Out,
        MDR_Out,
        LSControl,
        LSControl2_Out
    );

    Memoria Mem(
        IordD_Out,
        clk,
        MemControl,
        LSControl_Out,
        DataMemOut 
    );

    Registrador MDR(
        clk,
        reset,
        LoadMDR,
        DataMemOut,
        MDR_Out
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
        PC_Out,
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

    shift_left_16 shift16(
        Immediate,
        ImmediateLui //ImmediateLui
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

    shift_left_2_PC ShiftLeft2PC(
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
        DivZero
    );


    mux_memtoreg MuxMTR(
        LTout_Out,
        MDR_Out,
        Hi_Out,
        Lo_Out,
        RegisterShift_Out,
        LSControl_Out,
        ImmediateLui,  //ImmediateLui <- Immediate shiftado 16
        MemToReg,
        WriteData
    );

    Registrador EPC(
        clk,
        reset,
        LoadEPC,
        ALU_result,
        EPC_Out
    );

    mux_pcsource MuxPCSource(
        ALU_result,
        PC_Out[31:28],
        OFFSET_SHIFT,
        DataMemOut, //DataMemIn
        ALUOUT_Out,
        EPC_Out,   //Saida de EPC
        PCSource,
        PC_in
    );

    LS_Control LSControlBlock (
        LSControl1_Out,
        LSControlSignal,
        LSControl,
        LSControl2_Out,
        clk,
        reset,
        LSControl_Out
    );

    mux_2to1 MuxInputShift(
        A_Out,
        B_Out,        
        InputShift,
        MuxInputShift_Out
    );
    mux_numbershift MuxNumberShift(
        B_Out,
        Immediate[10:6],
        NumberShift,
        MuxNumberShift_Out
    );
    RegDesloc RegisterShift(
        clk,
        reset,
        ShiftControl,
        MuxNumberShift_Out,
        MuxInputShift_Out,
        RegisterShift_Out
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
        LoadHi,
        LoadLo,
        LoadEPC,
        NumberShift,
        InputShift,
        LTout,
        LSControl,
        

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
        CondControl,
        LSControlSignal,
        MultDiv,

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

    mux_condcontrol MuxCondControl(
        Eq,
        Gt,
        CondControl,
        CondControlOutput
    );
    
endmodule