module part_1(input a,b,cin, output diff,borrow);
assign diff=a^b^cin;
assign borrow=~a & (b^cin) | b & cin;
endmodule