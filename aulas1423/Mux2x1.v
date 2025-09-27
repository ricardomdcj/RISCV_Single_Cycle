module Mux2x1 #(parameter N = 8)
(
    input [N-1:0] a,
    input [N-1:0] b,
    input sel,
    output reg [N-1:0] y

);
    //assign y = sel ? b : a;   
    always @(*) begin
        case (sel)
            1'b0: y = a;
            1'b1: y = b;
            default: y = a;
        endcase
    end
 
endmodule