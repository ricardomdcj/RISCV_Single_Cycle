module Mux2x1_tb();

    localparam N = 8;

    reg [N-1:0] a;
    reg [N-1:0] b;
    reg sel;
    wire [N-1:0] y;

    Mux2x1 #(.N(N)) dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        a   = 8'hAA;
        b   = 8'h55;
        sel = 1'b0;

        $display("Time | sel |   a    |   b    |   y    ");
        $display("-------------------------------------------"); 
        $monitor("%4t |  %b  | %h | %h | %h", $time, sel, a, b, y);

        #10;
        sel = 1'b1;
        #10;
        a   = 8'hF0;
        b   = 8'h0F;
        #10;
        sel = 1'b0;
        #10;
        $finish;
    end

endmodule