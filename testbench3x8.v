`timescale 1ns/1ps
module decoder3x8_tb;
reg [2:0]a;
wire [7:0]y;
dec3x8 uut(.Y(y),.A(a) );
always begin
$dumpfile("decode.vcd");
$dumpvars(0,decoder3x8_tb);
	a=3'b000;
#10 a=3'b001;
#10 a=3'b010;
#10 a=3'b011;
#10 a=3'b100;
#10 a=3'b101;
#10 a=3'b110;
#10 a=3'b111;
#20 $finish;
end
initial begin
$display ("time\t a[2] \t a[1] \t a[0] \t y[7] \t y[6] \t y[5] \t y[4] \t y[3] \t y[2] \t y[1]\t  y[0] ");
$monitor ("%g \t %b \t %b \t %b \t %b \t %b \t %b \t %b \t %b \t %b \t %b \t %b ", $time, a[2], a[1], a[0],y[7],y[6],y[5],y[4],y[3],y[2],y[1],y[0]);
#90 $finish;
end
endmodule