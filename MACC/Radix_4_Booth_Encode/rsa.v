module rsa #( parameter N = 4 ) (
    input  wire [N-1:0] A, B,  // Các toán hạng đầu vào
    input  wire Cin,           // Bit nhớ vào
    output wire [N-1:0] Sum,   // Tổng đầu ra
    output wire Cout           // Bit nhớ ra
);
    wire [N:0] carry;          // Dây để truyền bit nhớ giữa các bộ cộng
    wire [N-1:0] B_xor;        // B XOR với Cin để hỗ trợ phép trừ khi cần

    assign B_xor = B ^ {N{Cin}};  // Nếu Cin = 1, sẽ thực hiện phép trừ A - B
    assign carry[0] = Cin; 
    

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : adder_stage
            full_adder FA (
                .A(A[i]), 
                .B(B_xor[i]), 
                .Cin(carry[i]), 
                .Sum(Sum[i]), 
                .Cout(carry[i+1])
            );
        end
    endgenerate

    assign carry_sign = carry[N];  
    assign Cout = carry_sign ^ Cin;  // Xữ lý bit có dấu khi trừ

endmodule


// Full Adder 1-bit
module full_adder (
    input  wire A, B, Cin,  
    output wire Sum, Cout   
);
    assign Sum  = A ^ B ^ Cin; 
    assign Cout = (A & B) | (A & Cin) | (B & Cin);  
endmodule
