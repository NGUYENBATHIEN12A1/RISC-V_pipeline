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
