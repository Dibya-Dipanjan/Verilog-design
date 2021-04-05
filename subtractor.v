// Here (a - b) is performed
   // 0 in sign bit ---> positive number
   // 1 in sign bit ---> negative number
module subtractor(clk , rst , a , b, z);

input clk,rst;
input [17:0] a,b; // INPUTS
output reg[18:0] z; // OUTPUT

reg [3:0] state; 

reg [16:0] a_magnitude, b_magnitude;
reg [17:0] z_magnitude;
reg a_sign,b_sign;
reg z_sign;

always @(posedge clk or rst) begin
	if(rst)
		state<= 0;
	else
		state <= state + 1;
end

always @(state) begin
if(state == 4'b0001) begin
	   a_magnitude = a[16:0]; // Magnitude Bits
	   a_sign = a[17]; //Sign Bit
	   b_magnitude = b[16:0]; //Magnitude Bits
	   b_sign = b[17]; //Sign Bit
	end
end

always @(state) begin
if(state == 4'b0010)begin
	if((a_sign == 0 && b_sign == 0) && (a_magnitude > b_magnitude)) begin
	z[18] = 0; // As here a > b 
	z[17:0] = a_magnitude - b_magnitude; // Subtraction only magnitude taken into comsideration(greater - smaller)
        end
    end
end

always @(state) begin
	if(state == 4'b0011) begin
		if((a_sign == 0 && b_sign == 0) && (a_magnitude < b_magnitude)) begin
			z[18] = 1; // As here a < b
			z[17:0] = b_magnitude - a_magnitude; //Subtraction only magnitude taken into comsideration(greater - smaller)
			end
	end
end		
                    

always @(state) begin
		if(state == 4'b0100) begin
			if((a_sign == 0 && b_sign == 1)) begin
				z[18] = 0; // Here the result is positive number as b is negative and doing a - b 
				z[17:0] = a_magnitude + b_magnitude; // In a - b "a" and "-b"(since b is negative so -b is positive) are of same sign so magnitude gets added
				end
		end
end

always @(state) begin
		if(state == 4'b0101) begin
			if((a_sign == 1 && b_sign == 0)) begin
				z[18] = 1; //Here the result is negative number as a is negative and doing a - b 
				z[17:0] = a_magnitude + b_magnitude; //Both "a" and "-b" (since b is positive so -b is negative) are of same sign so magnitude gets added
				end
		end
end

always @(state) begin
if(state == 4'b0110)begin
	if((a_sign == 1 && b_sign == 1) && (a_magnitude > b_magnitude)) begin
		z[18] = 1; // As here a < b so result is negative
		z[17:0] = a_magnitude - b_magnitude; //Subtraction only magnitude taken into comsideration(greater - smaller)
        end
    end
end

always @(state) begin
	if(state == 4'b0111) begin
		if((a_sign == 1 && b_sign == 1) && (a_magnitude < b_magnitude)) begin
			z[18] = 0; // As here a > b so result is negative
			z[17:0] = b_magnitude - a_magnitude; //Subtraction only magnitude taken into comsideration(greater - smaller)
			end
	end
end

always @(state) begin
	if(state == 4'b1000) begin
		if((a_sign == b_sign) && (a_magnitude == b_magnitude))begin
			z[18] = 0; 
			z[17:0] = 0; // As both are same magnitude so result
		end
	end
end	

always @(state) begin
	if(state == 4'b1001)begin
		z_sign = z[18]; // Sign bits
		z_magnitude = z[17:0]; // Magnitude bits
	end
end	


endmodule	

		
				