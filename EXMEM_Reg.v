module EXMEM_Reg(
    input clk, rst,
    // Control in
    input EX_RegWrite, EX_MemToReg, EX_Branch, EX_MemRead, EX_MemWrite,
    input EX_Zero,
    // Data in
    input [31:0] EX_BranchTarget, EX_ALUResult, EX_Rd2,
    input [4:0] EX_Rd_addr,
    
    // Control out
    output reg MEM_RegWrite, MEM_MemToReg, MEM_Branch, MEM_MemRead, MEM_MemWrite,
    output reg MEM_Zero,
    // Data out
    output reg [31:0] MEM_BranchTarget, MEM_ALUResult, MEM_WriteData,
    output reg [4:0] MEM_Rd_addr
);
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {MEM_RegWrite, MEM_MemToReg, MEM_Branch, MEM_MemRead, MEM_MemWrite, MEM_Zero} <= 6'b0;
            MEM_BranchTarget <= 32'b0; MEM_ALUResult <= 32'b0; MEM_WriteData <= 32'b0;
            MEM_Rd_addr <= 5'b0;
        end else begin
            MEM_RegWrite <= EX_RegWrite; MEM_MemToReg <= EX_MemToReg; MEM_Branch <= EX_Branch;
            MEM_MemRead <= EX_MemRead; MEM_MemWrite <= EX_MemWrite; MEM_Zero <= EX_Zero;
            MEM_BranchTarget <= EX_BranchTarget; MEM_ALUResult <= EX_ALUResult; MEM_WriteData <= EX_Rd2;
            MEM_Rd_addr <= EX_Rd_addr;
        end
    end
endmodule