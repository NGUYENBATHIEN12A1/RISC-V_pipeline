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