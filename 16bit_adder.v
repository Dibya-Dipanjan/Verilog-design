module ripple_16(a,b,cin,sum,cout);
input [15:0]a,b;
input cin;
output [15:0] sum;
output cout;
wire c1,c2,c3;

ripple_4 rp1(.a(a[3:0]),.b(b[3:0]),.cin(cin),.sum(sum[3:0]),.cout(c1));
ripple_4 rp2(.a(a[7:4]),.b(b[7:4]),.cin(c1),.sum(sum[7:4]),.cout(c2));
ripple_4 rp3(.a(a[11:8]),.b(b[11:8]),.cin(c2),.sum(sum[11:8]),.cout(c3));
ripple_4 rp4(.a(a[15:12]),.b(b[15:12]),.cin(c3),.sum(sum[15:12]),.cout(cout));

endmodule

module ripple_4(a,b,cin,sum,cout);
input [3:0]a,b;
input cin;
output [3:0] sum;
output cout;
wire c1,c2,c3;

full_addr ad1(.a(a[0]),.b(b[0]),.cin(cin),.sum(sum[0]),.cout(c1));
full_addr ad2(.a(a[1]),.b(b[1]),.cin(c1),.sum(sum[1]),.cout(c2));
full_addr ad3(.a(a[2]),.b(b[2]),.cin(c2),.sum(sum[2]),.cout(c3));
full_addr ad4(.a(a[3]),.b(b[3]),.cin(c3),.sum(sum[3]),.cout(cout));

endmodule

module full_addr(a,b,cin,sum,cout);
input a,b,cin;
output sum,cout;
assign sum = a^b^cin;
assign cout = (a&b) + (b&cin) + (a&cin);
endmodule

