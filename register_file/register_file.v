module register_file (
    input CLK,         //!Sinal de clock
    input WE3,         //!Write enable input
    input [4:0] A1,    //!Endereço do primeiro registrador de leitura
    input [4:0] A2,    //!Endereço do segundo registrador de leitura,
    input [4:0] A3,    //!Endereço do registrador de escrita
    input [31:0] WD3,  //!Dados a serem escritos no registrador
    output [31:0] RD1, //!Dados lidos do primeiro registrador
    output [31:0] RD2  //!Dados lidos do segundo registrador
);

    reg [31:0] registers [0:31]; //!Banco de registradores de 32 bits

    initial begin
        registers[0] = 32'b0; //!Inicializa o registrador 0 com 0
    end

    // Escrita síncrona
    always @(posedge CLK) begin :ESCRITA
        if (WE3) begin
            if (A3 != 0) begin
                registers[A3] <= WD3; //!Escreve os dados no registrador especificado
            end
        end
    end

    // Leitura combinacional (assíncrona)
    assign RD1 = registers[A1]; //Lê o primeiro registrador
    assign RD2 = registers[A2]; //Lê o segundo registrador
    
endmodule