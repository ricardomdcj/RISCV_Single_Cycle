module program_counter (
    input wire clk,
    input wire [31:0] PCNext,
    output reg [31:0] PC
);

    initial begin
        PC <= 32'h1000;
    end
    
    always @(posedge clk) begin
        PC <= PCNext;
    end

endmodule