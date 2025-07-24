module datapath (
    input           clk,        //!Sinal de clock
    input           rst,        //!Sinal de reset
    input           PCSrc,      //!Sinal de seleção do multiplexador MUX_PCNEXT
    input           ResultSrc,  //!Sinal de seleção do multiplexador MUX_RESULT
    input           MemWrite,   //!Sinal de habilitação de escrita (ativo em 1) de DATA_MEMORY 
    input           ALUSrc,     //!Sinal de seleção do multiplexador MUX_SRCB
    input           RegWrite,   //!Sinal de habilitação de escrita (ativo em 1) de REGISTER_FILE
    input [1:0]     ImmSrc,     //!Sinal de seleção do tipo de extensão a ser realizada pelo EXTEND
    input [2:0]     ALUControl, //!Sinal de seleção da operação realizada pela ALU
    output          Zero,       //!Sinal de indicação de resultado da ALU igual a zero
    output          funct7,     //!Sinal de lógica da CONTROL_UNIT
    output [2:0]    funct3,     //!Sinal de lógica da CONTROL_UNIT
    output [6:0]    op          //!Sinal de lógica da CONTROL_UNIT
);

    /* DECLARAÇÃO DOS WIRES (UTILIZADOS PARA INTERCONEXÃO DOS MÓDULOS) */

    wire [4:0]  A1;             //!Endereço do primeiro registrador de leitura
    wire [4:0]  A2;             //!Endereço do segundo registrador de leitura
    wire [4:0]  A3;             //!Endereço do registrador de escrita
    wire [24:0] InstrExtend;    //!Instrução a ser processada pelo EXTEND
    wire [31:0] PCNext;         //!Próximo endereço do PROGRAM_COUNTER
    wire [31:0] PC;             //!Endereço a ser lido pela INSTRUCTION_MEMORY
    wire [31:0] Result;         //!Dados a serem escritos no registrador
    wire [31:0] RD1;            //!Dados lidos do primeiro registrador
    wire [31:0] RD2;            //!Dados lidos do segundo registrador
    wire [31:0] PCPlus4;        //!Sinal de entrada do MUX DO PCNext (Entrada 0)
    wire [31:0] Instr;          //!Instrução fornecida pelo INSTRUCTION_MEMORY
    wire [31:0] PCTarget;       //!Endereço de "target" da instrução "branch"
    wire [31:0] ImmExt;         //!Saída do EXTEND   
    wire [31:0] SrcA;           //!Entrada A da ALU
    wire [31:0] SrcB;           //!Entrada B da ALU
    wire [31:0] ALUResult;      //!Resultado da ALU
    wire [31:0] WriteData;      //!Dado a ser escrito em DATA_MEMORY
    wire [31:0] ReadData;       //!Dado lido da DATA_MEMORY


    /* ASSIGN DOS WIRES NECESSÁRIOS */

    assign SrcA         = RD1;          //!Ligação entre REGISTER_FILE e ALU
    assign WriteData    = RD2;          //!Ligação entre DATA_MEMORY e REGISTER_FILE
    assign op           = Instr[6:0];   //!Extração dos bits de Instr referentes ao op da CONTROL_UNIT
    assign funct3       = Instr[14:12]; //!Extração dos bits de Instr referentes ao funct3 da CONTROL_UNIT
    assign funct7       = Instr[30];    //!Extração dos bits de Instr referentes ao funct7 da CONTROL_UNIT
    assign A1           = Instr[19:15]; //!Extração dos bits de Instr referentes ao A1 do REGISTER_FILE
    assign A2           = Instr[24:20]; //!Extração dos bits de Instr referentes ao A2 do REGISTER_FILE
    assign A3           = Instr[11:7];  //!Extração dos bits de Instr referentes ao A3 do REGISTER_FILE
    assign InstrExtend  = Instr[31:7];  //!Extração dos bits de Instr referentes à entrada do EXTEND


    /* DECLARAÇÃO DOS MÓDULOS (DESCRIÇÃO ESTRUTURAL) */

    //PROGRAM_COUNTER
    program_counter PROGRAM_COUNTER (
        .clk(clk),          //!Clock
        .PCNext(PCNext),    //!Próximo endereço do PROGRAM_COUNTER
        .PC(PC)             //!Endereço a ser lido pela INSTRUCTION_MEMORY
    );

    //INSTRUCTION_MEMORY
    instruction_memory INSTRUCTION_MEMORY (
        .A(PC),     //!Endereço a ser lido pela INSTRUCTION_MEMORY
        .RD(Instr)  //!Dados lidos da INSTRUCTION_MEMORY
    );

    //REGISTER_FILE
    register_file REGISTER_FILE (
        .clk(clk),      //!Clock
        .rst(rst),      //!Reset
        .WE3(RegWrite), //!Controle do REGISTER_FILE
        .A1(A1),        //!Endereço do primeiro registrador de leitura
        .A2(A2),        //!Endereço do segundo registrador de leitura
        .A3(A3),        //!Endereço do registrador de escrita
        .WD3(Result),   //!Dados a serem escritos no registrador
        .RD1(RD1),      //!Dados lidos do primeiro registrador
        .RD2(RD2)       //!Dados lidos do segundo registrador
    );

    //ADDER_PC
    adder ADDER_PC (
        .a(PC),         //!Endereço atual do PROGRAM_COUNTER para gerar PCNext
        .b(32'd4),      //!Constante "4" para gerar PCNext
        .sum(PCPlus4)   //!Sinal de entrada do MUX do PCNext (Entrada 0)
    );

    //MUX_PCNEXT
    Mux2x1 #(
        .N(32)          //!Multiplexador 2x1 de 32 bits
    ) MUX_PCNEXT (
        .a(PCPlus4),    //!Entrada "0"
        .b(PCTarget),   //!Entrada "1"
        .sel(PCSrc),    //!Sinal de seleção
        .y(PCNext)      //!Saída do multiplexador
    );

    //EXTEND
    extend EXTEND (
        .instr(InstrExtend),    //!Instrução a ser processada
        .immsrc(ImmSrc),        //!Comando contendo o tipo de extensão a ser realizada
        .immext(ImmExt)         //!Saída contendo a extensão da instrução
    );

    //ADDER_PCTARGET
    adder ADDER_PCTARGET (
        .a(PC),         //!Endereço atual do PROGRAM_COUNTER para gerar PCTarget
        .b(ImmExt),     //!Instrução estendida para gerar PCTarget
        .sum(PCTarget)  //!Sinal de entrada do MUX do PCTarget (Entrada 1)
    );
    
    //MUX_SRCB
    Mux2x1 #(
        .N(32)          //!Multiplexador 2x1 de 32 bits
    ) MUX_SRCB (
        .a(RD2),        //!Entrada "0"
        .b(ImmExt),     //!Entrada "1"
        .sel(ALUSrc),   //!Sinal de seleção
        .y(SrcB)      //!Saída do multiplexador
    );

    //ALU
    ALU ALU(
        .SrcA(SrcA),                //!Entrada A da ALU
        .SrcB(SrcB),                //!Entrada B da ALU
        .ALUControl(ALUControl),    //!Sinal de controle da ALU
        .ALUResult(ALUResult),      //!Resultado da ALU
        .Zero(Zero)                 //!Indicativo se o resultado da operação for zero
    );

    //DATA_MEMORY
    data_memory DATA_MEMORY (
        .clk(clk),      //!Clock
        .A(ALUResult),  //!Endereço de leitura/escrita
        .WD(WriteData), //!Dados a serem escritos
        .WE(MemWrite),  //!Sinal de habilitação de escrita (ativo em 1)            
        .RD(ReadData)   //!Dados lidos da DATA_MEMORY
    );

    //MUX_RESULT
    Mux2x1 #(
        .N(32)              //!Multiplexador 2x1 de 32 bits
    ) MUX_RESULT (      
        .a(ALUResult),      //!Entrada "0"
        .b(ReadData),       //!Entrada "1"
        .sel(ResultSrc),    //!Sinal de seleção
        .y(Result)          //!Saída do multiplexador
    );
endmodule
