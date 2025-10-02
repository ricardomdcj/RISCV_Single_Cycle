module tb_memTopo32LittleEndian;

    parameter DATA_WIDTH = 32;
    parameter ADDRESS_WIDTH = 6;

/*
    SINAIS QUE CHEGAM NO MEMORY STAGE DO PIPELINE
*/
  
  	reg clk;
  	reg [31:0] WriteData_MEM;
    reg MemWrite_MEM;
    
  	reg [31:0] ALUResult_MEM;
  	reg [4:0] Rd_MEM;
    reg ResultSrc_MEM;
    reg RegWrite_ME;
  
  	reg [1:0] size;
  	reg sign_ext;
  
  	wire [31:0] ReadData_MEM;

    memTopo32LittleEndian #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH)
    ) dut (
        .clk(clk),
        .size(size),
      .addr(ALUResult_MEM[5:0]),
        .din(WriteData_MEM),
        .sign_ext(sign_ext),
        .writeEnable(MemWrite_MEM),
        .dout(ReadData_MEM)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
      $dumpfile("dump.vcd"); $dumpvars;
        $display("Iniciando Testbench...");
        size = 0;
        ALUResult_MEM = 32'h0;
        WriteData_MEM = 0;
        sign_ext = 0;
        MemWrite_MEM = 0;

        #20;

        // Teste Word - escrita e leitura
        @(posedge clk);
        size = 2'b10;
      ALUResult_MEM = 32'h0; //Escrevendo no endereço x0000 com addr_offset 00;
        WriteData_MEM = 32'h12345678;
        MemWrite_MEM = 1;
        sign_ext = 0;
        @(posedge clk);
        MemWrite_MEM = 0;
        @(posedge clk);
        $display("Read Word: dout = %h (esperado: 12345678)", ReadData_MEM);
      
      
      // Teste Word - escrita e leitura
        @(posedge clk);
        size = 2'b10;
      ALUResult_MEM = 32'h0; //Escrevendo no endereço x0000 com addr_offset 00;
        WriteData_MEM = 32'h12345678;
        MemWrite_MEM = 1;
        sign_ext = 0;
        @(posedge clk);
        MemWrite_MEM = 0;
        @(posedge clk);
        $display("Read Word: dout = %h (esperado: 12345678)", ReadData_MEM);
      //-----------
      @(posedge clk);
        size = 2'b10;
      ALUResult_MEM = 32'h4; //Escrevendo no endereço x0001 com addr_offset 00;
        WriteData_MEM = 32'h87654321;
        MemWrite_MEM = 1;
        sign_ext = 0;
        @(posedge clk);
        MemWrite_MEM = 0;
        @(posedge clk);
      $display("Read Word: dout = %h (esperado: 87654321)", ReadData_MEM);
      
      // Teste HALF WORD - escrita e leitura
      @(posedge clk);
        size = 2'b01;
      ALUResult_MEM = 32'hC; //Escrevendo no endereço x0011 com addr_offset 00;
        WriteData_MEM = 32'hAABBCCDD;
        MemWrite_MEM = 1;
        sign_ext = 0;
        @(posedge clk);
        MemWrite_MEM = 0;
        @(posedge clk);
      $display("Read Word: dout = %h (esperado: FFFCCDD)", ReadData_MEM);
      
      
      // Teste byte- escrita e leitura
      @(posedge clk);
        size = 2'b00;
      ALUResult_MEM = 32'h21; //Escrevendo no endereço x0100 com addr_offset 01;
        WriteData_MEM = 32'hBB00;
        MemWrite_MEM = 1;
        sign_ext = 0;
        @(posedge clk);
        MemWrite_MEM = 0;
        @(posedge clk);
      $display("Read Word: dout = %h (esperado: FFFFFBB)", ReadData_MEM);


        $display("Testbench finalizado.");
        $finish;
    end

endmodule
