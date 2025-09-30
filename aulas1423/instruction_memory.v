module instruction_memory (
    input [31:0] A,      //!Endereço de leitura
    output [31:0] RD //!Dados lidos da memória de instruções
);
    reg [31:0] instructionMemoryRegisters [0:1023];

   initial begin
      // CÓDIGOS DA ATIVIDADE 2 (SEM BUBBLES)
      // start:
      instructionMemoryRegisters[0] <= 32'b000000001010_00000_000_00101_0010011; // addi t0, x0, 10 # t0 = contador = 10
      instructionMemoryRegisters[1] <= 32'b000000000000_00000_000_00110_0010011; // addi t1, x0, 0 # t1 = acumulador = 0
      instructionMemoryRegisters[2] <= 32'b000000000000_00000_000_00111_0010011; // addi t2, x0, 0x0000 # t2 <- data initial address

      // loop:
      instructionMemoryRegisters[3] <= 32'b000000000000_00111_010_11100_0000011; // lw t3, 0(t2) # carrega data[i] em t3
      instructionMemoryRegisters[4] <= 32'b0000000_11100_00110_000_00110_0110011; // add t1, t1, t3 # acumula soma
      instructionMemoryRegisters[5] <= 32'b000000000100_00111_000_00111_0010011; // addi t2, t2, 4 # avança ponteiro na memoria
      instructionMemoryRegisters[6] <= 32'b111111111111_00101_000_00101_0010011; // addt t0, t0, -1 # decrementa contador
      instructionMemoryRegisters[7] <= 32'b1111111_00101_00000_000_11100_1100011; // beq x0, t0, loop # t0 = 0, volta para loop

      // end:
      instructionMemoryRegisters[8] <= 32'b000000000000_00000_000_00000_0010011; // addi x0, x0, 0 # NOP
      instructionMemoryRegisters[9] <= 32'hFC000ee3; // beq x0, x0, start # volta pro inicio
   end

   assign RD = instructionMemoryRegisters[A];


endmodule