`timescale 1ns/1ps
`include "decode.vh"

module simplerisc_top(
    input  wire clk,
    input  wire rstn,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_wdata
);

    // Program Counter
    reg  [31:0] pc;
    wire [31:0] next_pc;
    wire [31:0] branch_target_addr;

    // Instruction Fetch
    wire [31:0] instr;
    imem U_IMEM (
        .addr(pc[31:2]),
        .instr(instr)
    );

    // Decode
    wire [4:0]  op      = `OP(instr);
    wire        Ibit    = `Ibit(instr);
    wire [3:0]  rd      = `RD(instr);
    wire [3:0]  rs1     = `RS1(instr);
    wire [3:0]  rs2     = `RS2(instr);
    wire [17:0] imm18   = `IMM18(instr);
    wire [26:0] off27   = `BR_OFFSET27(instr);

    // Control Unit
    wire [3:0]  alu_op;
    wire        use_imm;
    wire        mem_read;
    wire        mem_write;
    wire        wb_en;
    wire        wb_from_mem;
    wire        is_branch;
    wire        is_beq;
    wire        is_bgt;
    wire        is_b;
    wire        is_call;
    wire        is_ret;

    control_unit U_CU (
        .op(op),
        .Ibit(Ibit),
        .alu_op(alu_op),
        .use_imm(use_imm),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .wb_en(wb_en),
        .wb_from_mem(wb_from_mem),
        .is_branch(is_branch),
        .is_beq(is_beq),
        .is_bgt(is_bgt),
        .is_b(is_b),
        .is_call(is_call),
        .is_ret(is_ret)
    );

    // Immediate Unit
    wire [31:0] immx;
    immu U_IMMU (
        .imm18(imm18),
        .immx(immx)
    );

    // Register File
    wire [31:0] rdata1, rdata2;
    wire [31:0] wdata;
    regfile U_RF (
        .clk(clk),
        .we(wb_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wdata(wdata),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // ALU
    wire [31:0] alu_b;
    wire [31:0] alu_out;
    wire        alu_zero;
    assign alu_b = use_imm ? immx : rdata2;
    alu U_ALU (
        .a(rdata1),
        .b(alu_b),
        .op(alu_op),
        .y(alu_out),
        .zero(alu_zero)
    );

    // Data Memory
    wire [31:0] dmem_rdata;
    dmem U_DMEM (
        .clk(clk),
        .re(mem_read),
        .we(mem_write),
        .addr(alu_out),
        .wdata(rdata2),
        .rdata(dmem_rdata)
    );

    // Write Back Mux
    assign wdata = wb_from_mem ? dmem_rdata : alu_out;

    // Branch Target Calculation
    branch_target U_BT (
        .off27(off27),
        .pc(pc),
        .target(branch_target_addr)
    );

    // Next PC Logic
    assign next_pc = (is_branch & ((is_beq & alu_zero) | (is_bgt & ~alu_zero) | is_b | is_call)) ? branch_target_addr :
                     (is_ret) ? rdata1 : pc + 4;

    // PC Update
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            pc <= 32'h0;
        end else begin
            pc <= next_pc;
        end
    end
    
    assign debug_pc = pc;
    assign debug_instr = instr;
    assign debug_wdata = wdata;

endmodule