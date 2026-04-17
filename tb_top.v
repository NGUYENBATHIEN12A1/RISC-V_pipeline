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