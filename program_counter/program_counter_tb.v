module program_counter_tb;

  reg CLK;
  reg [31:0] PCNext;
  wire [31:0] PC;

  // Instanciando o DUT (Device Under Test)
  program_counter dut (
    .CLK(CLK),
    .PCNext(PCNext),
    .PC(PC)
  );

  // Geração do clock
  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK; // Clock de período 10ns
  end

  // Rotina de teste
  initial begin
    // Inicialização
    PCNext = 32'd0;
    #12;  // Espera alguns ciclos de clock

    // Teste 1: Escrevendo valores simples
    PCNext = 32'd100;
    #10;
    if (PC !== 32'd100)
      $display("Falha: PC esperado=100, PC=%d", PC);

    // Teste 2: Mudando PCNext
    PCNext = 32'd123456;
    #10;
    if (PC !== 32'd123456)
      $display("Falha: PC esperado=123456, PC=%d", PC);

    // Teste 3: Sequência de valores
    PCNext = 32'hFFFFFFFF; #10;
    if (PC !== 32'hFFFFFFFF)
      $display("Falha: PC esperado=FFFFFFFF, PC=%h", PC);

    PCNext = 32'd12; #10;
    if (PC !== 32'd12)
      $display("Falha: PC esperado=12, PC=%d", PC);

    // Teste de estabilidade (PCNext fixo)
    PCNext = PC; #10;
    if (PC !== 32'd12)
      $display("Falha: PC deveria permanecer em 12, PC=%d", PC);

    $display("Testbench finalizado!");
    $finish;
  end

  // Opção: monitoramento dos sinais
  initial begin
    $monitor("Tempo=%0t | CLK=%b | PCNext=%h | PC=%h", $time, CLK, PCNext, PC);
  end

endmodule
