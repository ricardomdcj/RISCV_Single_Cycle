// RETIRADO DA TABELA 7.2 NA PÁGINA 408 DA BIBLIOGRAFIA

module Main_decoder (
    input [6:0] Op,
    output reg Branch,
    output reg ResultSrc,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [1:0] ImmSrc,
    output reg RegWrite,
    output reg [1:0] ALUOp
);

// Instruções possíveis
localparam lw =     7'b0000011,
           sw =     7'b0100011,
           R_type = 7'b0110011,
           beq =    7'b1100011;

always @(*) begin
    Branch = 1'b0;
    ResultSrc = 1'b0;
    MemWrite = 1'b0;
    ALUSrc = 1'b0;
    ImmSrc = 2'b00;
    RegWrite = 1'b0;
    ALUOp = 2'b00;
    case (Op)
        lw: begin
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ResultSrc = 1'b1;
        end
        sw: begin
            ImmSrc = 2'b01;
            ALUSrc = 1'b1;
            MemWrite = 1'b1;
        end
        R_type: begin
            RegWrite = 1'b1;
            ALUOp = 2'b10;
        end
        beq: begin
            ImmSrc = 2'b10;
            Branch = 1'b1;
            ALUOp = 2'b01;
        end
    endcase
end

endmodule