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
	.addr(ALUResult_MEM[5:0]), 		//!Endereço de leitura/escrita
	.din(WriteData_MEM), 		//!Dados a serem escritos
	.writeEnable(MemWrite_MEM), //!Sinal de habilitação de escrita (ativo em 1) 
	.dout(ReadData_MEM), 		//!Dados lidos da DATA_MEMORY
	.size(funct3_MEM[1:0]),		//!Sinal de indicação de tamanho (00: byte, 01: half, 10: word)
	.sign_ext(funct3_MEM[2])	//!Sinal de extensão (0: extensão de sinal , 1: zero extension)
);
    
endmodule