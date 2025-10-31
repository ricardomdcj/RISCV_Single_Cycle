// Módulo Top-Level - CPU_Pipeline
module CPU_Pipeline_Completa (
    input clk, rst
);

// --- Estágio IF (Instruction Fetch) ---
wire [31:0] PCPlus4_IF, Instr_IF, PC_IF;

// --- Estágio ID (Instruction Decode) ---
wire [31:0] RD1_ID, RD2_ID, ImmExt_ID;
wire [4:0] Rd_ID;
wire [2:0] ALUControl_ID;
wire [1:0] ImmSrc_ID;
wire RegWrite_ID, MemWrite_ID, Branch_ID, ALUSrc_ID, ResultSrc_ID;
reg [31:0] Instr_ID, PC_ID;
wire [2:0] funct3_ID; // <<< CORREÇÃO 1: Alterado de 'reg' para 'wire'

// --- Estágio EXE (Execute) ---
wire [31:0] ALUResult_EXE, WriteData_EXE, PCTarget_EXE;
wire PCSrc_EXE;
reg [31:0] RD1_EXE, RD2_EXE, PC_EXE, ImmExt_EXE;
reg [4:0] Rd_EXE;
reg [2:0] ALUControl_EXE;
reg Branch_EXE, ALUSrc_EXE, RegWrite_EXE, MemWrite_EXE, ResultSrc_EXE;
reg [2:0] funct3_EXE;

// --- Estágio MEM (Memory Access) ---
wire [31:0] ReadData_MEM;
reg [31:0] WriteData_MEM, ALUResult_MEM;
reg [4:0] Rd_MEM;
reg MemWrite_MEM, ResultSrc_MEM, RegWrite_MEM;
reg [2:0] funct3_MEM;

// --- Estágio WB (Write Back) ---
wire [31:0] Result_WB;
reg [31:0] ReadData_WB, ALUResult_WB;
reg [4:0] Rd_WB;
reg ResultSrc_WB, RegWrite_WB;

always @(posedge clk) begin
    // --- Propagação do estágio IF para o ID ---
    // A instrução e seu endereço (PC) avançam para o estágio de decodificação.
    Instr_ID <= Instr_IF;
    PC_ID <= PC_IF;

    // --- Propagação do estágio ID para o EXE ---
    // Os dados lidos do banco de registradores (RD1, RD2), o imediato, o endereço do registrador
    // de destino (Rd) e todos os sinais de controle avançam para o estágio de execução.
    PC_EXE <= PC_ID;
    RD1_EXE <= RD1_ID;
    RD2_EXE <= RD2_ID;
    ImmExt_EXE <= ImmExt_ID;
    Rd_EXE <= Rd_ID;
    ALUControl_EXE <= ALUControl_ID;
    ALUSrc_EXE <= ALUSrc_ID;
    Branch_EXE <= Branch_ID;
    MemWrite_EXE <= MemWrite_ID;
    ResultSrc_EXE <= ResultSrc_ID;
    RegWrite_EXE <= RegWrite_ID;
	funct3_EXE <= funct3_ID;

    // --- Propagação do estágio EXE para o MEM ---
    // O resultado da ALU, o dado a ser escrito na memória (vindo de RD2), o Rd e os
    // sinais de controle para MEM e WB avançam para o estágio de memória.
    // Os sinais Branch, ALUSrc e ALUControl não avançam, pois foram usados em EXE.
    ALUResult_MEM <= ALUResult_EXE;
    WriteData_MEM <= WriteData_EXE;
    Rd_MEM <= Rd_EXE;
    MemWrite_MEM <= MemWrite_EXE;
    ResultSrc_MEM <= ResultSrc_EXE;
    RegWrite_MEM <= RegWrite_EXE;
	funct3_MEM <= funct3_EXE;

    // --- Propagação do estágio MEM para o WB ---
    // O dado lido da memória, o resultado da ALU (que passou direto pelo estágio MEM),
    // o Rd e os sinais de controle para WB avançam para o estágio de escrita.
    // O sinal MemWrite não avança, pois foi usado em MEM.
    ReadData_WB <= ReadData_MEM;
    ALUResult_WB <= ALUResult_MEM;
    Rd_WB <= Rd_MEM;
    ResultSrc_WB <= ResultSrc_MEM;
    RegWrite_WB <= RegWrite_MEM;
end

Fetch_stage INSTRUCTION_FETCH (
    .clk(clk),
    .PCTarget_EXE(PCTarget_EXE),
    .PCSrc_EXE(PCSrc_EXE),
    .PCPlus4_IF(PCPlus4_IF),
    .Instr_IF(Instr_IF),
    .PC_IF(PC_IF)
);
    
Decoder_stage INSTRUCTION_DECODER (
    .clk(clk),
    .rst(rst),
    .RegWrite_WB(RegWrite_WB),
    .Instr_ID(Instr_ID),
    .Result_WB(Result_WB),
    .Rd_WB(Rd_WB),
    .RegWrite_ID(RegWrite_ID),
    .MemWrite_ID(MemWrite_ID),
    .Branch_ID(Branch_ID),
    .ALUSrc_ID(ALUSrc_ID),
    .ResultSrc_ID(ResultSrc_ID),
    .ImmSrc_ID(ImmSrc_ID),
    .ALUControl_ID(ALUControl_ID),
    .Rd_ID(Rd_ID),
    .RD1_ID(RD1_ID),
    .RD2_ID(RD2_ID),
    .ImmExt_ID(ImmExt_ID),
    .PC_ID(PC_ID),
	.funct3_ID(funct3_ID)
);

Execution_stage EXECUTE (
    .Branch_EXE(Branch_EXE),
    .ALUSrc_EXE(ALUSrc_EXE),
    .ALUControl_EXE(ALUControl_EXE),
    .RD1_EXE(RD1_EXE),
    .RD2_EXE(RD2_EXE),
    .PC_EXE(PC_EXE),
    .ImmExt_EXE(ImmExt_EXE),
    .ALUResult_EXE(ALUResult_EXE),
    .PCTarget_EXE(PCTarget_EXE),
    .WriteData_EXE(WriteData_EXE),
    .PCSrc_EXE(PCSrc_EXE),
    .RegWrite_EXE(RegWrite_EXE),
    .MemWrite_EXE(MemWrite_EXE),
    .ResultSrc_EXE(ResultSrc_EXE),
    .Rd_EXE(Rd_EXE)
);

Memory_stage MEMORY (
    .clk(clk),
    .WriteData_MEM(WriteData_MEM),
    .MemWrite_MEM(MemWrite_MEM),
    .ReadData_MEM(ReadData_MEM),
    .ALUResult_MEM(ALUResult_MEM),
    .Rd_MEM(Rd_MEM),
    .ResultSrc_MEM(ResultSrc_MEM),
    .RegWrite_MEM(RegWrite_MEM),
	.funct3_MEM(funct3_MEM)
);

WriteBack_stage WriteBack (
    .ReadData_WB(ReadData_WB),
    .ALUResult_WB(ALUResult_WB),
    .ResultSrc_WB(ResultSrc_WB),
    .Result_WB(Result_WB),
    .Rd_WB(Rd_WB),
    .RegWrite_WB(RegWrite_WB)
);

endmodule


// Módulo Fetch_stage
module Fetch_stage (
    input wire clk,
    input wire [31:0] PCTarget_EXE,
    input wire PCSrc_EXE,
    output wire [31:0] PCPlus4_IF,
    output wire [31:0] Instr_IF,
    output wire [31:0] PC_IF
);

wire [31:0] PCMux_IF;

//MUX_PCNEXT
Mux2x1 #(
    .N(32)          //!Multiplexador 2x1 de 32 bits
) MUX_PCNEXT (
    .a(PCPlus4_IF),    //!Entrada "0"
    .b(PCTarget_EXE),   //!Entrada "1"
    .sel(PCSrc_EXE),    //!Sinal de seleção
    .y(PCMux_IF)      //!Saída do multiplexador
);

//ADDER_PC
adder ADDER_PC (
    .a(PC_IF),         //!Endereço atual do PROGRAM_COUNTER para gerar PCNext
    .b(32'd4),      //!Constante "4" para gerar PCNext
    .sum(PCPlus4_IF)   //!Sinal de entrada do MUX do PCNext (Entrada 0)
);

//PROGRAM_COUNTER
program_counter PROGRAM_COUNTER (
    .clk(clk),          //!Clock
    .PCNext(PCMux_IF),    //!Próximo endereço do PROGRAM_COUNTER
    .PC(PC_IF)             //!Endereço a ser lido pela INSTRUCTION_MEMORY
);

//INSTRUCTION_MEMORY
instruction_memory INSTRUCTION_MEMORY (
    .A(PC_IF),     //!Endereço a ser lido pela INSTRUCTION_MEMORY
    .RD(Instr_IF)  //!Dados lidos da INSTRUCTION_MEMORY
);
    
endmodule


// Módulo Decoder_stage
module Decoder_stage (
    input wire clk,
    input wire rst,
    input wire RegWrite_WB,
    input wire [31:0] Instr_ID,
    input wire [31:0] Result_WB,
    input wire [4:0] Rd_WB,
    output wire RegWrite_ID,
    output wire MemWrite_ID,
    output wire Branch_ID,
    output wire ALUSrc_ID,
    output wire ResultSrc_ID,
    output wire [1:0] ImmSrc_ID,
    output wire [2:0] ALUControl_ID,
    output wire [4:0] Rd_ID,
    output wire [31:0] RD1_ID,
    output wire [31:0] RD2_ID,
    output wire [31:0] ImmExt_ID,
    input wire [31:0] PC_ID,
	output wire [2:0] funct3_ID
);

wire [24:0] InstrExtend;
wire [6:0] op;
wire [2:0] funct3;
wire [4:0] A1;
wire [4:0] A2;
wire [4:0] A3;
wire funct7;

//ASSIGN wire DOS WIRES NECESSÁRIOS
assign InstrExtend  = Instr_ID[31:7];  //!Extração dos bits de Instr referentes à entrada do EXTEND
assign op           = Instr_ID[6:0];   //!Extração dos bits de Instr referentes ao op da CONTROL_UNIT
assign Rd_ID        = Instr_ID[11:7];   //!Extração dos bits de Instr referentes ao op da CONTROL_UNIT
assign funct3       = Instr_ID[14:12]; //!Extração dos bits de Instr referentes ao funct3 da CONTROL_UNIT
assign A1           = Instr_ID[19:15]; //!Extração dos bits de Instr referentes ao A1 do REGISTER_FILE
assign A2           = Instr_ID[24:20]; //!Extração dos bits de Instr referentes ao A2 do REGISTER_FILE
assign A3           = Instr_ID[11:7];  //!Extração dos bits de Instr referentes ao A3 do REGISTER_FILE
assign funct7       = Instr_ID[30];    //!Extração dos bits de Instr referentes ao funct7 da CONTROL_UNIT
assign funct3_ID    = Instr_ID[14:12]; //!Extração dos bits de Instr referentes ao funct3 da CONTROL_UNIT para a DATA_MEMORY

//REGISTER_FILE
register_file REGISTER_FILE (
    .clk(~clk),      //!Clock
    .rst(rst),      //!Reset
    .WE3(RegWrite_WB), //!Controle do REGISTER_FILE
    .A1(A1),        //!Endereço do primeiro registrador de leitura
    .A2(A2),        //!Endereço do segundo registrador de leitura
    .A3(Rd_WB),        //!Endereço do registrador de escrita
    .WD3(Result_WB),   //!Dados a serem escritos no registrador
    .RD1(RD1_ID),      //!Dados lidos do primeiro registrador
    .RD2(RD2_ID)       //!Dados lidos do segundo registrador
);

//CONTROL_UNIT
Control_Unit CONTROL_UNIT (
    .Op(op),                //!Sinal de lógica da CONTROL_UNIT
    .funct3(funct3),        //!Sinal de lógica da CONTROL_UNIT
    .funct7(funct7),        //!Sinal de lógica da CONTROL_UNIT
    .ResultSrc(ResultSrc_ID),  //!Sinal de seleção do multiplexador MUX_RESULT
    .MemWrite(MemWrite_ID),    //!Sinal de habilitação de escrita (ativo em 1) de DATA_MEMORY 
    .ALUSrc(ALUSrc_ID),        //!Sinal de seleção do multiplexador MUX_SRCB
    .ImmSrc(ImmSrc_ID),        //!Sinal de seleção do tipo de extensão a ser realizada pelo EXTEND
    .RegWrite(RegWrite_ID),    //!Sinal de habilitação de escrita (ativo em 1) de REGISTER_FILE
    .ALUControl(ALUControl_ID), //!Sinal de seleção da operação realizada pela ALU
    .Branch(Branch_ID)
);

//EXTEND
extend EXTEND (
    .instr(InstrExtend),    //!Instrução a ser processada
    .immsrc(ImmSrc_ID),        //!Comando contendo o tipo de extensão a ser realizada
    .immext(ImmExt_ID)         //!Saída contendo a extensão da instrução
);
    
endmodule


// Módulo Execution_stage
module Execution_stage (
    input wire Branch_EXE,
    input wire ALUSrc_EXE,
    input wire [2:0] ALUControl_EXE,
    input wire [31:0] RD1_EXE,
    input wire [31:0] RD2_EXE,
    input wire [31:0] PC_EXE,
    input wire [31:0] ImmExt_EXE,
    output wire [31:0] ALUResult_EXE,
    output wire [31:0] PCTarget_EXE,
    output wire [31:0] WriteData_EXE,
    output wire PCSrc_EXE,
    input wire RegWrite_EXE,
    input wire MemWrite_EXE,
    input wire ResultSrc_EXE,
    input wire [4:0] Rd_EXE
);

wire [31:0] ALUSrcB; //!Entrada B da ALU
wire Zero_EXE;

assign PCSrc_EXE = Zero_EXE & Branch_EXE;
assign WriteData_EXE = RD2_EXE;

//MUX_SRCB
Mux2x1 #(
    .N(32)          //!Multiplexador 2x1 de 32 bits
) MUX_SRCB (
    .a(RD2_EXE),        //!Entrada "0"
    .b(ImmExt_EXE),     //!Entrada "1"
    .sel(ALUSrc_EXE),   //!Sinal de seleção
    .y(ALUSrcB)      //!Saída do multiplexador
);

//ALU
ALU ALU(
    .SrcA(RD1_EXE),                //!Entrada A da ALU
    .SrcB(ALUSrcB),                //!Entrada B da ALU
    .ALUControl(ALUControl_EXE),    //!Sinal de controle da ALU
    .ALUResult(ALUResult_EXE),      //!Resultado da ALU
    .Zero(Zero_EXE)                 //!Indicativo se o resultado da operação for zero
);

//ADDER_PCTARGET
adder ADDER_PCTARGET (
    .a(PC_EXE),         //!Endereço atual do PROGRAM_COUNTER para gerar PCTarget
    .b(ImmExt_EXE),     //!Instrução estendida para gerar PCTarget
    .sum(PCTarget_EXE)  //!Sinal de entrada do MUX do PCTarget (Entrada 1)
);
    
endmodule


// Módulo Memory_stage
module Memory_stage (
    input wire clk,
    input wire [31:0] WriteData_MEM,
    input wire MemWrite_MEM,
    output wire [31:0] ReadData_MEM,
    input wire [31:0] ALUResult_MEM,
    input wire [4:0] Rd_MEM,
    input wire ResultSrc_MEM,
    input wire RegWrite_MEM,
	input wire [2:0] funct3_MEM
);

//DATA_MEMORY
//data_memory DATA_MEMORY (
//    .clk(clk),      //!Clock
//    .A(ALUResult_MEM),  //!Endereço de leitura/escrita
//    .WD(WriteData_MEM), //!Dados a serem escritos
//    .WE(MemWrite_MEM),  //!Sinal de habilitação de escrita (ativo em 1)            
//    .RD(ReadData_MEM)   //!Dados lidos da DATA_MEMORY
//);

memTopo32LittleEndian DATA_MEMORY_ADDRESSABLE (
	.clk(clk),      			//!Clock
	.addr(ALUResult_MEM[5:0]), 	//!Endereço de leitura/escrita <<< CORREÇÃO 2: Conectando apenas 6 bits
	.din(WriteData_MEM), 		//!Dados a serem escritos
	.writeEnable(MemWrite_MEM), //!Sinal de habilitação de escrita (ativo em 1) 
	.dout(ReadData_MEM), 		//!Dados lidos da DATA_MEMORY
	.size(funct3_MEM[1:0]),		//!Sinal de indicação de tamanho (00: byte, 01: half, 10: word)
	.sign_ext(funct3_MEM[2])	//!Sinal de extensão (0: extensão de sinal , 1: zero extension)
);
    
endmodule


// Módulo WriteBack_stage
module WriteBack_stage (
    input wire [31:0] ReadData_WB,
    input wire [31:0] ALUResult_WB,
    input wire ResultSrc_WB,
    output wire [31:0] Result_WB,
    input wire [4:0] Rd_WB,
    input wire RegWrite_WB
);

//MUX_RESULT
Mux2x1 #(
    .N(32)              //!Multiplexador 2x1 de 32 bits
) MUX_RESULT (      
    .a(ALUResult_WB),      //!Entrada "0"
    .b(ReadData_WB),       //!Entrada "1"
    .sel(ResultSrc_WB),    //!Sinal de seleção
    .y(Result_WB)          //!Saída do multiplexador
);
    
endmodule

// Módulo instruction_memory (dados embutidos)
module instruction_memory (
    input [31:0] A,      //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);
    // Memória de instruções de 8 bits (byte) e 1024 posições
    reg [7:0] memory [0:1023]; 
    integer j; // Declarado aqui

    initial begin
        // Dados do ativ5_instr.txt
        memory[0] = 8'h93; memory[1] = 8'h02; memory[2] = 8'h00; memory[3] = 8'h00; // addi t0, x0, 0
        memory[4] = 8'h13; memory[5] = 8'h03; memory[6] = 8'h00; memory[7] = 8'h01; // addi t1, x0, 16
        memory[8] = 8'h83; memory[9] = 8'h83; memory[10] = 8'h02; memory[11] = 8'h00; // lb t2, 0(t0)
        memory[12] = 8'h03; memory[13] = 8'hce; memory[14] = 8'h02; memory[15] = 8'h00; // lbu t3, 0(t0)
        memory[16] = 8'h83; memory[17] = 8'h9e; memory[18] = 8'h22; memory[19] = 8'h00; // lh t4, 2(t0)
        memory[20] = 8'h03; memory[21] = 8'hdf; memory[22] = 8'h22; memory[23] = 8'h00; // lhu t5, 2(t0)
        memory[24] = 8'h83; memory[25] = 8'haf; memory[26] = 8'h42; memory[27] = 8'h00; // lw t6, 4(t0)
        memory[28] = 8'h23; memory[29] = 8'h00; memory[30] = 8'h73; memory[31] = 8'h00; // sb t2, 0(t1)
        memory[32] = 8'ha3; memory[33] = 8'h00; memory[34] = 8'hc3; memory[35] = 8'h01; // sb t3, 1(t1)
        memory[36] = 8'h23; memory[37] = 8'h11; memory[38] = 8'hd3; memory[39] = 8'h01; // sh t4, 2(t1)
        memory[40] = 8'h23; memory[41] = 8'h12; memory[42] = 8'he3; memory[43] = 8'h01; // sh t5, 4(t1)
        memory[44] = 8'h23; memory[45] = 8'h24; memory[46] = 8'hf3; memory[47] = 8'h01; // sw t6, 8(t1)
        memory[48] = 8'h93; memory[49] = 8'h03; memory[50] = 8'hf0; memory[51] = 8'h07; // addi t2, x0, 127
        memory[52] = 8'h23; memory[53] = 8'h06; memory[54] = 8'h73; memory[55] = 8'h00; // sb t2, 12(t1)
        memory[56] = 8'h13; memory[57] = 8'h0e; memory[58] = 8'he0; memory[59] = 8'hff; // addi t3, x0, -2
        memory[60] = 8'h23; memory[61] = 8'h17; memory[62] = 8'hc3; memory[63] = 8'h01; // sh t3, 14(t1)
        memory[64] = 8'h6f; memory[65] = 8'h00; memory[66] = 8'h00; memory[67] = 8'h00; // j end_loop
        
        // integer j; // Movido para o topo do módulo
        for (j = 68; j < 1024; j = j + 1) begin
            memory[j] = 8'h00;
        end
    end

    always @(*) begin
        // Combina 4 bytes (8 bits cada) em uma instrução de 32 bits (Little-Endian)
        // O endereço 'A' vindo do PC começa em 32'h1000 para a primeira instrução
        RD = {memory[A - 32'h1000 + 3], memory[A - 32'h1000 + 2], memory[A - 32'h1000 + 1], memory[A - 32'h1000 + 0]};
    end

endmodule

// Módulo extend (Adicionado)
module extend (
    input [31:7] instr,      //! Imediato da instrução a ser processada
    input [1:0]  immsrc,     //! Comando contendo o tipo de extensão a ser realizado
    output reg [31:0] immext //! Saída contendo a extensão da instrução
);

always @(*) begin
    case (immsrc)
        2'b00: immext = { {20{instr[31]}}, instr[31:20] }; // I-type
        2'b01: immext = { {20{instr[31]}}, instr[31:25], instr[11:7] }; // S-type (store)
        2'b10: immext = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 }; // B-type (branches)
        2'b11: immext = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 }; // J-type (jal)
        default: immext = 32'bx; // undefined
    endcase
end

endmodule

// Módulo Main_decoder (Adicionado)
// RETIRADO DA TABELA 7.2 NA PÁGINA 408 DA BIBLIOGRAFIA
module Main_decoder (
    input [6:0] Op,
    output reg Branch,
    output reg ResultSrc,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

// Instruções possíveis
localparam lw =     7'b0000011,
           sw =     7'b0100011,
           R_type = 7'b0110011,
           beq =    7'b1100011,
           addi =   7'b0010011;

always @(*) begin
    Branch = 1'b0;
    ResultSrc = 1'b0;
    MemWrite = 1'b0;
    ALUSrc = 1'b0;
    ImmSrc = 2'b00;
    RegWrite = 1'b0;
    ALUOp = 2'b00;
    case (Op)
        lw: begin
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ResultSrc = 1'b1;
        end
        sw: begin
            ImmSrc = 2'b01;
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
        end
        R_type: begin
            RegWrite = 1'b1;
            ALUOp = 2'b10;
        end
        beq: begin
            ImmSrc = 2'b10;
            Branch = 1'b1;
            ALUOp = 2'b01;
        end
        addi: begin
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 2'b10;
        end
    endcase
end

endmodule

// Módulo Mux2x1 (Adicionado)
module Mux2x1 #(parameter N = 8)
(
    input [N-1:0] a,
    input [N-1:0] b,
    input sel,
    output [N-1:0] y

);
    assign y = sel ? b : a;    
endmodule

// Módulo program_counter (Adicionado)
module program_counter (
    input wire clk,
    input wire [31:0] PCNext,
    output reg [31:0] PC
);

    initial begin
        PC <= 32'h1000;
    end
    
    always @(posedge clk) begin
        PC <= PCNext;
    end

endmodule

// Módulo register_file (Adicionado)
module register_file (
    input clk,         //!Sinal de clock
    input rst,         //!Sinal de reset
    input WE3,         //!Write enable input
    input [4:0] A1,    //!Endereço do primeiro registrador de leitura
    input [4:0] A2,    //!Endereço do segundo registrador de leitura,
    input [4:0] A3,    //!Endereço do registrador de escrita
    input [31:0] WD3,  //!Dados a serem escritos no registrador
    output [31:0] RD1, //!Dados lidos do primeiro registrador
    output [31:0] RD2  //!Dados lidos do segundo registrador
);

    integer i;    

    reg [31:0] registers [0:31]; //!Banco de registradores de 32 bits

    // Escrita síncrona
    always @(posedge clk, posedge rst) begin :ESCRITA
        if (rst) begin
            for (i = 0; i < 32; i = i +1 ) begin: RESET
                registers[i] = 32'b0;
            end
            //registers[5] = 32'd6;
            //registers[9] = 32'h2004;
        end else if (WE3 & (A3 != 5'd0)) begin
            registers[A3] <= WD3; //!Escreve os dados no registrador especificado
        end
    end

    // Leitura combinacional (assíncrona)
    assign RD1 = (A1 == 5'd0) ? 32'd0 : registers[A1]; //Lê o primeiro registrador
    assign RD2 = (A2 == 5'd0) ? 32'd0 : registers[A2]; //Lê o segundo registrador
    
endmodule

// Módulo adder (Adicionado)
module adder (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] sum
);

    assign sum = a + b;
   
endmodule

// Módulo ALU (Adicionado)
module ALU (
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0] ALUControl,
    output reg [31:0] ALUResult,
    output reg Zero
);

    initial begin
        Zero = 0;
    end

    always @ (*) begin

        case (ALUControl)
            3'b000: ALUResult = SrcA + SrcB; // Soma
            3'b001: ALUResult = SrcA - SrcB; // Subtração
            3'b010: ALUResult = SrcA & SrcB; // AND
            3'b011: ALUResult = SrcA | SrcB; // OR
            3'b101: ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 32'd1 : 32'd0; // SLT  
            default: ALUResult = 32'd0; 
        endcase

        if (ALUResult == 32'd0) begin
            Zero = 1'b1;
        end else begin
            Zero = 1'b0;
        end
    end
    
endmodule

// Módulo ALU_decoder (Adicionado)
// RETIRADO DA TABELA 7.3 NA PÁGINA 409 DA BIBLIOGRAFIA
module ALU_decoder (
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7, op,
    output reg [2:0] ALUControl
);

// operações possíveis da ALU
localparam ADD = 3'b000,
           SUB = 3'b001,
           AND = 3'b010,
           OR =  3'b011,
           SLT = 3'b101;

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = ADD; // instruction lw,sw
        2'b01: ALUControl = SUB; // instruction beq
        2'b10: begin
            case (funct3)
                3'b000: begin
                    if ({op,funct7} == 2'b11) begin
                        ALUControl = SUB; // instruction sub
                    end else begin
                        ALUControl = ADD; // instruction add
                    end
                end
                3'b010: ALUControl = SLT; // instruction slt
                3'b110: ALUControl = OR; // instruction or
                3'b111: ALUControl = AND; // instruction AND
                default: ALUControl = ADD; // caso inválido
            endcase
        end
        default: ALUControl = ADD; // caso inválido
    endcase
end

endmodule

// Módulo Control_Unit (Adicionado)
module Control_Unit (
    input [6:0] Op,
    input [2:0] funct3,
    input funct7,
    output ResultSrc,
    output MemWrite,
    output ALUSrc,
    output [1:0] ImmSrc,
    output RegWrite,
    output [2:0] ALUControl,
    output Branch
);

wire [1:0] ALUOp;

Main_decoder MainDecoder (
.Op(Op),
.Branch(Branch),
.ResultSrc(ResultSrc),
.MemWrite(MemWrite),
.ALUSrc(ALUSrc),
.ImmSrc(ImmSrc),
.RegWrite(RegWrite),
.ALUOp(ALUOp)
);

ALU_decoder ALUDecoder (
.ALUOp(ALUOp),
.funct3(funct3),
.funct7(funct7),
.op(Op[5]),
.ALUControl(ALUControl)
);
    
endmodule

// --- MÓDULOS DA MEMÓRIA DE DADOS (EMBUTIDA) ---

module memReadManager (
    input wire [31:0] dout, //! Palavra lida da memória (sempre 32 bits)
    input wire [1:0] addr_offset , //! addr[1:0] (offset do byte)
    input wire [1:0] size, //! funct3[1:0] 00: byte, 01: half-word, 10: word
    input wire sign_extend , //! funct3[2] 0: extensão de sinal , 1: zero extension
    output reg [31:0] rdata //! Dado lido final , com extensão adequada
);
	reg [7:0] byte_data;
	reg [15:0] halfword_data;
	
	always @(*) begin
		case (addr_offset)
			2'b00: begin
			byte_data = dout[7:0];
			halfword_data = dout[15:0];
			end
			2'b01: begin
			byte_data = dout[15:8];
			halfword_data = dout[23:8];
			end
			2'b10: begin
			byte_data = dout[23:16];
			halfword_data = dout[31:16];
			end
			2'b11: begin
			byte_data = dout[31:24];
			halfword_data = {8'b0, dout[31:24]}; // inválido p/ halfword
			end
			default: begin
			byte_data = 8'b0;
			halfword_data = 16'b0;
			end
		endcase
		case (size)
			2'b00: begin
			rdata = ~sign_extend ?
			{{24{byte_data[7]}}, byte_data} :
			{24'b0, byte_data};
			end
			2'b01: begin
			rdata = ~sign_extend ?
			{{16{halfword_data[15]}}, halfword_data} :
			{16'b0, halfword_data};
			end
			2'b10: begin
			rdata = dout;
			end
			default: begin
			rdata = 32'hDEADBEEF; // erro leitura inválida
			end
		endcase
	end
endmodule

module memory_write_first #(
    parameter DATA_WIDTH = 8,
    parameter ADDRESS_WIDTH = 4
)(
    input wire clk,
    input wire we,
    input wire [ADDRESS_WIDTH -1:0] addr,
    input wire [DATA_WIDTH -1:0] din,
    output reg [DATA_WIDTH -1:0] dout
);
    localparam DEPTH = 1 << ADDRESS_WIDTH;
    reg [DATA_WIDTH -1:0] mem [0:DEPTH -1];
    always @(posedge clk) begin
        if (we) mem[addr] <= din;
        dout <= we ? din : mem[addr]; // tem prioridade
    end
    always @(*) dout <= mem[addr]; //leitura assinc.
endmodule

module memByteAddressable32WF #(
	parameter DATA_WIDTH = 32,
	parameter ADDRESS_WIDTH = 4
)(
	input wire clk,
	input wire [3:0] byteEnable ,
	input wire [ADDRESS_WIDTH -1:0] addr,
	input wire [DATA_WIDTH -1:0] din,
	output wire [DATA_WIDTH -1:0] dout
);

    // --- CORREÇÃO: Declaração 'integer i' movida para ANTES das instâncias ---
    integer i; 

	memory_write_first
	#(.DATA_WIDTH(8),
	.ADDRESS_WIDTH(4)) mem_byte0( // LSB - byteEnable[0] - din[7:0]
		.clk(clk),
		.we(byteEnable[0]),
		.addr(addr),
		.din(din[7:0]),
		.dout(dout[7:0])
	);

	memory_write_first
	#(.DATA_WIDTH(8),
	.ADDRESS_WIDTH(4)) mem_byte1( // byteEnable[1] - din[15:8]
		.clk(clk),
		.we(byteEnable[1]),
		.addr(addr),
		.din(din[15:8]),
		.dout(dout[15:8])
	);

	memory_write_first
	#(.DATA_WIDTH(8),
	.ADDRESS_WIDTH(4)) mem_byte2( // byteEnable[2] - din[23:16]
		.clk(clk),
		.we(byteEnable[2]),
		.addr(addr),
		.din(din[23:16]),
		.dout(dout[23:16])
	);

	memory_write_first
	#(.DATA_WIDTH(8),
	.ADDRESS_WIDTH(4)) mem_byte3( // MSB - byteEnable[3] - din[31:24]
		.clk(clk),
		.we(byteEnable[3]),
		.addr(addr),
		.din(din[31:24]),
		.dout(dout[31:24])
	);
	
    // --- O bloco Initial agora vem DEPOIS das instâncias ---
    initial begin
        // Carregamento de dados embutido (Hardcoded)
        // Endereço 0 (word 0): 56783412 (Little-Endian: 12 34 78 56)
        // .byte 0x12, .byte 0x34, .hword 0x5678
        mem_byte0.mem[0] = 8'h12;
        mem_byte1.mem[0] = 8'h34;
        mem_byte2.mem[0] = 8'h78;
        mem_byte3.mem[0] = 8'h56;
        
        // Endereço 1 (word 1): 9abcdef0 (Little-Endian: f0 de bc 9a)
        // .word 0x9ABCDEF0
        mem_byte0.mem[1] = 8'hf0;
        mem_byte1.mem[1] = 8'hde;
        mem_byte2.mem[1] = 8'hbc;
        mem_byte3.mem[1] = 8'h9a;

        // Inicializa o resto da memória com 0
        for (i = 2; i < (1 << ADDRESS_WIDTH); i = i + 1) begin
            mem_byte0.mem[i] = 8'h00;
            mem_byte1.mem[i] = 8'h00;
            mem_byte2.mem[i] = 8'h00;
            mem_byte3.mem[i] = 8'h00;
        end
    end
	
endmodule

module byteEnableDecoder (
	input wire [1:0] addr_offset , //! addr[1:0] mem alinhada
	input wire [1:0] size, //! funct3[1:0] 00: byte, 01: half, 10: word
	output reg [3:0] byteEnable , //! Saida em One Hot para Memoria
	input writeEnable //! Habilita escrita (vem do controle)
);
always @(*) begin
    if (!writeEnable)
        byteEnable = 4'b0000;
    else begin
        case (size)
            2'b00: byteEnable = 4'b0001 << addr_offset; // SB
            2'b01: begin
            case (addr_offset)
                2'b00: byteEnable = 4'b0011;
                2'b01: byteEnable = 4'b0110;
                2'b10: byteEnable = 4'b1100;
                default: byteEnable = 4'b0000; // desalinhado
            endcase
            end
            2'b10: byteEnable = 4'b1111; // SW
			//2'b10: byteEnable = (addr_offset == 2'b00) ? 4'b1111 : 4'b0000; // SW só alinhado
            default: byteEnable = 4'b0000;
        endcase
    end
end
endmodule

module memTopo32LittleEndian #(
	parameter DATA_WIDTH = 32,
	parameter ADDRESS_WIDTH = 6
	//parameter ADDRESS_WIDTH = 32
)(
	input wire clk, //! Clock
	input wire [1:0] size, //! funct3[1:0] 00: byte, 01: half, 10: word
	input wire [ADDRESS_WIDTH -1:0] addr, //! Endereco
	input wire [DATA_WIDTH -1:0] din, //! Entrada de dados
	input wire sign_ext , //! funct3[2] 0: extensão de sinal , 1: zero extension
	input wire writeEnable , //! Habilita escrita (vem do controle)
	output wire [DATA_WIDTH -1:0] dout //! Saida de dados
);
    // --- CORREÇÃO: Todas as declarações movidas para o topo ---
	wire [3:0] byteEnable;
	wire [31:0] mem_dout;
	wire [31:0] rdata;
    reg [31:0] din_shifted; 

    // --- O bloco Always agora vem ANTES das instâncias ---
    // Lógica para deslocar o dado de entrada (din) com base no offset do endereço
    always @(*) begin
        case (addr[1:0])
            2'b00: din_shifted = din;
            2'b01: din_shifted = din << 8;
            2'b10: din_shifted = din << 16;
            2'b11: din_shifted = din << 24;
            default: din_shifted = din; // Padrão seguro
        endcase
    end

    // --- Instâncias agora vêm DEPOIS das declarações e blocos always ---
	byteEnableDecoder decoder (
		.addr_offset(addr[1:0]),
		.size(size),
		.byteEnable(byteEnable),
		.writeEnable(writeEnable)
	);

	memByteAddressable32WF mem_inst (
		.clk(clk),
		.byteEnable(byteEnable),
		.addr(addr[5:2]), // endereçamento por palavra (alinhado)
		.din(din_shifted), // <<< CORREÇÃO (din_shifted)
		.dout(mem_dout)
	);

	memReadManager read_inst (
		.dout(mem_dout),
		.addr_offset(addr[1:0]),
		.size(size),
		.sign_extend(sign_ext),
		.rdata(rdata)
	);

	assign dout = rdata;

endmodule

