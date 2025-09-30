//`define DEBUG
module tb_CPU_Pipeline;
    
reg clk;
 reg rst;

CPU_Pipeline DUT (
    .clk(clk),
    .rst(rst)
);

/* DECLARAÇÃO DOS SINAIS QUE SERÃO MONITORADOS PARA COMPROVAR O FUNCIONAMENTO DO CIRCUITO */

wire [31:0] Instr; assign Instr = DUT.Instr_IF;                                                  //!Instruções fornecidas pelo INSTRUCTION_MEMORY
wire [31:0] PC; assign PC = DUT.PC_IF;                                                            //!Endereço a ser lido pela INSTRUCTRION_MEMORY
 
/* DECLARAÇÃO DE SINAIS AUXILIARES PARA CONTROLE DE TESTBENCH */
reg [7:0] loopCounter; initial loopCounter = 0; //!Contador de loops do programa via PC e PCNext
    
/* LOOPS DO TESTBENCH */
initial clk = 0; always #5 clk = ~clk;   //!Ciclo do clock
 
 initial begin rst = 1; #1 rst = 0;
    #500 $stop;
end

initial begin
    `ifdef DEBUG
        #1000 $stop;    //!Força final da execução do testbench para debbuging
    `endif
end

endmodule