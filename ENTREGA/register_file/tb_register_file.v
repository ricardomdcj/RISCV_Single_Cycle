module tb_register_file ();

    reg CLK;
    reg WE3;
    reg [4:0] A1, A2, A3;
    reg [31:0] WD3;
    wire [31:0] RD1, RD2;

    integer i;

    // Instancia o módulo register_file
    register_file uut (
        .CLK(CLK),
        .WE3(WE3),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2)
    );

    always #5 CLK = ~CLK; // Gera o clock com período de 10 unidades de tempo

    initial begin
        CLK = 0;
        WE3 = 0;
        A1 = 5'b00000; // Registrador 0
        A2 = 5'b00001; // Registrador 1
        A3 = 5'b00010; // Registrador 2
        WD3 = 32'h12345678; // Dados a serem escritos

        // Teste de escrita no registrador 2
        #10 WE3 = 1; // Habilita escrita
        #20;
        WE3= 0; // Desabilita escrita
        #10;
        A1= 5'b00010; // Lê o registrador 2
        A2= 5'b00000; // Lê o registrador 0

        #10;
        // Verifica os valores lidos
        if (RD1 !== 32'h12345678 || RD2 !== 32'h00000000) begin
            $display("Erro: RD1 = %h, RD2 = %h", RD1, RD2);
        end else begin
            $display("Teste bem-sucedido: RD1 = %h, RD2 = %h", RD1, RD2);
        end

        // Teste escrita no registrador 0
        A3 = 5'b00000; // Registrador 0
        WD3 = 32'h87654321; // Novos dados a serem escritos
        #10 WE3 = 1; // Habilita escrita
        #20;
        WE3 = 0; // Desabilita escrita
        #10;
        A2= 5'b00000; // Lê o registrador 0
        A1= 5'b00001; // Lê o registrador 1

        for (i =1; i < 32; i= i+1) begin
            A3= i;
            WD3 = i; // Escreve o valor do índice no registrador correspondente
            #10 WE3 = 1; // Habilita escrita
            #10;
            WE3 = 0; // Desabilita escrita
            #10;
            A1 = i; // Lê o registrador correspondente
            A2 = i-1; // Lê o registrador anterior
            #10;
            if (RD1 !== i || RD2 !== i-1) begin
                $display("Erro: RD1 = %d, RD2 = %d", RD1, RD2);
            end else begin
                $display("Teste bem-sucedido: RD1 = %d, RD2 = %d", RD1, RD2);
            end
        end

        $finish; // Encerra a simulação

    end

endmodule