module program_counter (
    input wire CLK,
    input wire [31:0] PCNext,
    output reg [31:0] PC
);

    always @(posedge CLK) begin
        PC <= PCNext;
    end

endmodule