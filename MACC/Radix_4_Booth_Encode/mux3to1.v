module mux3to1 #(parameter N = 9) (
input  wire [N-1:0] A, B, C,  
input  wire S0, S1,         
output wire [N-1:0] Out         
);

assign Out =    (S1 == 0 && S0 == 0) ? A :
                (S1 == 0 && S0 == 1) ? B :
                (S1 == 1 && S0 == 0) ? C : A;

endmodule
