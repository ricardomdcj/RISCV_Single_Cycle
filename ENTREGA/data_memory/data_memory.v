module data_memory (
    input clk,       //!Clock
    input [31:0] A,  //!Endereço de leitura/escrita
    input [31:0] WD, //!Dados a serem escritos
    input WE,        //!Habilita escrita
    output [31:0] RD //!Dados lidos da memória de dados
);
    integer i;
    reg [31:0] memory [0:16383]; //!Memória de dados de 32 bits e 256 palavras

    initial begin
        // Inicializa a memória com zeros
        /*for (i = 0; i < 16384; i = i + 1) begin
            memory[i] = 32'b0;
        end*/
        memory[14'h0800] = 32'd10;
    end

    // Escrita síncrona
    always @(posedge clk) begin :ESCRITA
        if (WE) begin
            memory[A[31:2]] <= WD; //Escreve os dados na memória no endereço especificado
        end
    end

    // Leitura combinacional (assíncrona)
     assign RD = memory[A[31:2]]; //Lê os dados da memória no endereço especificado

    
endmodule