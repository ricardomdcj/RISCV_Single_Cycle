module tb_Main_decoder ();

reg [6:0] Op;
wire Branch;
wire ResultSrc;
wire MemWrite;
wire ALUSrc;
wire [1:0] ImmSrc;
wire RegWrite;
wire [1:0] ALUOp;

Main_decoder DUT (
.Op(Op),
.Branch(Branch),
.ResultSrc(ResultSrc),
.MemWrite(MemWrite),
.ALUSrc(ALUSrc),
.ImmSrc(ImmSrc),
.RegWrite(RegWrite),
.ALUOp(ALUOp)
);

initial begin
    Op = 7'b0;

    #20 Op = 7'b0000011;

    #20 Op = 7'b0100011;

    #20 Op = 7'b0110011;

    #20 Op = 7'b1100011;
    
    #20 $stop;
end
    
endmodule