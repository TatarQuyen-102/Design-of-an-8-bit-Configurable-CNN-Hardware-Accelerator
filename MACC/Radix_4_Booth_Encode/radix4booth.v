`include "booth_encoder.v"
`include "mul_by_n.v"
`include "mux2to1.v"
`include "mux3to1.v"
`include "sqrt_csa_rca.v"
`include "mod_bec.v"


module Mul (
    input [7:0] x,
    input [7:0] y,
    output [14:0] o_mul
);

// output - multiply by 2
wire [8:0] m_2x;

// output - wire booth encoder
wire [2:0] o_s1_be;
wire [2:0] o_s2_be;
wire [2:0] o_s3_be;
wire [2:0] o_s4_be;

// output - wire mod bec
wire [8:0] o_s1_bec;

// output - wire mux3to1
wire [8:0] o_s1_mux3to1;
wire [8:0] o_s2_mux3to1;
wire [8:0] o_s3_mux3to1;
wire [8:0] o_s4_mux3to1;

// output - wire of each stage of multiplier
wire [8:0] o_s1;
wire [9:0] o_s2;
wire [9:0] o_s3;
wire [9:0] o_s4;

// multiply 2
multiplier_by_n #( .N(8), .S(1)) mul_2x(
    .A(x),
    .Y(m_2x));

// mux3to1
mux3to1 #(.N(9)) mux_s1(.A(1'b0) , .B(m_2x), .C({x[7],x}),
                        .S0(o_s1_be[0])  , .S1(o_s1_be[1]),
                        .Out(o_s1_mux3to1));

mux3to1 #(.N(9)) mux_s2(.A(1'b0) , .B(m_2x), .C({x[7],x}),
                        .S0(o_s2_be[0])  , .S1(o_s2_be[1]),
                        .Out(o_s2_mux3to1));

mux3to1 #(.N(9)) mux_s3(.A(1'b0) , .B(m_2x), .C({x[7],x}),
                        .S0(o_s3_be[0])  , .S1(o_s3_be[1]),
                        .Out(o_s3_mux3to1));

mux3to1 #(.N(9)) mux_s4(.A(1'b0) , .B(m_2x), .C({x[7],x}),
                        .S0(o_s4_be[0])  , .S1(o_s4_be[1]),
                        .Out(o_s4_mux3to1));

// booth encoder
booth_encoder be_s1( .B0(1'b0), .B1(y[0]), .B2(y[1]), 
                     .P0(o_s1_be[0]), .P1(o_s1_be[1]), .P2(o_s1_be[2]));

booth_encoder be_s2( .B0(y[1]), .B1(y[2]), .B2(y[3]), 
                     .P0(o_s2_be[0]), .P1(o_s2_be[1]), .P2(o_s2_be[2]));

booth_encoder be_s3( .B0(y[3]), .B1(y[4]), .B2(y[5]), 
                     .P0(o_s3_be[0]), .P1(o_s3_be[1]), .P2(o_s3_be[2]));

booth_encoder be_s4( .B0(y[5]), .B1(y[6]), .B2(y[7]), 
                     .P0(o_s4_be[0]), .P1(o_s4_be[1]), .P2(o_s4_be[2]));

// modified BEC of stage 1
mod_bec mod_bec_s1(.B(o_s1_mux3to1),   // Đầu vào 9-bit
                   .X(o_s1_bec));

// Mux2to1 of stage 1
mux2to1 #(.N(9)) mux2to1_s1(.In0(o_s1_mux3to1), 
                            .In1(o_s1_bec), 
                            .Sel(o_s1_be[2]), 
                            .Out(o_s1));

// sqrt carry save adder using RSA
sqrt_csa_rsa sqrt_csa_rsa_s2(.A({o_s1[8], o_s1[8], o_s1[8:2]}),
                             .B(o_s2_mux3to1), 
                             .Cin(o_s2_be[2]), 
                             .Out(o_s2));

sqrt_csa_rsa sqrt_csa_rsa_s3(.A({o_s2[8],o_s2[9:2]}), 
                             .B(o_s3_mux3to1), 
                             .Cin(o_s3_be[2]), 
                             .Out(o_s3));

sqrt_csa_rsa sqrt_csa_rsa_s4(.A({o_s3[8],o_s3[9:2]}), 
                             .B(o_s4_mux3to1), 
                             .Cin(o_s4_be[2]), 
                             .Out(o_s4));

assign o_mul = {o_s4, o_s3[1:0], o_s2[1:0], o_s1[1:0]};

endmodule
