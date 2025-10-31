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