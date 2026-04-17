module IDEXE_Reg(
    input clk, rst,
    // Control in
    input ID_RegWrite, ID_MemToReg, ID_Branch, ID_MemRead, ID_MemWrite, ID_ALUSrc,
    input [1:0] ID_ALUOp,
    // Data in
    input [31:0] ID_PC, ID_Rd1, ID_Rd2, ID_Imm,
    input [4:0] ID_Rd_addr, input [3:0] ID_funct, // funct = {instr[30], instr[14:12]}
    
    // Control out
    output reg EX_RegWrite, EX_MemToReg, EX_Branch, EX_MemRead, EX_MemWrite, EX_ALUSrc,
    output reg [1:0] EX_ALUOp,
    // Data out
    output reg [31:0] EX_PC, EX_Rd1, EX_Rd2, EX_Imm,
    output reg [4:0] EX_Rd_addr, output reg [3:0] EX_funct
);
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {EX_RegWrite, EX_MemToReg, EX_Branch, EX_MemRead, EX_MemWrite, EX_ALUSrc} <= 6'b0;
            EX_ALUOp <= 2'b0;
            EX_PC <= 32'b0; EX_Rd1 <= 32'b0; EX_Rd2 <= 32'b0; EX_Imm <= 32'b0;
            EX_Rd_addr <= 5'b0; EX_funct <= 4'b0;
        end else begin
            EX_RegWrite <= ID_RegWrite; EX_MemToReg <= ID_MemToReg; EX_Branch <= ID_Branch;
            EX_MemRead <= ID_MemRead; EX_MemWrite <= ID_MemWrite; EX_ALUSrc <= ID_ALUSrc;
            EX_ALUOp <= ID_ALUOp;
            EX_PC <= ID_PC; EX_Rd1 <= ID_Rd1; EX_Rd2 <= ID_Rd2; EX_Imm <= ID_Imm;
            EX_Rd_addr <= ID_Rd_addr; EX_funct <= ID_funct;
        end
    end
endmodule