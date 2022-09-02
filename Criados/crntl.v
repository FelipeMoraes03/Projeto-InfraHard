module crntl(

    //Clock e Reset
    input wire clk,
    input wire reset,

    //Instruction
    input wire [5:0] opcode,
    input wire [5:0] funct,

    //Flags
    input wire OF,
    input wire ZERO,

    //PC
    output reg PCWriteCond,
    output reg PCWrite,
    output reg [1:0] CondControl,

    //Memory
    output reg MemControl, //MemRead -> MemControl = 0, MemWrite -> MemControl = 1

    //Registers
    output reg RegWrite,
    output reg load_A,
    output reg load_B,
    output reg alu_out,
    output reg IRWrite,

    //ALU
    output reg [2:0] ALUOp,

    //MUX
    output reg [2:0] IorD,
    output reg [1:0] RegReadOne,
    output reg [1:0] RegDst,
    output reg ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [2:0] MemToReg,
    output reg [2:0] PCSource

    //output reg reset_out
);


//Current FSM state
  reg [5:0] state;
  reg [2:0] counter;
  reg [31:0] mult_count;

//Opcode Parameters
    //Type R
    parameter OP_type_r = 6'h0;
        //Funct Parameters
        parameter FUN_add = 6'h20;
        parameter FUN_and = 6'h24;
        parameter FUN_div = 6'h1A;
        parameter FUN_mult = 6'h18;
        parameter FUN_jr = 6'h8;
        parameter FUN_mfhi = 6'h10;
        parameter FUN_mflo = 6'h12;
        parameter FUN_sll = 6'h0;
        parameter FUN_sllv = 6'h4;
        parameter FUN_slt = 6'h2A;
        parameter FUN_sra = 6'h3;
        parameter FUN_srav = 6'h7;
        parameter FUN_srl = 6'h2;
        parameter FUN_sub = 6'h22;
        parameter FUN_break = 6'hD;
        parameter FUN_Rte = 6'h13;
        parameter FUN_Push = 6'h5;
        parameter FUN_Pop = 6'h6;

    //Type I
    parameter OP_addi = 6'h8;
    parameter OP_addiu = 6'h9;
    parameter OP_beq = 6'h4;
    parameter OP_bne = 6'h5;
    parameter OP_ble = 6'h6;
    parameter OP_bgt = 6'h7;
    parameter OP_lb = 6'h20;
    parameter OP_lh = 6'h21;
    parameter OP_lui = 6'hf;
    parameter OP_lw = 6'h23;
    parameter OP_sb = 6'h28;
    parameter OP_sh = 6'h29;
    parameter OP_slti = 6'hA;
    parameter OP_sw = 6'h2B;


    parameter ST_reset = 6'd0;
    parameter ST_fetch = 6'd1;
    parameter ST_waiting = 6'd2;
    parameter ST_decode = 6'd3;

    parameter ST_add = 6'd7;
    parameter ST_addi = 6'd8;
    parameter ST_OF_1 = 6'd12;
    parameter ST_RegWrite_1 = 6'd11;

    //Reset Na CPU
    initial begin

        state = ST_fetch;
        /*
        load_A = 1'b0;
        load_B = 1'b0;
        alu_out = 1'b0;
        */
    end

    always @(posedge clk) begin 
        if(reset) begin
            RegDst = 2'b10;
            MemToReg = 3'b111;
            RegWrite = 1'b1;
            //reset_out = 1'b0;
            mult_count = 32'd0;
            state = ST_fetch;
            
        end
        else begin
            case (state)
                ST_fetch: begin
                    MemControl = 1'b0;
                    ALUSrcA = 0;
                    IorD = 3'b000;
                    ALUSrcB = 2'b11;
                    ALUOp = 3'b001;
                    PCWrite = 1'b1;
                    PCSource = 3'b000;
                    counter = 3'b000;
                    state = ST_waiting;
                    IRWrite = 1;
                end

                ST_waiting: begin
                    state = ST_decode;
                end

                ST_decode: begin
                    RegReadOne = 2'b00;
                    ALUSrcA = 1'b0;
                    ALUSrcB = 2'b10;
                    ALUOp = 2'b01;
                    load_A = 1'b1;
                    load_B = 1'b1;

                    case (opcode)
                        OP_type_r: begin
                            state = ST_add;
                        end

                        OP_addi: begin
                            state = ST_addi;
                        end
                    endcase
                end

                ST_add: begin
                    ALUSrcA = 1'b1;
                    ALUSrcB = 2'b00;
                    ALUOp = 3'b001;
                    alu_out = 1'b1;

                    state = ST_RegWrite_1;
                end

                ST_addi: begin
                    ALUSrcA = 1'b1;
                    ALUSrcB = 2'b01;
                    ALUOp = 3'b001;
                    alu_out = 1'b1;

                    state = ST_RegWrite_1;
                end

                ST_RegWrite_1: begin
                    MemToReg = 3'b000;
                    RegDst = 2'b01;
                    RegWrite = 1'b1;

                    if (OF == 1'b1) begin
                        state = ST_OF_1;
                    end
                    else begin
                        state = ST_fetch;
                    end
                end

                ST_OF_1: begin
                    state = ST_fetch;
                end


            endcase

        end
    end
endmodule