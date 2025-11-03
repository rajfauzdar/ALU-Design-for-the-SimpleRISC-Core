`ifndef SIMPLERISC_DECODE_VH
`define SIMPLERISC_DECODE_VH

`define XLEN      32
`define NREGS     16

`define OP(instr)        instr[31:27]
`define Ibit(instr)      instr[26]
`define RD(instr)        instr[25:22]
`define RS1(instr)       instr[21:18]
`define RS2(instr)       instr[17:14]
`define IMM18(instr)     instr[17:0]
`define BR_OFFSET27(i)   i[26:0]

`define SP  14
`define RA  15

`define OP_ADD  5'b00000
`define OP_SUB  5'b00001
`define OP_MUL  5'b00010
`define OP_DIV  5'b00011
`define OP_MOD  5'b00100
`define OP_CMP  5'b00101
`define OP_AND  5'b00110
`define OP_OR   5'b00111
`define OP_NOT  5'b01000
`define OP_MOV  5'b01001
`define OP_LSL  5'b01010
`define OP_LSR  5'b01011
`define OP_ASR  5'b01100
`define OP_NOP  5'b01101
`define OP_LD   5'b01110
`define OP_ST   5'b01111
`define OP_BEQ  5'b10000
`define OP_BGT  5'b10001
`define OP_B    5'b10010
`define OP_CALL 5'b10011
`define OP_RET  5'b10100

`define ALU_ADD  4'd0
`define ALU_SUB  4'd1
`define ALU_AND  4'd2
`define ALU_OR   4'd3
`define ALU_XOR  4'd4
`define ALU_SLT  4'd5
`define ALU_SLL  4'd6
`define ALU_SRL  4'd7
`define ALU_SRA  4'd8
`define ALU_PASS 4'd9
`define ALU_NOT  4'd10
`define ALU_MUL  4'd11
`define ALU_DIV  4'd12
`define ALU_MOD  4'd13

`endif
