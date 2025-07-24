module cpu (
    input clk,   //!Sinal de clock
	 input rst    //!Sinal de reset
);

    /* DECLARAÇÃO DOS WIRES (UTILIZADOS PARA INTERCONEXÃO DOS MÓDULOS) */

    wire        PCSrc;      //!Sinal de seleção do multiplexador MUX_PCNEXT
    wire        ResultSrc;  //!Sinal de seleção do multiplexador MUX_RESULT
    wire        MemWrite;   //!Sinal de habilitação de escrita (ativo em 1) de DATA_MEMORY 
    wire        ALUSrc;     //!Sinal de seleção do multiplexador MUX_SRCB
    wire        RegWrite;   //!Sinal de habilitação de escrita (ativo em 1) de REGISTER_FILE
    wire [1:0]  ImmSrc;     //!Sinal de seleção do tipo de extensão a ser realizada pelo EXTEND
    wire [2:0]  ALUControl; //!Sinal de seleção da operação realizada pela ALU
    wire        Zero;       //!Sinal de indicação de resultado da ALU igual a zero
    wire        funct7;     //!Sinal de lógica da CONTROL_UNIT
    wire [2:0]  funct3;     //!Sinal de lógica da CONTROL_UNIT
    wire [6:0]  op;         //!Sinal de lógica da CONTROL_UNIT

    
    /* DECLARAÇÃO DOS MÓDULOS (DESCRIÇÃO ESTRUTURAL) */

    //DATAPATH
    datapath DATAPATH(
      .clk(clk),                //!Clock
		.rst(rst),					  //!Reset
      .PCSrc(PCSrc),            //!Sinal de seleção do multiplexador MUX_PCNEXT
      .ResultSrc(ResultSrc),    //!Sinal de seleção do multiplexador MUX_RESULT
      .MemWrite(MemWrite),      //!Sinal de habilitação de escrita (ativo em 1) de DATA_MEMORY 
      .ALUSrc(ALUSrc),          //!Sinal de seleção do multiplexador MUX_SRCB
      .RegWrite(RegWrite),      //!Sinal de habilitação de escrita (ativo em 1) de REGISTER_FILE
      .ImmSrc(ImmSrc),          //!Sinal de seleção do tipo de extensão a ser realizada pelo EXTEND
      .ALUControl(ALUControl),  //!Sinal de seleção da operação realizada pela ALU
      .Zero(Zero),              //!Sinal de indicação de resultado da ALU igual a zero
      .funct7(funct7),          //!Sinal de lógica da CONTROL_UNIT
      .funct3(funct3),          //!Sinal de lógica da CONTROL_UNIT
      .op(op)                   //!Sinal de lógica da CONTROL_UNIT
    );

    //CONTROL_UNIT
    Control_Unit CONTROL_UNIT (
        .Op(op),                //!Sinal de lógica da CONTROL_UNIT
        .funct3(funct3),        //!Sinal de lógica da CONTROL_UNIT
        .funct7(funct7),        //!Sinal de lógica da CONTROL_UNIT
        .Zero(Zero),            //!Sinal de indicação de resultado da ALU igual a zero
        .PCSrc(PCSrc),          //!Sinal de seleção do multiplexador MUX_PCNEXT
        .ResultSrc(ResultSrc),  //!Sinal de seleção do multiplexador MUX_RESULT
        .MemWrite(MemWrite),    //!Sinal de habilitação de escrita (ativo em 1) de DATA_MEMORY 
        .ALUSrc(ALUSrc),        //!Sinal de seleção do multiplexador MUX_SRCB
        .ImmSrc(ImmSrc),        //!Sinal de seleção do tipo de extensão a ser realizada pelo EXTEND
        .RegWrite(RegWrite),    //!Sinal de habilitação de escrita (ativo em 1) de REGISTER_FILE
        .ALUControl(ALUControl) //!Sinal de seleção da operação realizada pela ALU
    );

endmodule