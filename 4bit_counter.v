module counter(input clk,input reset, output [3:0] y);
reg [3:0] y;
always@(posedge(clk))
begin
if(reset==1'b1)
y=4'b0000;
else
y=y+1;
end
endmodule