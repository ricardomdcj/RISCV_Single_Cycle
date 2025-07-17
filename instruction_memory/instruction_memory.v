module instruction_memory (
    input [31:0] A,      //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);

    reg [31:0] memory [0:255]; //!Memória de instruções de 32 bits e 256 palavras

    initial begin
        // Inicializa a memória com algumas instruções de exemplo múltiplas de 4
        memory[0] = 32'h00000000; // Instrução travada em 0
        memory[1] = 32'h00000004;
        memory[2] = 32'h00000008;
        memory[3] = 32'h0000000C;
    end

    always @(*) begin
        RD = memory[A[31:2]]; //!Lê a instrução da memória com offset
        //RD = memory[A[31:0]]; //!Lê a instrução da memória sem offset
    end

endmodule