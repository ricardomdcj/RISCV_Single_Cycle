//`define DEBUG
module tb_CPU_Pipeline;
    
reg clk;
reg rst;

CPU_Pipeline_Completa DUT (
    .clk(clk),
    .rst(rst)
);

/* DECLARAÇÃO DOS SINAIS QUE SERÃO MONITORADOS */

// Sinais do pipeline
wire [31:0] Instr; assign Instr = DUT.Instr_IF; //!Instruções fornecidas pelo INSTRUCTION_MEMORY
wire [31:0] PC; assign PC = DUT.PC_IF;          //!Endereço a ser lido pela INSTRUCTRION_MEMORY

// Sinais internos (atalhos para registradores e memória)
wire [31:0] t0; assign t0 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[5];
wire [31:0] t1; assign t1 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[6];
wire [31:0] t2; assign t2 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[7];
wire [31:0] t3; assign t3 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[28];
wire [31:0] t4; assign t4 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[29];
wire [31:0] t5; assign t5 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[30];
wire [31:0] t6; assign t6 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[31];

// Atalhos para a memória de dados (lendo palavras de 32 bits)
// O módulo de memória interna é `mem_inst` dentro de `DATA_MEMORY_ADDRESSABLE`
// O seu `ADDRESS_WIDTH` é 4, então o `DEPTH` é 16 (0 a 15)
wire [31:0] mem_word0; assign mem_word0 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[0], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[0], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[0], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[0]};
wire [31:0] mem_word1; assign mem_word1 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[1], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[1], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[1], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[1]};
wire [31:0] mem_word2; assign mem_word2 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[2], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[2], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[2], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[2]};
wire [31:0] mem_word3; assign mem_word3 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[3], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[3], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[3], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[3]};
wire [31:0] mem_word4; assign mem_word4 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[4], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[4], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[4], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[4]};
wire [31:0] mem_word5; assign mem_word5 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[5], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[5], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[5], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[5]};
wire [31:0] mem_word6; assign mem_word6 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[6], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[6], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[6], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[6]};
wire [31:0] mem_word7; assign mem_word7 = {DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[7], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[7], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[7], DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[7]};

/* LOOPS DO TESTBENCH */
initial clk = 0; always #5 clk = ~clk;   //!Ciclo do clock
 
initial begin rst = 1; #1 rst = 0;
#1400 $stop;
end

// ***** BLOCO ATUALIZADO PARA GERAR O ARQUIVO .VCD *****
initial begin
    $dumpfile("waveform.vcd"); // Define o nome do arquivo de saída
    
    // <<< CORREÇÃO: Dumpar a partir do módulo do testbench (tb_CPU_Pipeline)
    // Isso incluirá o DUT e também os wires locais (t0, mem_word4, etc.)
    //$dumpvars(0, tb_CPU_Pipeline);         
end
// ************************************************

initial begin
    `ifdef DEBUG
        #1000 $stop;    //!Força final da execução do testbench para debbuging
    `endif
end

// Bloco de verificação (baseado no programa assembly ativ5)
initial begin
    // Espera o programa chegar no loop infinito (instrução 'j' no endereço 0x1040)
    wait (DUT.PC_IF == 32'h1040);
    
    // Espera mais alguns ciclos para garantir que o pipeline esvazie e
    // as operações de MEM e WB das últimas instruções sejam concluídas.
    #50; 
    
    $display("-----------------------------------------------");
    $display("--- INICIANDO VERIFICACAO DO TESTBENCH ---");
    $display("--- Teste de Load/Store (programa ativ5) ---");
    $display("-----------------------------------------------");
    $display("");
    
    // [1] VERIFICAR REGISTRADORES
    $display("[1] Verificando Registradores (Estado Final):");
    
    // t0 (x5) = 0
    if (t0 === 32'h00000000) $display("PASS: t0 (x5) = 0x%h", t0);
    else $display("FAIL: t0 (x5) = 0x%h (Esperado: 0x00000000)", t0);
    
    // t1 (x6) = 16
    if (t1 === 32'h00000010) $display("PASS: t1 (x6) = 0x%h", t1);
    else $display("FAIL: t1 (x6) = 0x%h (Esperado: 0x00000010)", t1);
    
    // t2 (x7) = 127
    if (t2 === 32'h0000007f) $display("PASS: t2 (x7) = 0x%h", t2);
    else $display("FAIL: t2 (x7) = 0x%h (Esperado: 0x0000007F)", t2);
    
    // t3 (x28) = -2
    if (t3 === 32'hFFFFFFFE) $display("PASS: t3 (x28) = 0x%h", t3);
    else $display("FAIL: t3 (x28) = 0x%h (Esperado: 0xFFFFFFFE)", t3);

    // t4 (x29) = 0x5678 (sign-extended)
    if (t4 === 32'h00005678) $display("PASS: t4 (x29) = 0x%h", t4);
    else $display("FAIL: t4 (x29) = 0x%h (Esperado: 0x00005678)", t4);
    
    // t5 (x30) = 0x5678 (zero-extended)
    if (t5 === 32'h00005678) $display("PASS: t5 (x30) = 0x%h", t5);
    else $display("FAIL: t5 (x30) = 0x%h (Esperado: 0x00005678)", t5);
    
    // t6 (x31) = 0x9ABCDEF0
    if (t6 === 32'h9ABCDEF0) $display("PASS: t6 (x31) = 0x%h", t6);
    else $display("FAIL: t6 (x31) = 0x%h (Esperado: 0x9ABCDEF0)", t6);
    
    $display("");
    
    // [2] VERIFICAR MEMÓRIA (store_area @ 0x10 = 16)
    // Endereços de memória são (t1 + offset)
    // mem_word4 = end 16 (0x10)
    // mem_word5 = end 20 (0x14)
    // mem_word6 = end 24 (0x18)
    // mem_word7 = end 28 (0x1C)
    
    $display("[2] Verificando Memoria (store_area @ 0x10):");
    
    // sb t2, 0(t1) @ end 16 (mem_word4[7:0])
    // sb t3, 1(t1) @ end 17 (mem_word4[15:8])
    // sh t4, 2(t1) @ end 18 (mem_word4[31:16])
    // Valor esperado para mem_word4 (Little-Endian): 0x5678_1212
    if (mem_word4 === 32'h56781212) $display("PASS: Mem[19:16] = 0x%h", mem_word4);
    else $display("FAIL: Mem[19:16] = 0x%h (Esperado: 0x56781212)", mem_word4);

    // sh t5, 4(t1) @ end 20 (mem_word5[15:0])
    // Valor esperado para mem_word5 (Little-Endian): 0x0000_5678
    if (mem_word5 === 32'h00005678) $display("PASS: Mem[23:20] = 0x%h", mem_word5);
    else $display("FAIL: Mem[23:20] = 0x%h (Esperado: 0x00005678)", mem_word5);
    
    // sw t6, 8(t1) @ end 24 (mem_word6)
    // Valor esperado para mem_word6: 0x9ABCDEF0
    if (mem_word6 === 32'h9ABCDEF0) $display("PASS: Mem[27:24] = 0x%h", mem_word6);
    else $display("FAIL: Mem[27:24] = 0x%h (Esperado: 0x9ABCDEF0)", mem_word6);

    // sb t2, 12(t1) @ end 28 (mem_word7[7:0])
    // sh t3, 14(t1) @ end 30 (mem_word7[31:16])
    // ** NOTA: Hazards de dados são esperados aqui! **
    // O teste abaixo verifica o valor *correto* (sem hazard),
    // portanto, é esperado que ele FALHE.
    
    // Valor esperado para mem_word7 (Little-Endian): 0xFFFE_007F
    if (mem_word7 === 32'hFFFE007F) $display("PASS: Mem[31:28] = 0x%h", mem_word7);
    else $display("FAIL: Mem[31:28] = 0x%h (Esperado: 0xFFFE007F) <-- Data Hazard esperado", mem_word7);


    $display("");
    $display("--- VERIFICACAO CONCLUIDA ---");
    
    #10 $stop; // Para a simulação após a verificação
end

endmodule
