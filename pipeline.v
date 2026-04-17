`timescale 1ns / 1ps

// ==========================================
// Generic 2-to-1 Multiplexer
// ==========================================
module Mux2to1 (
    input [31:0] in0, in1,
    input sel,
    output [31:0] out
);
    assign out = (sel == 1'b0) ? in0 : in1;
endmodule

// ==========================================
// Adder Module
// ==========================================
module Adder(
    input [31:0] in_1, in_2,
    output [31:0] Sum_out
);
    assign Sum_out = in_1 + in_2;
endmodule

// ==========================================
// ALU Control Module
// ==========================================
module ALU_Control(
    input [1:0] ALUOp,
    input fun7,
    input [2:0] fun3,
    output reg [3:0] Control_out
);
    always @(*) begin
        case({ALUOp, fun7, fun3})
            6'b00_0_000: Control_out = 4'b0010; // Load/Store (Add)
            6'b01_0_000: Control_out = 4'b0110; // Beq (Sub)
            6'b10_0_000: Control_out = 4'b0010; // R-type Add
            6'b10_1_000: Control_out = 4'b0110; // R-type Sub
            6'b10_0_111: Control_out = 4'b0000; // R-type And
            6'b10_0_110: Control_out = 4'b0001; // R-type Or
            default:     Control_out = 4'b0000;
        endcase 
    end
endmodule

// ==========================================
// ALU Unit Module
// ==========================================
module ALU_unit (
    input  [31:0] A, B,
    input  [3:0]  Control_in,
    output reg [31:0] ALU_Result,
    output reg zero
);
    always @(*) begin 
        case (Control_in)
            4'b0000: ALU_Result = A & B;      // AND
            4'b0001: ALU_Result = A | B;      // OR
            4'b0010: ALU_Result = A + B;      // ADD
            4'b0110: ALU_Result = A - B;      // SUB
            default: ALU_Result = 32'b0;
        endcase
        zero = (ALU_Result == 32'b0) ? 1'b1 : 1'b0;
    end
endmodule

// ==========================================
// Control Unit Module
// ==========================================
module Control_Unit(
    input [6:0] instruction,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg [1:0] ALUOp
);
    always @(*) begin
        case(instruction)
            7'b0110011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00100010; // R-type
            7'b0000011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b11110000; // Load
            7'b0100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b10001000; // Store
            7'b1100011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00000101; // Branch
            7'b0010011 : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b10100000; // I-type (addi)
            default    : {ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp} = 8'b00000000;
        endcase
    end
endmodule

// ==========================================
// Data Memory Module
// ==========================================
module Data_Memory(
    input clk, reset, MemWrite, MemRead,
    input [31:0] address, Write_data,
    output [31:0] MemData_out
);
    reg [31:0] D_Memory[63:0];
    integer k;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (k = 0; k < 64; k = k + 1) D_Memory[k] <= 32'b0;
        end 
        else if (MemWrite) begin
            D_Memory[address >> 2] <= Write_data;
        end 
    end
    assign MemData_out = (MemRead) ? D_Memory[address >> 2] : 32'b0;
endmodule

// ==========================================
// Immediate Generator Module
// ==========================================
module ImmGen(
    input [6:0] Opcode,
    input [31:0] instruction,
    output reg [31:0] ImmExt
);
    always @(*) begin 
        case (Opcode)
            7'b0000011, 7'b0010011, 7'b1100111: // I-type
                ImmExt = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // S-type 
                ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B-type 
                ImmExt = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            7'b0110111, 7'b0010111: // U-type
                ImmExt = {instruction[31:12], 12'b0};
            7'b1101111: // J-type
                ImmExt = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default: ImmExt = 32'b0;
        endcase
    end
endmodule

// ==========================================
// Instruction Memory Module
// ==========================================
module Instruction_Mem( 
    input [31:0] read_address,
    output [31:0] instruction_out
);
    reg [31:0] Imen [63:0];
    initial begin
        $readmemh("mem.dump", Imen);
    end
    assign instruction_out = Imen[read_address >> 2];
endmodule

// ==========================================
// Program Counter & PCplus4
// ==========================================
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

// ==========================================
// Register File Module 
// ==========================================
module Reg_file(
    input clk, rst, Reg_write,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
);
    reg [31:0] Registers [31:0];
    integer k;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (k = 0; k < 32; k = k + 1) Registers[k] <= 32'b0;
        end 
        else if (Reg_write && rd != 5'b0) begin
            Registers[rd] <= write_data;
        end 
    end
    assign read_data1 = Registers[rs1];
    assign read_data2 = Registers[rs2];
endmodule

// =========================================================================
// PIPELINE REGISTERS
// =========================================================================

// IF/ID Stage
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

// ID/EX Stage
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

// EX/MEM Stage
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

// MEM/WB Stage
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

// ==========================================
// TOP PIPELINE MODULE
// ==========================================
module top(input clk, reset);

    // ------------------------------------
    // STAGE 1: INSTRUCTION FETCH (IF)
    // ------------------------------------
    wire [31:0] IF_PC, IF_PCplus4, IF_Instr, NextPC_Wire;
    wire PCSrc; // Tính toán ở tầng MEM
    wire [31:0] MEM_BranchTarget; // Từ tầng MEM
    
    Mux2to1 PC_Mux (.in0(IF_PCplus4), .in1(MEM_BranchTarget), .sel(PCSrc), .out(NextPC_Wire));
    Program_Counter PC_inst (.clk(clk), .rst(reset), .PC_in(NextPC_Wire), .PC_out(IF_PC));
    PCplus4 PC4_inst (.fromPC(IF_PC), .NextoPC(IF_PCplus4));
    Instruction_Mem IM_inst (.read_address(IF_PC), .instruction_out(IF_Instr));

    // Pipeline Reg: IF/ID
    wire [31:0] ID_PC, ID_Instr;
    IFID_Reg IFID_inst(.clk(clk), .rst(reset), .IF_PC(IF_PC), .IF_Instr(IF_Instr), .ID_PC(ID_PC), .ID_Instr(ID_Instr));

    // ------------------------------------
    // STAGE 2: INSTRUCTION DECODE (ID)
    // ------------------------------------
    wire ID_Branch, ID_MemRead, ID_MemtoReg, ID_MemWrite, ID_ALUSrc, ID_RegWrite;
    wire [1:0] ID_ALUOp;
    wire [31:0] ID_Rd1, ID_Rd2, ID_ImmExt;
    
    // Tín hiệu WriteBack từ tầng WB vòng về
    wire WB_RegWrite;
    wire [4:0] WB_Rd_addr;
    wire [31:0] WB_WriteBackData;
    
    Control_Unit CU_inst (
        .instruction(ID_Instr[6:0]), .Branch(ID_Branch), .MemRead(ID_MemRead),
        .MemtoReg(ID_MemtoReg), .ALUOp(ID_ALUOp), .MemWrite(ID_MemWrite),
        .ALUSrc(ID_ALUSrc), .RegWrite(ID_RegWrite)
    );

    Reg_file RF_inst (
        .clk(clk), .rst(reset), .Reg_write(WB_RegWrite),
        .rs1(ID_Instr[19:15]), .rs2(ID_Instr[24:20]), .rd(WB_Rd_addr),
        .write_data(WB_WriteBackData), .read_data1(ID_Rd1), .read_data2(ID_Rd2)
    );

    ImmGen IG_inst (.Opcode(ID_Instr[6:0]), .instruction(ID_Instr), .ImmExt(ID_ImmExt));

    // Pipeline Reg: ID/EX
    wire EX_RegWrite, EX_MemtoReg, EX_Branch, EX_MemRead, EX_MemWrite, EX_ALUSrc;
    wire [1:0] EX_ALUOp;
    wire [31:0] EX_PC, EX_Rd1, EX_Rd2, EX_ImmExt;
    wire [4:0] EX_Rd_addr;
    wire [3:0] EX_funct;
    
    IDEXE_Reg IDEX_inst(
        .clk(clk), .rst(reset),
        .ID_RegWrite(ID_RegWrite), .ID_MemToReg(ID_MemtoReg), .ID_Branch(ID_Branch), 
        .ID_MemRead(ID_MemRead), .ID_MemWrite(ID_MemWrite), .ID_ALUSrc(ID_ALUSrc), .ID_ALUOp(ID_ALUOp),
        .ID_PC(ID_PC), .ID_Rd1(ID_Rd1), .ID_Rd2(ID_Rd2), .ID_Imm(ID_ImmExt), 
        .ID_Rd_addr(ID_Instr[11:7]), .ID_funct({ID_Instr[30], ID_Instr[14:12]}),
        
        .EX_RegWrite(EX_RegWrite), .EX_MemToReg(EX_MemtoReg), .EX_Branch(EX_Branch), 
        .EX_MemRead(EX_MemRead), .EX_MemWrite(EX_MemWrite), .EX_ALUSrc(EX_ALUSrc), .EX_ALUOp(EX_ALUOp),
        .EX_PC(EX_PC), .EX_Rd1(EX_Rd1), .EX_Rd2(EX_Rd2), .EX_Imm(EX_ImmExt),
        .EX_Rd_addr(EX_Rd_addr), .EX_funct(EX_funct)
    );

    // ------------------------------------
    // STAGE 3: EXECUTE (EX)
    // ------------------------------------
    wire [3:0] EX_ALUControl;
    wire [31:0] EX_ALUB, EX_ALUResult, EX_BranchTarget;
    wire EX_Zero;

    ALU_Control AC_inst (.ALUOp(EX_ALUOp), .fun7(EX_funct[3]), .fun3(EX_funct[2:0]), .Control_out(EX_ALUControl));
    
    Mux2to1 ALU_in_Mux (.in0(EX_Rd2), .in1(EX_ImmExt), .sel(EX_ALUSrc), .out(EX_ALUB));
    ALU_unit ALU_inst (.A(EX_Rd1), .B(EX_ALUB), .Control_in(EX_ALUControl), .ALU_Result(EX_ALUResult), .zero(EX_Zero));
    
    Adder Branch_Adder (.in_1(EX_PC), .in_2(EX_ImmExt), .Sum_out(EX_BranchTarget));

    // Pipeline Reg: EX/MEM
    wire MEM_RegWrite, MEM_MemtoReg, MEM_Branch, MEM_MemRead, MEM_MemWrite, MEM_Zero;
    wire [31:0] MEM_ALUResult, MEM_WriteDataToMem;
    wire [4:0] MEM_Rd_addr;

    EXMEM_Reg EXMEM_inst(
        .clk(clk), .rst(reset),
        .EX_RegWrite(EX_RegWrite), .EX_MemToReg(EX_MemtoReg), .EX_Branch(EX_Branch), 
        .EX_MemRead(EX_MemRead), .EX_MemWrite(EX_MemWrite), .EX_Zero(EX_Zero),
        .EX_BranchTarget(EX_BranchTarget), .EX_ALUResult(EX_ALUResult), .EX_Rd2(EX_Rd2), .EX_Rd_addr(EX_Rd_addr),
        
        .MEM_RegWrite(MEM_RegWrite), .MEM_MemToReg(MEM_MemtoReg), .MEM_Branch(MEM_Branch), 
        .MEM_MemRead(MEM_MemRead), .MEM_MemWrite(MEM_MemWrite), .MEM_Zero(MEM_Zero),
        .MEM_BranchTarget(MEM_BranchTarget), .MEM_ALUResult(MEM_ALUResult), .MEM_WriteData(MEM_WriteDataToMem), 
        .MEM_Rd_addr(MEM_Rd_addr)
    );

    // ------------------------------------
    // STAGE 4: MEMORY (MEM)
    // ------------------------------------
    wire [31:0] MEM_ReadData;
    
    assign PCSrc = MEM_Branch & MEM_Zero; // Quyết định rẽ nhánh dựa theo cờ AND ở tầng MEM
    
    Data_Memory DM_inst (
        .clk(clk), .reset(reset), .MemWrite(MEM_MemWrite), .MemRead(MEM_MemRead),
        .address(MEM_ALUResult), .Write_data(MEM_WriteDataToMem), .MemData_out(MEM_ReadData)
    );

    // Pipeline Reg: MEM/WB
    wire WB_MemtoReg;
    wire [31:0] WB_ReadData, WB_ALUResult;

    MEMWB_Reg MEMWB_inst(
        .clk(clk), .rst(reset),
        .MEM_RegWrite(MEM_RegWrite), .MEM_MemToReg(MEM_MemtoReg),
        .MEM_ReadData(MEM_ReadData), .MEM_ALUResult(MEM_ALUResult), .MEM_Rd_addr(MEM_Rd_addr),
        
        .WB_RegWrite(WB_RegWrite), .WB_MemToReg(WB_MemtoReg),
        .WB_ReadData(WB_ReadData), .WB_ALUResult(WB_ALUResult), .WB_Rd_addr(WB_Rd_addr)
    );

    // ------------------------------------
    // STAGE 5: WRITE BACK (WB)
    // ------------------------------------
    Mux2to1 WB_Mux (.in0(WB_ALUResult), .in1(WB_ReadData), .sel(WB_MemtoReg), .out(WB_WriteBackData));

endmodule

// ==========================================
// Testbench Module 
// ==========================================
module tb_top;
    reg clk, reset;

    top uut (.clk(clk), .reset(reset));

    initial begin 
        clk = 0;
        reset = 1;
        #15 reset = 0;
        
        $monitor("Time=%0t | IF_PC=%h | IF_Inst=%h", $time, uut.IF_PC, uut.IF_Instr);
        
        #500 $finish; // Thiết lập giới hạn chạy mô phỏng
    end

    always #5 clk = ~clk;

    initial begin
        $dumpfile("riscv_sim.vcd");
        $dumpvars(0, tb_top);
    end
endmodule