`timescale 1ns/1ns
module alu_tb; //testbench initialization
//inputs
reg [3:0] A;
reg [3:0] B;
reg [3:0] Cin;
reg [3:0] F;
//output
wire [3:0] D;
ALU uut(.D(D),.A(A),.B(B),.Cin(Cin),.F(F)); //Instantiate the Unit Under Test
initial begin
//Initialize inputs
$dumpfile("alu.vcd");
$dumpvars(0,alu_tb);
 A=0; B=0; Cin=0; F=0;
#10 B=1;  F=1;
#10 A=1; B=0;  F=2;
#10 B=1;  F=3;
#10 A=0; B=0;  F=4;
#10 Cin=1; F=5;
#10 B=1; Cin=0; F=6;
#10 A=1; B=0; Cin=1; F=7;
#10 A=0; B=1;  F=8;
#10 B=0; Cin=0; F=9;
#10 B=1;  F=10;
#10 A=1;  F=11;
#10 A=0;  Cin=1; F=12;
#20 $finish;
end
initial begin
$monitor("A=%4b, B=%4b, Cin=%4b , F=%4b, D=%4b \n",A,B,Cin,F,D );
#90 $finish;
end
endmodule