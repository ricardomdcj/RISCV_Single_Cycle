module instruction_memory (
    input [31:0] A,      //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);

    reg [7:0] memory [0:1023]; //!Memória de instruções de 32 bits e 1024 palavras

    initial begin
        // Inicializa a memória com as instruções
        memory[10'h0] = 8'h03;
		memory[10'h1] = 8'hA3;
		memory[10'h2] = 8'hC4;
		memory[10'h3] = 8'hFF;
		memory[10'h4] = 8'h23;
		memory[10'h5] = 8'hA4;
		memory[10'h6] = 8'h64;
		memory[10'h7] = 8'h00;
		memory[10'h8] = 8'h33;
		memory[10'h9] = 8'hE2;
		memory[10'hA] = 8'h62;
		memory[10'hB] = 8'h00;
		memory[10'hC] = 8'hE3;
		memory[10'hD] = 8'h0A;
		memory[10'hE] = 8'h42;
		memory[10'hF] = 8'hFE;
    end

    always @(*) begin
        RD = {memory[A - 32'h1000 + 3], memory[A - 32'h1000 + 2], memory[A - 32'h1000 + 1], memory[A - 32'h1000 + 0]};
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