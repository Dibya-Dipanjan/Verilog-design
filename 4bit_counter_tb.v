module counter_tb;
reg clk;
reg reset;
wire [3:0] y;
counter uut(.clk(clk),.reset(reset),.y(y));
always #5 clk=~clk;
initial begin
clk <=0;
reset <=0;

#20 reset <=1;
#80 reset <=0;
#50 reset <=1;

#20 $finish;
end
endmodule