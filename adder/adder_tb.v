module adder_tb();

  reg [31:0] a;
  reg [31:0] b;
  wire [31:0] sum;

  integer error_count;
  integer i;

  // Instancia o módulo adder
  adder dut (
    .a(a),
    .b(b),
    .sum(sum)
  );

  // Task para checar o resultado da soma
  task check;
    begin
      #10; // espera para propagar a soma
      if (sum !== (a + b)) begin
        $display("ERRO! | a=%h, b=%h | soma esperada=%h, soma obtida=%h", a, b, (a + b), sum);
        error_count = error_count + 1;
      end
    end
  endtask

  initial begin
    error_count = 0;

    // Testes básicos
    a = 32'd0; b = 32'd0; check;
    a = 32'hFFFFFFFF; b = 32'd0; check;
    a = 32'd0;        b = 32'hFFFFFFFF; check;

    // Testes de overflow
    a = 32'hFFFFFFFF; b = 32'd1; check;
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; check;

    // Testes de propagação de carry
    a = 32'h00000001; b = 32'hFFFFFFFF; check;
    a = 32'hAAAAAAAA; b = 32'h55555555; check;

    // Testes aleatórios
    for (i = 0; i < 200; i = i + 1) begin
      a = $random;
      b = $random;
      check;
    end

    #20;

    if (error_count == 0) begin
      $display("SUCESSO! Todos os testes passaram.");
    end else begin
      $display("FALHA! Foram encontrados %0d erros.", error_count);
    end

    $finish;
  end

endmodule
