`timescale 1ns/1ps
`include "decode.vh"

module imem(
    input  wire [31:2] addr,
    output wire [31:0] instr
);
    reg [31:0] rom [0:1023];
    initial begin
        $readmemh("D:\\iitd sem1\\coa iitd\\assignment_2\\output.hex", rom);
    end
    assign instr = rom[addr[11:2]];
endmodule

module dmem(
    input  wire        clk,
    input  wire        re,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);
    reg [31:0] ram [0:1023];
    wire [9:0] idx = addr[11:2];
    always @(posedge clk) begin
        if (we) ram[idx] <= wdata;
        if (re) rdata    <= ram[idx];
    end
endmodule
