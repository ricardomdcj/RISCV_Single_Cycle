module ALU_tb();

    reg  [31:0] a, b;
    reg  [2:0]  alu_op;
    wire [31:0] result;
    wire        zero;

    integer error_count;
    integer i;

    localparam MAX_POS = 32'h7FFFFFFF; 
    localparam MIN_NEG = 32'h80000000; 
    localparam ALL_ONES = 32'hFFFFFFFF;

    ALU dut (
        .SrcA(a),
        .SrcB(b),
        .ALUControl(alu_op),
        .ALUResult(result),
        .Zero(zero)
    );

    task check;
        input [31:0] expected_result;
        input [2:0]  op_code;
        input string op_name;

        alu_op = op_code;
        #10; 
        
        if (result !== expected_result || zero !== (expected_result == 0)) begin
            $display("   ERRO! Op: %s (%b)", op_name, op_code);
            $display("   Entradas: a=%h, b=%h", a, b);
            $display("   Esperado: res=%h, zero=%b", expected_result, (expected_result==0));
            $display("   Obtido:   res=%h, zero=%b", result, zero);
            error_count = error_count + 1;
        end
    endtask

    initial begin
        error_count = 0;

        // --- Testes com zero ---
        a=0;         b=MAX_POS;    check(a + b, 3'b000, "ADD");
        a=MIN_NEG;   b=0;          check(a - b, 3'b001, "SUB");
        a=ALL_ONES;  b=1;          check(a + b, 3'b000, "ADD"); 
        a=0;         b=1;          check(a - b, 3'b001, "SUB"); 

        // --- Testes de Overflow/Underflow  ---
        a=MAX_POS;   b=1;          check(a + b, 3'b000, "ADD"); // Overflow: Maior positivo + 1 = Menor negativo
        a=MIN_NEG;   b=ALL_ONES;   check(a - b, 3'b001, "SUB"); // Underflow: Menor negativo - (-1) = Maior positivo
        
        // --- Testes Lógicos  ---
        a=32'hAAAAAAAA; b=32'h55555555; check(a & b, 3'b010, "AND");
        a=32'hAAAAAAAA; b=32'h55555555; check(a | b, 3'b011, "OR" );
        
        // --- Testes de SLT com extremos ---
        a=MIN_NEG;   b=MAX_POS;    check(($signed(a) < $signed(b)), 3'b101, "SLT");
        a=MAX_POS;   b=MIN_NEG;    check(($signed(a) < $signed(b)), 3'b101, "SLT");
        a=0;         b=ALL_ONES;   check(($signed(a) < $signed(b)), 3'b101, "SLT"); 
        a=ALL_ONES;  b=0;          check(($signed(a) < $signed(b)), 3'b101, "SLT"); 
        a=0;         b=0;          check(($signed(a) < $signed(b)), 3'b101, "SLT");
         
        // --- TESTES ALEATÓRIOS
        for (i = 0; i < 200; i = i + 1) begin
            a = $random;
            b = $random;
            check(a + b,                         3'b000, "ADD_RANDOM");
            check(a - b,                         3'b001, "SUB_RANDOM");
            check(a & b,                         3'b010, "AND_RANDOM");
            check(a | b,                         3'b011, "OR_RANDOM" );
            check(($signed(a) < $signed(b)),     3'b101, "SLT_RANDOM");
        end

        #20;
        if (error_count == 0)
            $display("\n SUCESSO! Todos os testes passaram.");
        else
            $display("\n FALHA! A ALU teve %0d erro(s).", error_count);
        
        $finish;
    end

endmodule