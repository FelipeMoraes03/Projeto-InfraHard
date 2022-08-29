module control_unit (
//Clock
  input wire clk,

//Instruction
  input wire [5:0] opcode,
  input wire [5:0] funct,

//Flags
  input wire OF,
  input wire ZERO,

//Control Signals
  //PC
  output reg PCWriteCond,
  output reg PCWrite,
  output reg CondControl,

  //Memory
  output reg MemRead,
  output reg MemWrite,

  //Instruction Register
  output reg IRWrite,

  //Registers
  output reg RegWrite,

  //ALU
  output reg [2:0] ALUOp,

  //Register Shift
  output reg [2:0] ShiftControl,

  //DIV/MULT
  output reg DIVMULT_control,

  //LS Control
  output reg [1:0] LSControlSignal,

  //MUX
  output reg [2:0] IorD,
  output reg [1:0] RegReadOne,
  output reg [1:0] RegDst,
  output reg [2:0] MemToReg,
  output reg MemData,
  output reg ALUSrcA,
  output reg [1:0] ALUSrcB,
  output reg InputShift,
  output reg NumberShift,
  output reg LSControl,
  output reg [2:0] PCSource,
  output reg LTout,

//Reset
  input wire reset_in,
  output reg reset_out
);

//Current FSM state
  reg [5:0] state;
  
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

  //Type J
  parameter OP_j = 6'h2;
  parameter OP_jal = 6'h3;

//States
  //basics
  parameter ST_reset = 6'd0;
  parameter ST_fetch = 6'd1;
  parameter ST_waiting = 6'd2;
  parameter ST_decode = 6'd3;

  //Invalid OPcode
  parameter ST_IOP_1 = 6'd4;
  parameter ST_IOP_2 = 6'd5;

  //and, add, addi, addiu, sub
  parameter ST_and = 6'd6;
  parameter ST_add = 6'd7;
  parameter ST_addi = 6'd8;
  parameter ST_addiu = 6'd9;
  parameter ST_sub = 6'd10;
  parameter ST_RegWrite_1 = 6'd11;
    //OverFlow
    parameter ST_OF_1 = 6'd12;
    parameter ST_OF_2 = 6'd13;

  //mult, div
  parameter ST_mult = 6'd14;
  parameter ST_div = 6'd15;
    //DIVision by 0
    parameter ST_DIV0_1 = 6'd16;
    parameter ST_DIV0_2 = 6'd17;

  //mfhi, mflo
  parameter ST_mfhi = 6'd18;
  parameter ST_mflo = 6'd19;
  parameter ST_RegWrite_2 = 6'd20;

  //loads, stores
  parameter ST_MemAddress_calc = 6'd21;
  parameter ST_load = 6'd22;
  parameter ST_lb = 6'd23;
  parameter ST_lh = 6'd24;
  parameter ST_lw = 6'd25;
  parameter ST_sb = 6'd26;
  parameter ST_sh = 6'd27;
  parameter ST_sw = 6'd28;

  //shifts
  parameter ST_shift_var = 6'd29;
  parameter ST_shift_imm = 6'd30;
  parameter ST_sll_sllv = 6'd31;
  parameter ST_srl = 6'd32;
  parameter ST_sra_srav = 6'd33;
  parameter ST_MemToReg = 6'd34;

  //slt, slti
  parameter ST_slt = 6'd35;
  parameter ST_slti = 6'd36;
  parameter ST_RegWrite_3 = 6'd37;

  //branches
  parameter ST_bne = 6'd38;
  parameter ST_beq = 6'd39;
  parameter ST_ble = 6'd40;
  parameter ST_bgt = 6'd41;

  //jumps
  parameter ST_jal = 6'd42;
  parameter ST_MemToReg_31 = 5'd43;
  parameter ST_j = 6'd44;
  parameter ST_jr = 6'd45;
  parameter ST_address_to_PC = 6'd46;

  //lui, rte, break
  parameter ST_lui = 6'd47;
  parameter ST_Rte = 6'd48;
  parameter ST_break = 6'd49;

  //stack  
  parameter ST_Push = 6'd50;
  parameter ST_RegWrite_Push = 6'd51;
  parameter ST_RegWrite_Push = 6'd52;
  parameter ST_MemAddressCalc_Push = 6'd53;
  parameter ST_mem_access = 6'd54;
  parameter ST_Pop = 6'd55;
  parameter ST_RegWrite_4 = 6'd56;
  parameter ST_SP_plus_4 = 6'd57;
  parameter ST_MemToReg_29 = 6'd58;

//For Mult waiting cylces only
  reg [31:0] mult_count;

initial begin
  reset_out = 1'b1;
end

always @(posedge clk) begin
  if (reset_in == 1'b1) begin
    RegDst = 2'b10;
    MemToReg = 3'b111;
    RegWrite = 1'b1;
    reset_out = 1'b0;
    mult_count = 32'd0;
    state = ST_fetch;
  end
  else begin
    case (state)
      ST_fetch: begin
        MemRead = 1'b1;
        ALUSrcA = 1'b0;
        IorD = 3'b000;
        IRWrite = 1'b1;
        ALUSrcB = 2'b11;
        ALUOp = 2'b001;
        PCWrite = 1'b1;
        PCSource = 3'b000;
        state = ST_waiting;
      end

      ST_waiting: begin
        state = ST_decode;
      end

      ST_decode: begin
        RegReadOne = 2'b00;
        ALUSrcA = 1'b0;
        ALUSrcB = 2'b10;
        ALUOp = 3'b001;

        case (opcode)
          OP_type_r: begin
            case (funct)
              FUN_add: begin
                state = ST_add;
              end

              FUN_and: begin
                state = ST_and;
              end

              FUN_div: begin
                state = ST_div;
              end

              FUN_mult: begin
                state = ST_mult;
              end

              FUN_jr: begin
                state = ST_jr;
              end

              FUN_mfhi: begin
                state = ST_mfhi;
              end

              FUN_mflo: begin
                state = ST_mflo;
              end

              FUN_sll: begin
                state = ST_shift_imm;
              end

              FUN_sllv: begin
                state = ST_shift_var;
              end

              FUN_slt: begin
                state = ST_slt;
              end

              FUN_sra: begin
                state = ST_shift_imm;
              end

              FUN_srav: begin
                state = ST_shift_var;
              end

              FUN_srl: begin
                state = ST_shift_imm;
              end

              FUN_sub: begin
                state = ST_sub;
              end

              FUN_break: begin
                state = ST_break;
              end

              FUN_Rte: begin
                state = ST_Rte;
              end

              FUN_Push: begin
                state = ST_Push;
              end

              FUN_Pop: begin
                state = ST_Pop;
              end

              default:
                state = ST_IOP_1;
            endcase
          end

          OP_addi: begin
            state = ST_addi;
          end

          OP_addiu: begin
            state = ST_addiu;
          end

          OP_beq: begin
            state = ST_beq;
          end

          OP_bne: begin
            state = ST_bne;
          end

          OP_ble: begin
            state = ST_ble;
          end

          OP_bgt: begin
            state = ST_bgt;
          end

          OP_lb: begin
            state = ST_MemAddress_calc;
          end

          OP_lh: begin
            state = ST_MemAddress_calc;
          end

          OP_lui: begin
            state = ST_lui;
          end

          OP_lw: begin
            state = ST_MemAddress_calc;
          end

          OP_sb: begin
            state = ST_MemAddress_calc;
          end

          OP_sh: begin
            state = ST_MemAddress_calc;
          end

          OP_slti: begin
            state = ST_slti;
          end

          OP_sw: begin
            state = ST_MemAddress_calc;
          end

          OP_j: begin
            state = ST_j;
          end

          OP_jal: begin
            state = ST_jal;
          end

          default: begin
            state = ST_IOP_1;
          end
        endcase
      end
  
      ST_IOP_1: begin
        ALUSrcA = 1'b0;
        ALUOp = 3'b000;
        state = ST_IOP_2;
      end
      
      ST_IOP_2: begin
      	IorD = 3'b010;
        MemRead = 1'b1;
        PCSource = 3'b010;
        PCWrite = 1'b1;
        LTout = 1'b0;
        state = ST_fetch;
       end

      ST_and: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b011;
        state = ST_RegWrite_1;
      end

      ST_add: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b001;
        state = ST_RegWrite_1;
      end

      ST_addi: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b01;
        ALUOp = 3'b001;
        state = ST_RegWrite_1;
      end

      ST_addiu: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b01;
        ALUOp = 3'b001;
        state = ST_RegWrite_1;
      end

      ST_sub: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b010;
        state = ST_RegWrite_1;
      end

      ST_RegWrite_1: begin
      	LTout = 1'b0;
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
        ALUSrcA = 1'b0;
        ALUOp = 3'b000;
        state = ST_OF_2;
      end

      ST_OF_2: begin
        IorD = 3'b011;
        MemRead = 1'b1;
        PCSource = 3'b010;
        PCWrite = 1'b1;
        state = ST_fetch;
      end

      ST_mult: begin
        DIVMULT_control = 1'b1;
        //Wait 32
        if (mult_count >= 32'd32) begin
        	mult_count = 32'd0;
        	state = ST_fetch;
        end
        else begin
        	mult_count = mult_count + 32'd1;
        end
      end

      ST_div: begin
        DIVMULT_control = 1'b0;
        if (ZERO == 1'b1) begin
          state = ST_DIV0_1;
        end
        else begin
          state = ST_fetch;
        end
      end

      ST_DIV0_1: begin
        ALUSrcA = 1'b0;
        ALUOp = 3'b000;
        state = ST_DIV0_2;
      end

      ST_DIV0_2: begin
        IorD = 3'b100;
        MemRead = 1'b1;
        MemWrite = 1'b0;
        PCSource = 3'b010;
        PCWrite = 1'b1;
        state = ST_fetch;
      end

      ST_mfhi: begin
        MemToReg = 3'b010;
        state = ST_RegWrite_2;
      end

      ST_mflo: begin
        MemToReg = 3'b011;
        state = ST_RegWrite_2;
      end

      ST_RegWrite_2: begin
        RegDst = 1'b0;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_MemAddress_calc: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b01;
        ALUOp = 3'b001;
        if (opcode == OP_lb || opcode == OP_lh || opcode == OP_lw) begin
          state = ST_load;
        end
        else if (opcode == OP_sb) begin
          state = ST_sb;
        end
        else if (opcode == OP_sh) begin
          state = ST_sh;
        end
        else begin
          state = ST_sw;
        end
      end

      ST_load: begin
      	LTout = 1'b0;
      	IorD = 3'b001;
        MemRead = 1'b1;
        if (opcode == OP_lb) begin
          state = ST_lb;
        end
        else if (opcode == OP_lh) begin
          state = ST_lh;
        end
        else begin
          state = ST_lw;
        end
      end

      ST_lb: begin
        RegDst = 2'b00;
        LSControl = 1'b0;
        LSControlSignal = 2'b01;
        MemToReg = 3'b101;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_lh: begin
        RegDst = 2'b00;
        LSControl = 1'b0;
        LSControlSignal = 2'b10;
        MemToReg = 3'b101;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_lw: begin
        RegDst = 2'b00;
        LSControl = 1'b0;
        LSControlSignal = 2'b11;
        MemToReg = 3'b101;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_sb: begin
      	LTout = 1'b0;
        IorD = 3'b001;
        LSControl = 1'b1;
        LSControlSignal = 2'b01;
        MemData = 1'b1;
        MemWrite = 1'b1;
        state = ST_fetch;
      end

      ST_sh: begin
      	LTout = 1'b0;
        IorD = 3'b001;
        LSControl = 1'b1;
        LSControlSignal = 2'b10;
        MemData = 1'b1;
        MemWrite = 1'b1;
        state = ST_fetch;
      end

      ST_sw: begin
      	LTout = 1'b0;
        IorD = 3'b001;
        LSControl = 1'b1;
        LSControlSignal = 2'b11;
        MemData = 1'b1;
        MemWrite = 1'b1;
        state = ST_fetch;
      end

      ST_shift_var: begin
        InputShift = 1'b0;
        NumberShift = 1'b0;
        ShiftControl = 3'b001;
        if (funct == FUN_sllv) begin
          state = ST_sll_sllv;
        end
        else begin
          state = ST_sra_srav;
        end
      end

      ST_shift_imm: begin
        InputShift = 1'b1;
        NumberShift = 1'b1;
        ShiftControl = 3'b001;
        if (funct == FUN_sll) begin
          state = ST_sll_sllv;
        end
        else if (funct == FUN_srl) begin
          state = ST_srl;
        end
        else begin
          state = ST_sra_srav;
        end
      end

      ST_sll_sllv: begin
        ShiftControl = 3'b010;
        state = ST_MemToReg;
      end

      ST_srl: begin
        ShiftControl = 3'b011;
        state = ST_MemToReg;
      end

      ST_sra_srav: begin
        ShiftControl = 3'b100;
        state = ST_MemToReg;
      end

      ST_MemToReg: begin
        MemToReg = 3'b100;
        RegDst = 2'b01;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_slt: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b111;
        state = ST_RegWrite_3;
      end

      ST_slti: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b01;
        ALUOp = 3'b111;
        state = ST_RegWrite_3;
      end

      ST_RegWrite_3: begin
      	LTout = 1'b1;
        RegDst = 2'b01;
        MemToReg = 3'b000;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_bne: begin
        PCWriteCond = 1'b1;
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b111;
        PCSource = 3'b011;
        CondControl = 2'b00;
        state = ST_fetch;
      end

      ST_beq: begin
        PCWriteCond = 1'b1;
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b111;
        PCSource = 3'b011;
        CondControl = 2'b01;
        state = ST_fetch;
      end

      ST_ble: begin
        PCWriteCond = 1'b1;
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b111;
        PCSource = 3'b011;
        CondControl = 2'b10;
        state = ST_fetch;
      end

      ST_bne: begin
        PCWriteCond = 1'b1;
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b00;
        ALUOp = 3'b111;
        PCSource = 3'b011;
        CondControl = 2'b11;
        state = ST_fetch;
      end

      ST_jal: begin
        ALUSrcA = 1'b0;
        ALUSrcB = 2'b11;
        ALUOp = 3'b001;
        state = ST_MemToReg_31;
      end

      ST_MemToReg_31: begin
      	LTout = 1'b0;
        MemToReg = 3'b000;
        RegDst = 2'b11;
        RegWrite = 1'b1;
        state = ST_j;
      end

      ST_j: begin
        PCSource = 3'b001;
        PCWrite = 1'b1;
        state = ST_fetch;
      end

      ST_jr: begin
        ALUSrcA = 1'b1;
        ALUOp = 3'b000;
        state = ST_address_to_PC;
      end

      ST_address_to_PC: begin
        PCSource = 3'b011;
        PCWrite = 1'b1;
        state = ST_fetch;
      end

      ST_lui: begin
        RegDst = 2'b00;
        MemToReg = 3'b110;
        RegWrite = 1'b1;
        state = ST_fetch;
      end

      ST_Rte: begin
        PCSource = 3'b100;
        PCWrite = 1'b1;
        state = ST_fetch;
      end

      ST_break: begin
        ALUSrcA = 1'b0;
        ALUOp = 3'b000;
        PCSource = 3'b000;
        PCWrite = 1'b1;
        state = ST_fetch;
      end

      ST_Push: begin
        RegReadOne = 2'b01;
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b11;
        ALUOp = 3'b010;
        state = ST_mem_access;
      end

      ST_RegWrite_Push: begin
      	LTout = 1'b0;
        MemToReg = 3'b000;
        RegDst = 2'b10;
        RegWrite = 1'b1;
        state = ST_MemAddressCalc_Push;
      end
      
      ST_MemAddressCalc_Push: begin
      	RegReadOne = 2'b01;
      	ALUSrcA = 1'b1;
        ALUSrcB = 2'b01;
        ALUOp = 3'b001;
        state = ST_mem_access;
      end

      ST_mem_access: begin
      	LTout = 1'b0;
        IorD = 3'b001;
        LSControl = 1'b1;
        LSControlSignal = 2'b11;
        MemData = 1'b0;
        MemWrite = 1'b1;
        state = ST_fetch;
      end

      ST_Pop: begin
        RegReadOne = 2'b01;
        ALUSrcA = 1'b1;
        ALUOp = 3'b000;
        LTout = 1'b0;
        IorD = 3'b001;
        MemRead = 1'b1;
        state = ST_RegWrite_4;
      end

      ST_RegWrite_4: begin
        LSControl = 1'b0;
        LSControlSignal = 2'b11;
        MemToReg = 3'b101;
        RegDst = 2'b00;
        RegWrite = 1'b1;
        state = ST_SP_plus_4;
      end

      ST_SP_plus_4: begin
        ALUSrcA = 1'b1;
        ALUSrcB = 2'b11;
        ALUOp = 3'b001;
        state = ST_MemToReg_29;
      end

      ST_MemToReg_29: begin
        MemToReg = 3'b000;
        RegDst = 2'b10;
        RegWrite = 1'b1;
        state = ST_fetch;
      end
    endcase
  end
end
endmodule
