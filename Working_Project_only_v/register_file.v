module register_file (
    input clk,         //!Sinal de clock
    input rst,         //!Sinal de reset
    input WE3,         //!Write enable input
    input [4:0] A1,    //!Endereço do primeiro registrador de leitura
    input [4:0] A2,    //!Endereço do segundo registrador de leitura,
    input [4:0] A3,    //!Endereço do registrador de escrita
    input [31:0] WD3,  //!Dados a serem escritos no registrador
    output [31:0] RD1, //!Dados lidos do primeiro registrador
    output [31:0] RD2  //!Dados lidos do segundo registrador
);

    integer i;    

    reg [31:0] registers [0:31]; //!Banco de registradores de 32 bits

    // Escrita síncrona
    always @(posedge clk, posedge rst) begin :ESCRITA
        if (rst) begin
            for (i = 0; i < 32; i = i +1 ) begin: RESET
                registers[i] = 32'b0;
            end
            registers[5] = 32'd6;
            registers[9] = 32'h2004;
        end else if (WE3 & (A3 != 5'd0)) begin
            registers[A3] <= WD3; //!Escreve os dados no registrador especificado
        end
    end

    // Leitura combinacional (assíncrona)
    assign RD1 = (A1 == 5'd0) ? 32'd0 : registers[A1]; //Lê o primeiro registrador
    assign RD2 = (A2 == 5'd0) ? 32'd0 : registers[A2]; //Lê o segundo registrador
    
endmodule