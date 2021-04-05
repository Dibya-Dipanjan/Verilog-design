`timescale 1ns/1ns
module subtractor_tb;

reg [17:0] a, b;
wire [18:0] z;
reg clk, rst;

subtractor uut(.clk(clk) , .rst(rst), .a(a), .b(b), .z(z));

initial begin
	$dumpfile("wave.vcd");
	$dumpvars(0, subtractor_tb);
end

initial begin
	clk <= 0;
	rst <= 1;
	repeat(17000)
		#5 clk <= ~clk;
end

initial #13 rst <= 0;

initial begin

	
	
	#80
		a = 18'b111111111111111111;
		b = 18'b011111111111111111;
		#180
		$display("a=%b, b=%b, z=%b,t=%0t", a,b,z,$time );
		

	
	#200 $finish;
end


endmodule