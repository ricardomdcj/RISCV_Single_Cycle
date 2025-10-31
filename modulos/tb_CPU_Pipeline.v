//`define DEBUG
module tb_CPU_Pipeline;
    
reg clk;
reg rst;

CPU_Pipeline DUT (
    .clk(clk),
    .rst(rst)
);

/* DECLARAÇÃO DOS SINAIS QUE SERÃO MONITORADOS */

// Sinais do pipeline
wire [31:0] Instr; assign Instr = DUT.Instr_IF; //!Instruções fornecidas pelo INSTRUCTION_MEMORY
wire [31:0] PC; assign PC = DUT.PC_IF;          //!Endereço a ser lido pela INSTRUCTRION_MEMORY

// Registradores (mapeados para x5, x6, x7, x28, x29, x30, x31)
wire [31:0] t0; assign t0 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[5];
wire [31:0] t1; assign t1 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[6];
wire [31:0] t2; assign t2 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[7];
wire [31:0] t3; assign t3 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[28];
wire [31:0] t4; assign t4 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[29];
wire [31:0] t5; assign t5 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[30];
wire [31:0] t6; assign t6 = DUT.INSTRUCTION_DECODER.REGISTER_FILE.registers[31];

// Posições da Memória de Dados (store_area, base 0x10 = 16)
// O endereço da mem_inst é addr[5:2].
// Addr 16 (0x10) -> mem_inst addr 4
// Addr 20 (0x14) -> mem_inst addr 5
// Addr 24 (0x18) -> mem_inst addr 6
// Addr 28 (0x1C) -> mem_inst addr 7

// Caminho hierárquico: DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byteX.mem[addr]
wire [7:0] mem16; assign mem16 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[4]; // sb t2, 0(t1)
wire [7:0] mem17; assign mem17 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[4]; // sb t3, 1(t1)
wire [7:0] mem18; assign mem18 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[4]; // sh t4, 2(t1) - byte low
wire [7:0] mem19; assign mem19 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[4]; // sh t4, 2(t1) - byte high
wire [7:0] mem20; assign mem20 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[5]; // sh t5, 4(t1) - byte low
wire [7:0] mem21; assign mem21 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[5]; // sh t5, 4(t1) - byte high
wire [7:0] mem24; assign mem24 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[6]; // sw t6, 8(t1) - byte 0
wire [7:0] mem25; assign mem25 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte1.mem[6]; // sw t6, 8(t1) - byte 1
wire [7:0] mem26; assign mem26 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[6]; // sw t6, 8(t1) - byte 2
wire [7:0] mem27; assign mem27 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[6]; // sw t6, 8(t1) - byte 3
wire [7:0] mem28; assign mem28 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte0.mem[7]; // sb t2, 12(t1)
wire [7:0] mem30; assign mem30 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte2.mem[7]; // sh t3, 14(t1) - byte low
wire [7:0] mem31; assign mem31 = DUT.MEMORY.DATA_MEMORY_ADDRESSABLE.mem_inst.mem_byte3.mem[7]; // sh t3, 14(t1) - byte high
    
/* LOOPS DO TESTBENCH */
initial clk = 0; always #5 clk = ~clk;   //!Ciclo do clock
 
initial begin
    rst = 1; #1 rst = 0;

    // Espera até que o PC chegue ao loop final (instrução j end_loop, PC=0x1040)
    wait (PC == 32'h1040);
    #100; // Espera 10 ciclos extras para garantir que todos os pipelines terminaram

    // --- Bloco de Verificação ---
    $display("-----------------------------------------------");
    $display("--- INICIANDO VERIFICACAO DO TESTBENCH ---");
    $display("--- Teste de Load/Store (programa ativ5) ---");
    $display("-----------------------------------------------");

    // 1. Verificação dos Registradores
    $display("\n[1] Verificando Registradores (Estado Final):");
    if (t0 === 32'h00000000) $display("PASS: t0 (x5) = 0x%h", t0); else $display("FAIL: t0 (x5) = 0x%h (Esperado: 0x00000000)", t0);
    if (t1 === 32'h00000010) $display("PASS: t1 (x6) = 0x%h", t1); else $display("FAIL: t1 (x6) = 0x%h (Esperado: 0x00000010)", t1);
    if (t2 === 32'h0000007F) $display("PASS: t2 (x7) = 0x%h", t2); else $display("FAIL: t2 (x7) = 0x%h (Esperado: 0x0000007F)", t2);
    if (t3 === 32'hFFFFFFFE) $display("PASS: t3 (x28) = 0x%h", t3); else $display("FAIL: t3 (x28) = 0x%h (Esperado: 0xFFFFFFFE)", t3);
    if (t4 === 32'h00005678) $display("PASS: t4 (x29) = 0x%h", t4); else $display("FAIL: t4 (x29) = 0x%h (Esperado: 0x00005678)", t4);
    if (t5 === 32'h00005678) $display("PASS: t5 (x30) = 0x%h", t5); else $display("FAIL: t5 (x30) = 0x%h (Esperado: 0x00005678)", t5);
    if (t6 === 32'h9ABCDEF0) $display("PASS: t6 (x31) = 0x%h", t6); else $display("FAIL: t6 (x31) = 0x%h (Esperado: 0x9ABCDEF0)", t6);

    // 2. Verificação da Memória (store_area @ 0x10)
    $display("\n[2] Verificando Memoria (store_area @ 0x10):");
    if (mem16 === 8'h12) $display("PASS: Mem[16] (sb) = 0x%h", mem16); else $display("FAIL: Mem[16] (sb) = 0x%h (Esperado: 0x12)", mem16);
    if (mem17 === 8'h12) $display("PASS: Mem[17] (sb) = 0x%h", mem17); else $display("FAIL: Mem[17] (sb) = 0x%h (Esperado: 0x12)", mem17);
    if ({mem19, mem18} === 16'h5678) $display("PASS: Mem[19:18] (sh) = 0x%h%h", mem19, mem18); else $display("FAIL: Mem[19:18] (sh) = 0x%h%h (Esperado: 0x5678)", mem19, mem18);
    if ({mem21, mem20} === 16'h5678) $display("PASS: Mem[21:20] (sh) = 0x%h%h", mem21, mem20); else $display("FAIL: Mem[21:20] (sh) = 0x%h%h (Esperado: 0x5678)", mem21, mem20);
    if ({mem27, mem26, mem25, mem24} === 32'h9ABCDEF0) $display("PASS: Mem[27:24] (sw) = 0x%h%h%h%h", mem27, mem26, mem25, mem24); else $display("FAIL: Mem[27:24] (sw) = 0x%h%h%h%h (Esperado: 0x9ABCDEF0)", mem27, mem26, mem25, mem24);
    if (mem28 === 8'h7F) $display("PASS: Mem[28] (sb) = 0x%h", mem28); else $display("FAIL: Mem[28] (sb) = 0x%h (Esperado: 0x7F)", mem28);
    if ({mem31, mem30} === 16'hFFFE) $display("PASS: Mem[31:30] (sh) = 0x%h%h", mem31, mem30); else $display("FAIL: Mem[31:30] (sh) = 0x%h%h (Esperado: 0xFFFE)", mem31, mem30);

    $display("\n--- VERIFICACAO CONCLUIDA ---");
    #100 $stop; // Para a simulação
end

initial begin
    `ifdef DEBUG
        #1000 $stop;    //!Força final da execução do testbench para debbuging
    `endif
end

endmodule
