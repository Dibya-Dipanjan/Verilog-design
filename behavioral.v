module part_3(input a,b,cin, output diff,borrow);
reg diff,borrow;
always @(a,b,cin)
begin
diff=a^b^cin;
 borrow=~a & (b^cin) | b & cin;
end
endmodule