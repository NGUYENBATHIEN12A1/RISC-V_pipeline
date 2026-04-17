module IFID_Reg(
    input clk, rst, 
    input [31:0] IF_PC, IF_Instr,
    output reg [31:0] ID_PC, ID_Instr
);
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            ID_PC    <= 32'b0;
            ID_Instr <= 32'b0;
        end else begin
            ID_PC    <= IF_PC;
            ID_Instr <= IF_Instr;
        end
    end
endmodule