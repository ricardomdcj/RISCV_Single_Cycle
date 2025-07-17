module tb_extend;

    reg [31:7] instr;
    reg [1:0] immsrc;
    wire [31:0] immext;

    // Instancia o módulo extend
    extend uut (
        .instr(instr),
        .immsrc(immsrc),
        .immext(immext)
    );

    initial begin
        $monitor("Time: %0t | Instruction: %h | Immediate Extended: %h", $time, instr, immext);
    end

    initial begin
        // Teste I-type
        instr = 25'h7FA_123; // instrução com imediato negativo
        immsrc = 2'b00; // I-type
        #10;
        $display("I-type: %h (esperado: 3FD)", immext);

        // Teste S-type
        instr = 25'h5AB_456; // instrução com valor positivo
        immsrc = 2'b01; // S-type
        #10;
        $display("S-type: %h (esperado: 2D6)", immext);

        // Teste B-type
        instr = 25'h7DE_789; // instrução com salto negativo
        immsrc = 2'b10; // B-type
        #10;
        $display("B-type: %h (esperado: BE8)", immext);

        // Teste J-type
        instr = 25'h4BC_DEF; // instrução com salto positivo
        immsrc = 2'b11; // J-type
        #10;
        $display("J-type: %h (esperado: 6F25E)", immext);

        $finish;
    end
endmodule