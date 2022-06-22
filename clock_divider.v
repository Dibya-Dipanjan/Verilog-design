module ClockDivider(sys_Clock, new_Clock);
parameter max=2;
parameter bitwidth=2;
input sys_Clock;
output reg newClock=0;
reg[bitwidth-1:0] counter=3'b000; 

always@(posedge sys_Clock)
begin

	counter=counter+1;
	
	if(counter == max)
		begin
			new_Clock = 0;
			counter = 3'b000;
		end
	else
		begin
			new_Clock = 1;
			counter = counter;
		end
end

endmodule