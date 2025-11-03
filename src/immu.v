`timescale 1ns/1ps
`include "decode.vh"

module immu(
    input  wire [17:0] imm18,
    output reg  [31:0] immx
);
    wire [1:0] mod  = imm18[17:16];
    wire [15:0] c16 = imm18[15:0];
    always @(*) begin
        case (mod)
            2'b01: immx = {16'h0000, c16};
            2'b10: immx = {c16, 16'h0000};
            default: immx = {{16{c16[15]}}, c16};
        endcase
    end
endmodule

module branch_target(
    input  wire [26:0] off27,
    input  wire [31:0] pc,
    output wire [31:0] target
);
    wire [28:0] byte_off29 = {off27, 2'b00};
    wire [31:0] sext = {{3{byte_off29[28]}}, byte_off29};
    assign target = pc + sext;
endmodule
