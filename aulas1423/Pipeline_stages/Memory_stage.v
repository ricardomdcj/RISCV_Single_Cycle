module Memory_stage (
    input wire clk,
    input wire [31:0] WriteData_MEM,
    input wire MemWrite_MEM,
    output wire [31:0] ReadData_MEM,
    input wire [31:0] ALUResult_MEM,
    input wire [4:0] Rd_MEM,
    input wire ResultSrc_MEM,
    input wire RegWrite_MEM
);

//DATA_MEMORY
data_memory DATA_MEMORY (
    .clk(clk),      //!Clock
    .A(ALUResult_MEM),  //!Endereço de leitura/escrita
    .WD(WriteData_MEM), //!Dados a serem escritos
    .WE(MemWrite_MEM),  //!Sinal de habilitação de escrita (ativo em 1)            
    .RD(ReadData_MEM)   //!Dados lidos da DATA_MEMORY
);
    
endmodule