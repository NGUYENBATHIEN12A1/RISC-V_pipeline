module Program_Counter( 
    input clk, rst,
    input [31:0] PC_in,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge rst) begin 
        if (rst) PC_out <= 32'b0;
        else     PC_out <= PC_in;
    end
endmodule

module PCplus4(
    input [31:0] fromPC,
    output [31:0] NextoPC
);
    assign NextoPC = fromPC + 4;
endmodule 