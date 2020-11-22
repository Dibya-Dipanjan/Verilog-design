module full_subtractor_2(input a, input b, input cin, output diff, output borrow);
	wire t1,t2,t3;
	xor(t1,a,b);
	xor(diff,t1,cin);
	and(t2,~t1,cin);
	and(t3,~a,b);
	or(borrow,t2,t3);
endmodule