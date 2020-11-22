module decoder1 ( output [3:0] Y, input EN, input [1:0] A);9
assign Y[0]=~A[1]&~A[0]& EN;
assign Y[1]=~A[1]& A[0]& EN;
assign Y[2]= A[1]&~A[0]& EN;
assign Y[3]= A[1]& A[0]& EN;
endmodule