module MEMWB_Reg(
    input clk, rst,
    // Control in
    input MEM_RegWrite, MEM_MemToReg,
    // Data in
    input [31:0] MEM_ReadData, MEM_ALUResult,
    input [4:0] MEM_Rd_addr,
    
    // Control out
    output reg WB_RegWrite, WB_MemToReg,
    // Data out
    output reg [31:0] WB_ReadData, WB_ALUResult,
    output reg [4:0] WB_Rd_addr
);
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            {WB_RegWrite, WB_MemToReg} <= 2'b0;
            WB_ReadData <= 32'b0; WB_ALUResult <= 32'b0;
            WB_Rd_addr <= 5'b0;
        end else begin
            WB_RegWrite <= MEM_RegWrite; WB_MemToReg <= MEM_MemToReg;
            WB_ReadData <= MEM_ReadData; WB_ALUResult <= MEM_ALUResult;
            WB_Rd_addr <= MEM_Rd_addr;
        end
    end
endmodule
