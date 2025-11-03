`timescale 1ns/1ps
`include "decode.vh"

module control_unit(
    input  wire [4:0]  op,
    input  wire        Ibit,
    output reg  [3:0]  alu_op,
    output reg         use_imm,
    output reg         mem_read,
    output reg         mem_write,
    output reg         wb_en,
    output reg         wb_from_mem,
    output reg         is_branch,
    output reg         is_beq,
    output reg         is_bgt,
    output reg         is_b,
    output reg         is_call,
    output reg         is_ret,
    output reg         is_cmp,
    output reg         is_mov,
    output reg         is_not,
    output reg         is_ld,
    output reg         is_st
);
    always @(*) begin
        alu_op      = `ALU_ADD;
        use_imm     = Ibit;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        wb_en       = 1'b0;
        wb_from_mem = 1'b0;
        is_branch   = 1'b0;
        is_beq=0; is_bgt=0; is_b=0; is_call=0; is_ret=0;
        is_cmp=0; is_mov=0; is_not=0; is_ld=0; is_st=0;

        case (op)
            `OP_ADD: begin alu_op=`ALU_ADD; wb_en=1'b1; end
            `OP_SUB: begin alu_op=`ALU_SUB; wb_en=1'b1; end
            `OP_MUL: begin alu_op=`ALU_MUL; wb_en=1'b1; end
            `OP_DIV: begin alu_op=`ALU_DIV; wb_en=1'b1; end
            `OP_MOD: begin alu_op=`ALU_MOD; wb_en=1'b1; end
            `OP_AND: begin alu_op=`ALU_AND; wb_en=1'b1; end
            `OP_OR : begin alu_op=`ALU_OR ; wb_en=1'b1; end
            `OP_LSL: begin alu_op=`ALU_SLL; wb_en=1'b1; end
            `OP_LSR: begin alu_op=`ALU_SRL; wb_en=1'b1; end
            `OP_ASR: begin alu_op=`ALU_SRA; wb_en=1'b1; end

            `OP_NOT: begin alu_op=`ALU_NOT; is_not=1'b1; wb_en=1'b1; end
            `OP_MOV: begin alu_op=`ALU_PASS; is_mov=1'b1; wb_en=1'b1; end

            `OP_CMP: begin is_cmp=1'b1; wb_en=1'b0; end

            `OP_LD : begin is_ld=1'b1; alu_op=`ALU_ADD; mem_read=1'b1; wb_en=1'b1; wb_from_mem=1'b1; end
            `OP_ST : begin is_st=1'b1; alu_op=`ALU_ADD; mem_write=1'b1; wb_en=1'b0; end

            `OP_BEQ: begin is_branch=1'b1; is_beq=1'b1; end
            `OP_BGT: begin is_branch=1'b1; is_bgt=1'b1; end
            `OP_B  : begin is_branch=1'b1; is_b=1'b1;  end
            `OP_CALL:begin is_branch=1'b1; is_call=1'b1; end
            `OP_RET: begin is_branch=1'b1; is_ret=1'b1; end

            `OP_NOP: begin end
            default: begin end
        endcase
    end
endmodule
