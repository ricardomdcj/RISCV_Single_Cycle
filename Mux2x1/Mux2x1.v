module Mux2x1#(parameter N = 8)
(
    input [N-1:0] a,
    input [N-1:0] b,
    input sel,
    output [N-1:0] y

);
    assign y = sel ? b : a;    
endmodule