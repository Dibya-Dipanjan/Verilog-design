module d_ff(input clk,rst,d,output q,qbar);
reg q;

assign qbar = ~q;

always @(posedge clk)
begin
    if(rst)
        q <= 0;
    else
        q <= d;   
end
endmodule