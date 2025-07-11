module instruction_memory (
    input [31:0] A, //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);

    reg [31:0] memory [0:255]; //!Memória de instruções de 32 bits e 256 palavras

    initial begin
        // Inicializa a memória com algumas instruções de exemplo
        memory[0] = 32'h00000001;
        memory[1] = 32'h00000002;
        memory[2] = 32'h00000003;
        memory[3] = 32'h00000004;
    end

    always @(*) begin
        RD = memory[A[31:2]]; //!Lê a instrução da memória
    end

endmodule