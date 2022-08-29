`include "modulos/control_unit.v"
`include "modulos/div.v"
`include "modulos/mult.v"
`include "modulos/demux_1to2.v"
`include "modulos/mux_2to1.v"
`include "modulos/mux_alusrb.v"
`include "modulos/mux_iord.v"
`include "modulos/mux_memtoreg.v"
`include "modulos/mux_numbershift.v"
`include "modulos/pcsource.v"
`include "modulos/regdest.v"
`include "modulos/regreadone.v"
`include "modulos/sign_extend_16.v"
`include "modulos/zero_extend_1.v"
`include "modulos/mux_condcontrol.v"

`include "componentesDoProjeto/Banco_reg.vhd"
`include "componentesDoProjeto/Instr_Reg.vhd"
`include "componentesDoProjeto/Memoria.vhd"
`include "componentesDoProjeto/RegDesloc.vhd"
`include "componentesDoProjeto/Registrador.vhd"
`include "componentesDoProjeto/ula32.vhd"


module integracao (
    input wire clk, reset,
    output wire Q2
);


// Control Wires 1 bit
wire load;
wire sel_lscontrol;
wire sel_alusra;
wire sel_regwrite;
wire sel_ltout;
wire sel_lscontrol;
wire sel_memdata;
wire sel_inputshift;
wire sel_numbershift;
wire sel_lscontrol_signal;
wire sel_condcontrol;
wire sel_memcontrol;

//Control wires 2 bits
wire [1:0] sel_alusrb;
wire [1:0] sel_mux_pcsource;
wire [1:0] sel_regdest;
 
//Control wires 3bits
wire [2:0] sel_aluop;
wire [2:0] sel_memtoreg;
wire [2:0] sel_iord;
wire [2:0] sel_reg_read_one;
wire [2:0] sel_shiftcontrol;

//Data Wires 1 bit
wire output_mux_condcontrol;
wire output_zero_div;

// Data Wires 5 bits
wire [4:0] output_mux_numbershift;
wire [4:0] output_instruction_15_0;
wire [4:0] output_instruction_20_16;
wire [4:0] output_instruction_15_11;
wire [4:0] output_mux_RegReadOne;
wire [4:0] input_n;
wire [4:0] output_mux_regdest;

// Data Wires 32 bits
wire [31:0] output_aluout;
wire [31:0] output_alu;
wire [31:0] output_PCSource;
wire [31:0] input_a;
wire [31:0] input_b;
wire [31:0] input_regHi;
wire [31:0] output_regHi;
wire [31:0] input_regLo;
wire [31:0] output_regLo;
wire [31:0] output_PC;
wire [31:0] output_regA;
wire [31:0] output_regB;
wire [31:0] output_mux_iord;
wire [31:0] output_1_demux;
wire [31:0] output_2_demux;
wire [31:0] output_mux_alusra;
wire [31:0] output_mux_alusrb;
wire [31:0] output_mux_memtoreg;
wire [31:0] output_shift_left_16;
wire [31:0] output_register_shift;
wire [31:0] memory_data_register;
wire [31:0] output_sign_extend_16;
wire [31:0] output_shift_left_2;
wire [31:0] output_mux_srb;
wire [31:0] output_mux_pcsource;
wire [31:0] jump_address_31_0;
wire [31:0] memData;
wire [31:0] output_menor_extended;
wire [31:0] output_mux_ltout;
wire [31:0] output_MDR;
wire [31:0] output_mux_information_lscontrol;
wire [31:0] output_mux_addres_lscontrol;
wire [31:0] output_mux_inputshift;
wire [31:0] output_ls_control_block;
wire [31:0] output_memory;
wire [31:0] output_mux_memdata;

// Flags
wire overflow;
wire negativo;
wire zero;
wire igual;
wire maior;
wire menor;

// Registers
Registrador aluOut(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(output_alu), 
    .Saida(output_aluout) 
    );

Registrador PC(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(output_PCSource), 
    .Saida(output_PC)
    );

Registrador A(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(input_a), 
    .Saida(output_regA) 
    );

Registrador B(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(input_b), 
    .Saida(output_regB) 
    );

Registrador Hi(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(input_regHi), 
    .Saida(output_regHi) 
    );

Registrador Lo(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(input_regLo), 
    .Saida(output_regLo) 
    );

Registrador epc(
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(output_alu), 
    .Saida(output_epc) 
    );

Registrador memoryDataRegister (
    .Clock(clk), 
    .Reset(reset), 
    .Load(load), 
    .Entrada(output_memory), 
    .Saida(output_MDR) 
    );

// Componentes do Projeto
alu32 alu(
    .A(output_mux_alusra),  
    .B(output_mux_alusrb), 
    .Seletor(sel_aluop), 
    .S(output_alu), 
    .Overflow(overflow), 
    .Negativo(negativo), 
    .z(zero), 
    .Igual(igual), 
    .Maior(maior), 
    .Menor(menor) 
    );

Banco_reg bancoReg (
    .Clk(clk),
    .Reset(reset),
    .RegWrite(sel_regwrite),
    .ReadReg1(output_mux_RegReadOne),
    .ReadReg2(output_instruction_20_16),
    .WriteReg(output_mux_regdest),
    .WriteData(output_MemtoReg),
    .ReadData1(input_regA),
    .ReadData2(input_regB)
    );

Memoria memory(
    .Clock(clk),
    .Address(output_mux_iord), 
    .Wr(sel_memcontrol), 
    .Datain(output_mux_memdata), 
    .Dataout(output_memory) 
);

// Blocos criados
LScontrol ls_Control(
    .clock(clk),
    .reset(reset),
    .value(output_mux_information_lscontrol),
    .instruction(output_mux_address_lscontrol),
    .control(sel_lscontrol_signal),
    .out(output_ls_control_block)
);

RegDesloc shift(
    .Clk(clk),
    .Reset(reset),
    .Shift(sel_shiftcontrol),
    .N(output_mux_numbershift),
    .Entrada(output_mux_inputshift),
    .Saida(output_regDeloc)
    
);

mult mult(
    .M(output_regA),
    .Q(output_regB),
    .clk(clk),
    .reset(reset),
    .mflo(input_regLo), 
    .mfhi(input_regHi)
);

div div(
    .clk(clk),
    .reset(reset),
    .a(output_regA),
    .b(output_regB),
    .high(input_regHi), 
    .low(input_regLo),
    .div_zero(output_zero_div)
);

// Mux's
mux_2to1 mux_alusra(
    .a(output_PC), 
    .b(output_regA), 
    .sel(sel_alusra), 
    .out(output_mux_alusra) 
    );

mux_2to1 mux_ltout(
    .a(output_menor_extended),
    .b(output_aluout),
    .sel(sel_ltout),
    .out(output_mux_ltout)
    );

mux_alusrb mux_alusrb(
    .reg_B(output_regB), 
    .instruction_15_11(output_sign_extend_16), 
    .c(output_shift_left_2), 
    .sel(sel_alusrb), 
    .out(output_mux_srb) 
    );

mux_iord mux_iord(
    .PC(output_PC), 
    .b(output_mux_ltout), 
    .sel(sel_iord), 
    .out(output_mux_iord) 
    );

mux_condcontrol mux_condcontrol(
        .zero(zero),
        .gt(maior),
        .sel(sel_condcontrol),
        .out(output_mux_condcontrol)
    );

mux_memtoreg mux_memtoreg(
    .a(output_aluout), 
    .b(memory_data_register), 
    .c(output_regHi), 
    .d(output_regLo), 
    .e(output_register_shift), 
    .f(output_2_demux), 
    .g(output_shift_left_16), 
    .sel(sel_memtoreg), 
    .out(output_mux_memtoreg) 
    );

mux_numbershift mux_numbershift(
    .reg_B(output_regB),
    .instruction_15_0(output_instruction_15_0),
    .sel(sel_numbershift),
    .out(output_mux_numbershift)
    );

mux_2to1 mux_inputshift(
    .a(output_regA),
    .b(output_regB),
    .sel(sel_inputshift),
    .out(output_mux_inputshift)
    );

mux_pcsource mux_pcsource(
    .aluResult(output_aluout),
    .jump_address_31_0(jump_address_31_0),
    .memData(output_memory),
    .aluOut(output_aluout),
    .epc(output_epc),
    .sel(sel_mux_pcsource),
    .out(output_mux_pcsource)
    );

mux_regdest mux_regdest(
    .instruction_20_16(output_instruction_20_16),
    .instruction_15_11(output_instruction_15_11),
    .sel(sel_regdest),
    .out(output_mux_regdest)
    );

mux_regreadone mux_regreadone(
    .instrucion_25_21(output_instruction_25_21),
    .sel(sel_reg_read_one),
    .out(output_mux_RegReadOne)
    );

mux_2to1 mux_information_lscontrol(
    .a(output_MDR),
    .b(output_regB),
    .sel(sel_lscontrol),
    .out(output_mux_information_lscontrol)
    );

mux_2to1 mux_addres_lscontrol(
    .a(output_regB),
    .b(output_MDR),
    .sel(sel_lscontrol),
    .out(output_mux_addres_lscontrol)
    );

mux_2to1 mux_memdata(
    .a(output_2_demux),
    .b(output_regB),
    .sel(sel_memdata),
    .out(output_mux_memdata)
    );

demux_1to2 demux(
    .a(output_ls_control_block), 
    .sel(sel_lscontrol), 
    .out_1(output_1_demux), 
    .out_2(output_2_demux) 
    );

zero_extend_1 zero_extend_1(
    .Data_in(menor),
    .Data_out(output_menor_extended)
    );

sign_extend_16 sign_extend_16(
    .Data_in(instruction_15_0),
    .Data_out(output_sign_extend_16)
);

shift_left_2 shift_left_2(
    .data_in(output_sign_extend_16),
    .data_out(output_shift_left_2)
);

shift_left_16 shift_left_16(
    .data_in(instruction_15_0),
    .data_out(output_shift_left_16)
);

endmodule