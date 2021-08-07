module signal_count(input [7:0] count, output reg [3:0] out,input clk,rst); // counting no. of ones
reg [7:0] tem; 
integer i;

always @(posedge clk)
begin 
	for(i=0;i<8;i=i+1)
		tem = tem + count[i];
	out <= tem;
end
endmodule	