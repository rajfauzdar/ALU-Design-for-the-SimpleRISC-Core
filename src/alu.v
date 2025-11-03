`timescale 1ns/1ps
`include "decode.vh"

module Xor(
 input wire [31:0] a,
 input wire [31:0] b,
 output wire [31:0] z
);

assign z=a^b;
endmodule

module And(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

assign z=a&b;
endmodule

module Or(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

assign z=a|b;
endmodule

module Not(
input wire [31:0] a,
output wire [31:0] z
);

assign z=~a;
endmodule

module Arith_Shift_Right
(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

wire [31:0] s0,s1,s2,s3;

assign s0=b[0]? { a[31], a[31:1] } : a;
assign s1=b[1]? { {2{s0[31]}}, s0[31:2] } : s0;
assign s2=b[2]? { {4{s1[31]}}, s1[31:4] } : s1;
assign s3=b[3]? { {8{s2[31]}}, s2[31:8] } : s2;

assign z=b[4]? { {16{s3[31]}}, s3[31:16] } : s3;

endmodule

module Logic_Shift_Right
(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

wire [31:0] s0,s1,s2,s3;
assign s0 = b[0] ? { 1'b0, a[31:1] } : a;
assign s1 = b[1] ? { 2'b00, s0[31:2] } : s0;
assign s2 = b[2] ? { 4'b0000, s1[31:4] } : s1;
assign s3 = b[3] ? { 8'b00000000, s2[31:8] } : s2;
assign z  = b[4] ? { 16'b0000000000000000, s3[31:16] } : s3;

endmodule

module Logic_Shift_Left
(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

wire [31:0] s0,s1,s2,s3;
assign s0 = b[0] ? { a[30:0], 1'b0 } : a;
assign s1 = b[1] ? { s0[29:0] , 2'b00 } : s0;
assign s2 = b[2] ? { s1[27:0] , 4'b0000 } : s1;
assign s3 = b[3] ? { s2[23:0] , 8'b00000000 } : s2;
assign z  = b[4] ? { s3[15:0] , 16'b0000000000000000 } : s3;

endmodule


module adder #( 
    parameter N = 32
)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire cin,
    output wire [N-1:0] sum
);

wire [N-1:0] g;
wire [N-1:0] p;

genvar i;
generate
    for (i = 0 ;i < N ; i=i+1 ) begin 
        assign g[i] = a[i] & b[i];
        assign p[i] = a[i] ^ b[i];
    end
endgenerate

localparam Stages = 5 ;

wire [N-1:0] G [0:Stages];
wire [N-1:0] P [0:Stages];

generate
    for (i = 0 ; i < N ; i=i+1 ) begin
        assign G[0][i] = g[i];
        assign P[0][i] = p[i];
    end
endgenerate

genvar stage;
generate
    for (stage = 1;stage <= Stages ; stage = stage +1 ) begin
        localparam integer dist = 1 << (stage-1);

        for (i = 0 ;i<N ;i=i+1 ) begin
            if(i >= dist) begin
              assign G[stage][i] = G[stage-1][i] | (P[stage-1][i] & G[stage-1][i-dist]);
              assign P[stage][i] = P[stage-1][i] & P[stage-1][i-dist];
            end
            else begin
              assign G[stage][i] = G[stage-1][i];
              assign P[stage][i] = P[stage-1][i];
            end
        end
    end
endgenerate

wire[N:0] carry;
assign carry[0] = cin;

generate
    for (i = 0 ; i<N ;i=i+1 ) begin
        assign carry[i+1] = G[Stages][i] | (P[Stages][i] & carry[0]);
    end
endgenerate

generate
    for (i = 0 ;i<N ;i=i+1 ) begin
        assign sum[i] = p[i] ^ carry[i];
        
    end

endgenerate

endmodule

module subtraction(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

wire [31:0] temp0;

Not onecomp(
.a(b),
.z(temp0)
);

//Adder twocomp(
//.a(temp0),
//.b(32'b00000000000000000000000000000001),
//.z(temp1)
//);

adder sub(
.a(a),
.b(temp0),
.cin(1'b1),
.sum(z)
);


endmodule



module setlessthan(
input wire [31:0] a,
input wire [31:0] b,
output wire [31:0] z
);

  wire [31:0] diff;
  
  subtraction sub(
  .a(a),
  .b(b),
  .z(diff)
  );
  
  wire diffsign;
  assign diffsign=(a[31]^b[31]);
  
  assign z[0] = (diffsign)? a[31] : diff[31];

endmodule

module Not_64(
input wire [63:0] a,
output wire [63:0] z
);

assign z=~a;
endmodule

module Logic_Shift_Left_64
(
input wire [63:0] a,
input wire [63:0] b,
output wire [63:0] z
);

wire [63:0] s0,s1,s2,s3,s4;
assign s0 = b[0] ? { a[62:0], 1'b0 } : a;
assign s1 = b[1] ? { s0[61:0] , 2'b00 } : s0;
assign s2 = b[2] ? { s1[59:0] , 4'b0000 } : s1;
assign s3 = b[3] ? { s2[55:0] , 8'b00000000 } : s2;
assign s4  = b[4] ? { s3[47:0] , 16'b0000000000000000 } : s3;
assign z  = b[5] ? { s4[31:0] , 32'b00000000000000000000000000000000 } : s4;

endmodule


module adder_64 #( 
    parameter N = 64
)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire cin,
    output wire [N-1:0] sum
);

wire [N-1:0] g;
wire [N-1:0] p;

genvar i;
generate
    for (i = 0 ;i < N ; i=i+1 ) begin 
        assign g[i] = a[i] & b[i];
        assign p[i] = a[i] ^ b[i];
    end
endgenerate

localparam Stages = 6 ;

wire [N-1:0] G [0:Stages];
wire [N-1:0] P [0:Stages];

generate
    for (i = 0 ; i < N ; i=i+1 ) begin
        assign G[0][i] = g[i];
        assign P[0][i] = p[i];
    end
endgenerate

genvar stage;
generate
    for (stage = 1;stage <= Stages ; stage = stage +1 ) begin
        localparam integer dist = 1 << (stage-1);

        for (i = 0 ;i<N ;i=i+1 ) begin
            if(i >= dist) begin
              assign G[stage][i] = G[stage-1][i] | (P[stage-1][i] & G[stage-1][i-dist]);
              assign P[stage][i] = P[stage-1][i] & P[stage-1][i-dist];
            end
            else begin
              assign G[stage][i] = G[stage-1][i];
              assign P[stage][i] = P[stage-1][i];
            end
        end
    end
endgenerate

wire[N:0] carry;
assign carry[0] = cin;

generate
    for (i = 0 ; i<N ;i=i+1 ) begin
        assign carry[i+1] = G[Stages][i] | (P[Stages][i] & carry[0]);
    end
endgenerate

generate
    for (i = 0 ;i<N ;i=i+1 ) begin
        assign sum[i] = p[i] ^ carry[i];
        
    end
endgenerate

endmodule

module csa_3to2(
input wire[63:0] a,
input wire [63:0] b,
input wire [63:0] c,
output wire [63:0] sum,
output wire [63:0] carry
);

    assign sum = a ^ b ^ c;
    assign carry = ((a & b) | (b & c) | (a & c)) << 1;
endmodule

module multiplication(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] z
);
    wire signed [63:0] partial_prod [0:15];
    wire [32:0] b_ext;
    wire signed [63:0] A_ext;
    wire signed [63:0] m0, m1, m2, mneg1, mneg2;
    
    integer i;
    reg [2:0] trip;
    reg signed [63:0] sel[0:15];
    
    assign b_ext  = {1'b0, b};
    assign A_ext  = {{32{a[31]}}, a};
    wire [63:0] neg_a,twocomp_a;
    Not_64 neg(
    .a(A_ext),
    .z(neg_a)
    );
    
    adder_64 #(.N(64)) add_unit 
    (.a(neg_a),
     .b(64'd1),
     .cin(1'b0),
     .sum(twocomp_a)
     );
     
    wire signed [63:0] A_ext2;
    assign A_ext2 = A_ext<<1;
    wire [63:0] neg_a2,twocomp_a2;
    wire c_out_tmp2;
    Not_64 neg2(
    .a(A_ext2),
    .z(neg_a2)
    );
    
    adder_64 #(.N(64)) add_unit2 
    (.a(neg_a2),
     .b(64'd1),
     .cin(1'b0),
     .sum(twocomp_a2)
     );
     
   
    assign m0     = 64'sd0;
    assign m1     = A_ext;
    assign m2     = A_ext2;
    assign mneg1  = twocomp_a;
    assign mneg2  = twocomp_a2;

    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            if (2*i-1 >= 0)
                trip = {b_ext[2*i+1], b_ext[2*i], b_ext[2*i-1]};
            else
                trip = {b_ext[2*i+1], b_ext[2*i], 1'b0};
            case (trip)
                3'b000, 3'b111: sel[i] = m0;
                3'b001, 3'b010: sel[i] = m1;
                3'b011:         sel[i] = m2;
                3'b100:         sel[i] = mneg2;
                3'b101, 3'b110: sel[i] = mneg1;
                default:        sel[i] = m0;
            endcase
            
                
    
            
        end
    end
    
    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1)
         begin
        
            Logic_Shift_Left_64 shift_inst(
                .a(sel[j]),
                .b(64'd2*j),
                .z(partial_prod[j])
            );
        end
    endgenerate
    
    
    
    
    wire [63:0] sum1 [4:0];
    wire [63:0] carry1 [4:0];
    wire [63:0] rem1 = partial_prod[15];


    generate
        for (j = 0; j < 5; j = j + 1) begin : stage1
            csa_3to2 csa_inst(
                .a(partial_prod[3*j]),
                .b(partial_prod[3*j+1]),
                .c(partial_prod[3*j+2]),
                .sum(sum1[j]),
                .carry(carry1[j])
            );
        end
    endgenerate

    wire [63:0] stage2_in [10:0];
    assign stage2_in[0]  = sum1[0];
    assign stage2_in[1]  = carry1[0];
    assign stage2_in[2]  = sum1[1];
    assign stage2_in[3]  = carry1[1];
    assign stage2_in[4]  = sum1[2];
    assign stage2_in[5]  = carry1[2];
    assign stage2_in[6]  = sum1[3];
    assign stage2_in[7]  = carry1[3];
    assign stage2_in[8]  = sum1[4];
    assign stage2_in[9]  = carry1[4];
    assign stage2_in[10] = rem1;

    wire [63:0] sum2 [2:0];
    wire [63:0] carry2 [2:0];
    wire [63:0] rem2a = stage2_in[9];
    wire [63:0] rem2b = stage2_in[10];

    generate
        for (j = 0; j < 3; j = j + 1) begin : stage2
            csa_3to2 csa_inst2(
                .a(stage2_in[3*j]),
                .b(stage2_in[3*j+1]),
                .c(stage2_in[3*j+2]),
                .sum(sum2[j]),
                .carry(carry2[j])
            );
        end
    endgenerate

    wire [63:0] stage3_in [7:0];
    assign stage3_in[0] = sum2[0];
    assign stage3_in[1] = carry2[0];
    assign stage3_in[2] = sum2[1];
    assign stage3_in[3] = carry2[1];
    assign stage3_in[4] = sum2[2];
    assign stage3_in[5] = carry2[2];
    assign stage3_in[6] = rem2a;
    assign stage3_in[7] = rem2b;

    wire [63:0] sum3 [1:0];
    wire [63:0] carry3 [1:0];
    wire [63:0] rem3a = stage3_in[6];
    wire [63:0] rem3b = stage3_in[7];

    generate
        for (j = 0; j < 2; j = j + 1) begin : stage3
            csa_3to2 csa_inst3(
                .a(stage3_in[3*j]),
                .b(stage3_in[3*j+1]),
                .c(stage3_in[3*j+2]),
                .sum(sum3[j]),
                .carry(carry3[j])
            );
        end
    endgenerate
    
    wire [63:0] stage4_in [5:0];
    assign stage4_in[0] = sum3[0];
    assign stage4_in[1] = carry3[0];
    assign stage4_in[2] = sum3[1];
    assign stage4_in[3] = carry3[1];
    assign stage4_in[4] = rem3a;
    assign stage4_in[5] = rem3b;
    
    wire [63:0] sum4 [1:0];
    wire [63:0] carry4 [1:0];
    
    generate
        for (j = 0; j < 2; j = j + 1) begin : stage4
            csa_3to2 csa_inst4(
                .a(stage4_in[3*j]),
                .b(stage4_in[3*j+1]),
                .c(stage4_in[3*j+2]),
                .sum(sum4[j]),
                .carry(carry4[j])
            );
        end
     endgenerate
     
     wire [63:0] stage5_in [3:0];
     assign stage5_in[0] = sum4[0];
     assign stage5_in[1] = carry4[0];
     assign stage5_in[2] = sum4[1];
     assign stage5_in[3] = carry4[1];   
        
        
     wire [63:0] sum5,carry5;
     
     csa_3to2 csa_stage5(
        .a(stage5_in[0]),
        .b(stage5_in[1]),
        .c(stage5_in[2]),
        .sum(sum5),
        .carry(carry5)
    );   
    
    wire [63:0] finalsum,finalcarry;
    csa_3to2 csa_stage6(
        .a(sum5),
        .b(carry5),
        .c(stage5_in[3]),
        .sum(finalsum),
        .carry(finalcarry)
    );
    
    wire [31:0] useless_msb;

    adder_64 #(.N(64)) final_add_unit 
    (.a(finalsum),
     .b(finalcarry),
     .cin(1'b0),
     .sum({useless_msb,z})
     );
    
endmodule

module division (
    input  wire [31:0] a,       // Dividend
    input  wire [31:0] b,       // Divisor
    output reg  [31:0] quotient,
    output reg  [31:0] remainder
);

    // Internal signals
    reg [31:0] abs_a, abs_b;
    reg [31:0] q_tmp, r_tmp;
    reg sign_q, sign_r;

    integer i;

    always @(*) begin
        // Default values
        quotient  = 32'b0;
        remainder = 32'b0;

        // Division-by-zero check
        if (b == 0) begin
            quotient  = 32'h7FFFFFFF; // saturation
            remainder = a;
        end
        else begin
            // Determine result signs
            sign_q = a[31] ^ b[31];
            sign_r = a[31];

            // Convert to absolute values
            abs_a = a[31] ? (~a + 1'b1) : a;
            abs_b = b[31] ? (~b + 1'b1) : b;

            // Perform unsigned division
            q_tmp = 0;
            r_tmp = 0;

            for (i = 31; i >= 0; i = i - 1) begin
                r_tmp = (r_tmp << 1) | (abs_a[i]);
                if (r_tmp >= abs_b) begin
                    r_tmp = r_tmp - abs_b;
                    q_tmp[i] = 1'b1;
                end
            end

            // Apply signs
            quotient  = sign_q ? (~q_tmp + 1'b1) : q_tmp;
            remainder = sign_r ? (~r_tmp + 1'b1) : r_tmp;
        end
    end

endmodule

module Pass (
input wire [31:0]b,
output wire[31:0] z
);

assign z=b;
endmodule

module Division(
input wire [31:0]a,
input wire [31:0]b,
output wire[31:0] z
);

wire [31:0] useless_rem;
division div(
.a(a),
.b(b),
.quotient(z),
.remainder(useless_rem)
);

endmodule


module Mod(
input wire [31:0]a,
input wire [31:0]b,
output wire[31:0] z
);

wire [31:0] useless_quot;
division div(
.a(a),
.b(b),
.quotient(useless_quot),
.remainder(z)
);

endmodule

module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  op,
    output reg  [31:0] y,
    output wire        zero
);

wire [31:0] add_res,sub_res,and_res,or_res,xor_res,slt_res,sll_res,srl_res,sra_res,pass_res,not_res,mul_res,div_res,mod_res;

           adder #(.N(32)) add_inst (
                .a(a),
                .b(b),
                .cin(1'b0),
                .sum(add_res)
            );

            subtraction sub_inst (
                .a(a),
                .b(b),
                .z(sub_res)
            );
            
            And and_inst(
               .a(a),
               .b(b),
               .z(and_res)            
            );
            
            Or or_inst(
               .a(a),
               .b(b),
               .z(or_res)            
            );
            
            Xor xor_inst(
               .a(a),
               .b(b),
               .z(xor_res)            
            );
            
            
            
            
            setlessthan slt_inst (
                .a(a),
                .b(b),
                .z(slt_res)
            );
            Logic_Shift_Left sll_inst (
                .a(a),
                .b(b),
                .z(sll_res)
            );  

            Logic_Shift_Right srl_inst (
                .a(a),
                .b(b),
                .z(srl_res)
            );
            Arith_Shift_Right sra_inst (
                .a(a),
                .b(b),
                .z(sra_res)
            );
           
            Pass pass_inst (
                .b(b),
                .z(pass_res)
            );
             
             Not not_inst(
               .a(b),
               .z(not_res)            
            );
            
            multiplication mul_inst (
                .a(a),
                .b(b),
                .z(mul_res)
            );
            division div_inst (
                .a(a),
                .b(b),
                .quotient(div_res)
            );
            Mod mod_inst (
                .a(a),
                .b(b),
                .z(mod_res)
            );        
             


    always @(*) begin
        case (op)
            
            `ALU_ADD: y = add_res;
            `ALU_SUB: y = sub_res;
            `ALU_AND: y = and_res;
            `ALU_OR : y = or_res;
            `ALU_XOR: y = xor_res;
            `ALU_SLT: y = slt_res;
            `ALU_SLL: y = sll_res;
            `ALU_SRL: y = srl_res;
            `ALU_SRA: y = sra_res;
            `ALU_NOT: y = not_res;
            `ALU_PASS:y = pass_res;
            `ALU_MUL: y = mul_res;
            `ALU_DIV: y = div_res;
            `ALU_MOD: y = mod_res;
            default:   y = 32'd0;
        endcase
    end
    assign zero = (y == 32'd0);
endmodule