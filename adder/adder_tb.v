module adder_tb();

    reg [31:0] a;
    reg [31:0] b;
    wire [31:0] sum;
    integer error_count;
    integer i;

    adder dut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    task check;
        #10;
        if (sum !== (a + b)) begin
            $display("ERRO! | a=%h, b=%h | soma esperada=%h, soma obtida=%h", a, b, (a+b), sum);
            error_count = error_count + 1;
        end
    endtask

    initial begin
        error_count = 0;

        // Teste com zero
        a = 32'd0; b = 32'd0; check;
        a = 32'hFFFFFFFF; b = 32'd0; check;
        a = 32'd0; b = 32'hFFFFFFFF; check;

        // Teste de overflow (estouro)
        a = 32'hFFFFFFFF; b = 32'd1; check; 
        a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; check;

        // Teste de propagação de carry
        a = 32'h00000001; b = 32'hFFFFFFFF; check;
        a = 32'hAAAAAAAA; b = 32'h55555555; check;

        // --- 2. Testes Aleatórios ---
        for (i = 0; i < 200; i = i + 1) begin
            a = $random;
            b = $random;
            check;
        end

        #20;
        if (error_count == 0) begin
            $display("SUCESSO! Todos os testes passaram.");
        end else begin
            $display("\nFALHA! Foram encontrados %0d erros.", error_count);
        end
        $finish;
    end

endmodule