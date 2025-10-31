module instruction_memory #(
	parameter ADDR_WIDTH = 10,  // 1024 palavras
    parameter DATA_WIDTH = 32
)(
    input [31:0] A,      //!Endereço de leitura
    output reg [31:0] RD //!Dados lidos da memória de instruções
);
    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1]; //!Memória de instruções de 32 bits e 1024 palavras

    initial begin
		$readmemh("/atividades/ativ5_instr.txt", memory);
    end
	
	wire [ADDR_WIDTH-1:0] word_addr;
    assign word_addr = (A - 32'h1000) >> 2;

    always @(*) begin
        RD = memory[word_addr];
	end

endmodule