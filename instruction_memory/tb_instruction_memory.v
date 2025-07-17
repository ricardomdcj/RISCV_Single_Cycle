module tb_instruction_memory;
    reg [31:0] A;
    wire [31:0] RD; 

    // Instancia o módulo instruction_memory
    instruction_memory uut (
        .A(A),
        .RD(RD)
    );

    initial begin
        $monitor("Time: %0t | Address: %h | Data Read: %h", $time, A, RD);
    end

    initial begin
        // Teste de leitura
        A = 32'h00000000; // Endereço inicial
        #20;
        A = 32'h00000004; 
        #20;
        A = 32'h00000008; 
        #20;
        A = 32'h0000000C; 
        #20;
        $finish;
    end

endmodule
