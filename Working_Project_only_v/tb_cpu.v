//`define DEBUG
module tb_cpu;
    
    reg clk;
	 reg rst;

    cpu DUT (
        .clk(clk),
		  .rst(rst)
    );

    /* DECLARAÇÃO DOS SINAIS QUE SERÃO MONITORADOS PARA COMPROVAR O FUNCIONAMENTO DO CIRCUITO */
    
	 wire [31:0] Instr; assign Instr = DUT.DATAPATH.Instr;                                                  //!Instruções fornecidas pelo INSTRUCTION_MEMORY
    wire [31:0] PC; assign PC = DUT.DATAPATH.PC;                                                            //!Endereço a ser lido pela INSTRUCTRION_MEMORY
    wire [31:0] PCNext; assign PCNext = DUT.DATAPATH.PCNext;                                                //!Próximo endereço a ser lido pela INSTRUCTION_MEMORY
    wire [31:0] Result; assign Result = DUT.DATAPATH.Result;                                                //!Dados a serem escritos no REGISTER_FILE
    wire [31:0] Register_x4; assign Register_x4 = DUT.DATAPATH.REGISTER_FILE.registers[4];                    //!Registrador 4 do REGISTER_FILE
    wire [31:0] Register_x5; assign Register_x5 = DUT.DATAPATH.REGISTER_FILE.registers[5];                    //!Registrador 5 do REGISTER_FILE
    wire [31:0] Register_x6; assign Register_x6 = DUT.DATAPATH.REGISTER_FILE.registers[6];                    //!Registrador 6 do REGISTER_FILE
    wire [31:0] Register_x9; assign Register_x9 = DUT.DATAPATH.REGISTER_FILE.registers[9];                    //!Registrador 9 do REGISTER_FILE
    wire [31:0] DataMemory_x2000; assign DataMemory_x2000 = DUT.DATAPATH.DATA_MEMORY.memory[14'h800];   //!Posição de memória x2000 do DATA_MEMORY (Lẽ-se em x800 por causa do word allign) 
    wire [31:0] DataMemory_x200C; assign DataMemory_x200C = DUT.DATAPATH.DATA_MEMORY.memory[14'h803];   //!Posição de memória x200C do DATA_MEMORY (Lẽ-se em x803 por causa do word allign)
	
	 
    /* DECLARAÇÃO DE SINAIS AUXILIARES PARA CONTROLE DE TESTBENCH */
    reg [7:0] loopCounter; initial loopCounter = 0; //!Contador de loops do programa via PC e PCNext
        
    /* LOOPS DO TESTBENCH */
    initial clk = 0; always #5 clk = ~clk;   //!Ciclo do clock
	 
	 initial begin rst = 1; #1 rst = 0; end

    always @(negedge clk) begin
        if (PC == 32'h100C & PCNext == 32'h1000) loopCounter = loopCounter + 1;   //!Se o programa realizar o loop, adiciona 1 no contador
        if (loopCounter > 10) $stop;   //!Depois de 10 ciclos de loop, para o testbench
    end

    initial begin
        `ifdef DEBUG
            #1000 $stop;    //!Força final da execução do testbench para debbuging
        `endif
    end

    initial begin
        $monitor("PC: %h (PCNext: %h) | Instr: %h | Result: %h | x4: %h | x5: %h | x6: %h | x9: %h",
         PC, PCNext, Instr, Result, Register_x4, Register_x5, Register_x6, Register_x9);

    end

endmodule

/*    
    PROGRAMA QUE DEVERÁ SER UTILIZADO PARA COMPROVAR O FUNCIONAMENTO (em hexadecimal):
    0x1000: FF_C4_A3_03
    0x1004: 00_64_A4_23
    0x1008: 00_62_E2_33
    0x100C: FE_42_0A_E3

    PROGRAMA QUE DEVERÁ SER UTILIZADO PARA COMPROVAR O FUNCIONAMENTO (em binário):
    0x1000: 11111111_11000100_10100011_00000011
    0x1004: 00000000_01100100_10100100_00100011
    0x1008: 00000000_01100010_11100010_00110011
    0x100C: 11111110_01000010_00001010_11100011

    DESCRIÇÃO DO PROGRAMA:
    0x1000: L7: lw x6, -4(x9)       -> lê o valor armazenado no endereço de memória (x9 - 4) e armazena no registrador x6 
    0x1004:     sw x6, 8(x9)        -> lê o valor armazenado no registrador x6 e escreve no endereço de memória x9 + 8
    0x1008:     or x4, x5, x6       -> realiza um OR bit a bit entre os registradores x5 e x6, e armazena o resultado no registrador x4
    0x100C:     beq x4, x4, L7      -> compara os registradores x4 e x4 e, desvia a execução do programa para L7 (0x1000)

   VALORES INCIAIS DE INSTRUCTION_MEMORY:
   memory[0] = 32'hFFC4A303
   memory[4] = 32'h0064A423
   memory[8] = 32'h0062E233
   memory[12] = 32'hFE420AE3

    VALORES INICIAIS DE DATA_MEMORY:
    0x2000 = 10

    VALORES INICIAIS DO REGISTER_FILE:
    registers[5] = 32'h0006
    registers[9] = 32'h2004

    É NECESSÁRIO ADICIONAR ESSAS INSTRUÇÕES NO CÓDIGO DO DATA_MEMORY, REGISTER_FILE E INSTRUCTION_MEMORY.
*/