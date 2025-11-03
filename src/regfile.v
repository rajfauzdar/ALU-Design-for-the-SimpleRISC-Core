`timescale 1ns/1ps
`include "decode.vh"

module regfile(
    input  wire         clk,
    input  wire         we,
    input  wire [3:0]   rs1,
    input  wire [3:0]   rs2,
    input  wire [3:0]   rd,
    input  wire [31:0]  wdata,
    output wire [31:0]  rdata1,
    output wire [31:0]  rdata2
);
    reg [31:0] rf[0:`NREGS-1];

    assign rdata1 = rf[rs1];
    assign rdata2 = rf[rs2];

    always @(posedge clk) begin
        if (we) rf[rd] <= wdata;
    end
endmodule
