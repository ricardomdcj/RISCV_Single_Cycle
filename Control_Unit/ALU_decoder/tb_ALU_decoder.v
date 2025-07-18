module tb_ALU_decoder ();

reg [1:0] ALUOp;
reg [2:0] funct3;
reg funct7, op;
wire [2:0] ALUControl;

ALU_decoder DUT (
.ALUOp(ALUOp),
.funct3(funct3),
.funct7(funct7),
.op(op),
.ALUControl(ALUControl)
);

initial begin
    ALUOp = 2'b00;

    #10 ALUOp = 2'b01;
    
    #10 ALUOp = 2'b10;
    funct3 = 3'b000;
    {op,funct7} = 2'b00;
    #10 {op,funct7} = 2'b01;
    #10 {op,funct7} = 2'b10;
    
    #10 {op,funct7} = 2'b11;

    #10 funct3 = 3'b010;
    {op,funct7} = 2'bxx;

    #10 funct3 = 3'b110;

    #10 funct3 = 3'b111;

    #10 $stop;
end
    
endmodule