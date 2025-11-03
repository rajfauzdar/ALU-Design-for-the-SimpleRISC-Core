`timescale 1ns/1ps
module tb_simplerisc;
    reg clk=0, rstn=0;
    simplerisc_top dut(.clk(clk), .rstn(rstn));

    always #5 clk = ~clk;

    integer i;
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_simplerisc);

        rstn=0; repeat(5) @(posedge clk); rstn=1;

        repeat(200) @(posedge clk);

        for (i=0; i<16; i=i+1)
            $display("r%0d = %h", i, dut.U_RF.rf[i]);
        $finish;
    end
endmodule
