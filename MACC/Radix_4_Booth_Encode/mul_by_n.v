// arithmetic_left_shift 
module multiplier_by_n #(parameter N = 8, parameter S = 1) (
    input  wire [N-1:0] A,
    output wire [N:0] Y
);
    assign Y = {A[N-1], A} << S;  // Dịch trái S bit
endmodule