module decode2x4(output [3:0]Y, input EN, input[1:0]A);
and (Y[0],~A[1],~A[0],EN);
and (Y[1],~A[1], A[0],EN);
and (Y[2], A[1],~A[0],EN);
and (Y[3], A[1], A[0],EN);
endmodule