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