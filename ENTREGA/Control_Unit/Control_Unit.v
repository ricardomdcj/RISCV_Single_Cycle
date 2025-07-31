module Control_Unit (
    input [6:0] Op,
    input [2:0] funct3,
    input funct7,
    input Zero,
    output PCSrc,
    output ResultSrc,
    output MemWrite,
    output ALUSrc,
    output [1:0] ImmSrc,
    output RegWrite,
    output [2:0] ALUControl
);

wire [1:0] ALUOp;
wire Branch;

assign PCSrc = Zero & Branch;

Main_decoder MainDecoder (
.Op(Op),
.Branch(Branch),
.ResultSrc(ResultSrc),
.MemWrite(MemWrite),
.ALUSrc(ALUSrc),
.ImmSrc(ImmSrc),
.RegWrite(RegWrite),
.ALUOp(ALUOp)
);

ALU_decoder ALUDecoder (
.ALUOp(ALUOp),
.funct3(funct3),
.funct7(funct7),
.op(Op[5]),
.ALUControl(ALUControl)
);
    
endmodule