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