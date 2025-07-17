module tb_data_memory;

    reg CLK;
    reg WE;
    reg [31:0] A; // Endereço de leitura/escrita
    reg [31:0] WD; // Dados a serem escritos
    wire [31:0] RD; // Dados lidos da memória de dados

    // Instancia o módulo data_memory
    data_memory uut (
        .A(A),
        .WD(WD),
        .WE(WE),
        .RD(RD)
    );

    initial begin
        $monitor("Time: %0t | Address: %h | Data Written: %h | Data Read: %h", $time, A, WD, RD);
    end

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // Gera o clock com período de 10 unidades de tempo
    end

    initial begin
        CLK = 0;
        WE = 0;
        A = 32'h00000000; // Endereço inicial
        WD = 32'h12345678; // Dados a serem escritos

        // Teste de escrita na memória
        #10 WE = 1; // Habilita escrita
        #20;
        WE = 0; // Desabilita escrita
        #10;

        // Teste de leitura da memória
        A = 32'h00000000; // Lê do endereço inicial
        #10;

        if (RD !== 32'h12345678) begin
            $display("Erro: RD = %h", RD);
        end else begin
            $display("Teste bem-sucedido: RD = %h", RD);
        end

        // Teste de escrita em outro endereço
        A = 32'h00000001; // Novo endereço
        WD = 32'h87654321; // Novos dados a serem escritos
        #10 WE = 1; // Habilita escrita
        #20;
        WE = 0; // Desabilita escrita
        #10;

        // Verifica a leitura do novo endereço
        A = 32'h00000001; // Lê do novo endereço
        #10;

        if (RD !== 32'h87654321) begin
            $display("Erro: RD = %h", RD);
        end else begin
            $display("Teste bem-sucedido: RD = %h", RD);
        end

        $finish;
    end
endmodule