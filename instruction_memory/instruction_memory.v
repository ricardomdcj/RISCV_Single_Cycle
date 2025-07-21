module instruction_memory (
    input [31:0] A,      //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);

    reg [31:0] memory [0:1 << 16]; //!Memória de instruções de 32 bits e 256 palavras

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

/*module instruction_memory (
    input [31:0] A,      //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);

  reg [7:0] memory [0:255]; //!Memória de instruções de 32 bits e 256 palavras

    initial begin
        // Inicializa a memória com algumas instruções de exemplo múltiplas de 4
      memory[0] = 8'h11; // Instrução travada em 0
      memory[1] = 8'h44;
      memory[2] = 8'h88;
      memory[3] = 8'hCC;
      memory[4] = 8'hDD;
      memory[5] = 8'h22;
      memory[6] = 8'h33;
      memory[7] = 8'hFF;

    end

    always @(*) begin
        //RD = memory[A[31:2]]; //!Lê a instrução da memória com offset
      RD = { memory[A+3], memory[A+2], memory[A+1], memory[A]};    
    end

endmodule
*/
