module fmultiplier(clk, rst, a, b, z);

input clk, rst;
input [31:0] a, b;
output reg [31:0] z;

reg [2:0] state;

reg [23:0] a_mantissa, b_mantissa, z_mantissa;
reg [9:0] a_exponent, b_exponent, z_exponent;
reg a_sign, b_sign, z_sign;

reg [49:0] product;

reg guard_bit, round_bit, sticky;

always @(posedge clk or rst) begin
	if(rst)
		state<= 0;
	else
		state <= state + 1;
end


always @(state) begin
	if(state == 3'b001) begin //Representing in IEEE-754 notation
		a_mantissa <= a[22:0];
	        b_mantissa <= b[22:0];
	        a_exponent <= a[30:23] - 127;
        	b_exponent <= b[30:23] - 127;
	        a_sign <= a[31];
        	b_sign <= b[31];
        end
end


always @(state) begin
	if(state == 3'b010) begin //Special Cases
		if ((a_exponent == 128 && a_mantissa != 0) || (b_exponent == 128 && b_mantissa != 0)) begin //If a is NaN or b is NaN then z is NaN
		//In IEEE-754 notation NaN is when all exponent bits are 1 and a non zero mantissa
          		z[31] <= 1;
          		z[30:23] <= 255;
          		z[22] <= 1;
          		z[21:0] <= 0;
          	end
          	else if (a_exponent == 128) begin //If a is infinity then the result is infinity 
			//In IEEE-754 notation Infinity is when all exponent bits are 1 and mantissa is 0
          		z[31] <= a_sign ^ b_sign;
          		z[30:23] <= 255;
          		z[22:0] <= 0;
          		if (($signed(b_exponent) == -127) && (b_mantissa == 0)) begin //Here in this case if a is infinity and b is 0 then result is NaN
            			z[31] <= 1;
            			z[30:23] <= 255;
	        	    	z[22] <= 1;
        		    	z[21:0] <= 0;
          		end
          	end
          	else if (b_exponent == 128) begin //If b is infinity then result is infinity
          		z[31] <= a_sign ^ b_sign;
          		z[30:23] <= 255;
          		z[22:0] <= 0;
          		if (($signed(a_exponent) == -127) && (a_mantissa == 0)) begin //If b is infinity and a is 0 the result is NaN
            			z[31] <= 1;
            			z[30:23] <= 255;
	        	    	z[22] <= 1;
        		    	z[21:0] <= 0;
          		end
          	end
	          else if (($signed(a_exponent) == -127) && (a_mantissa == 0)) begin //0 if a = 0
       		 z[31] <= a_sign ^ b_sign;
       		 z[30:23] <= 0;
        	 	 z[22:0] <= 0;
        	  end
        	  else if (($signed(b_exponent) == -127) && (b_mantissa == 0)) begin //0 if b = 0
        	 	 z[31] <= a_sign ^ b_sign;
        	  	 z[30:23] <= 0;
        	  	 z[22:0] <= 0;
        	  end
        	  else begin
			  //Denormalised Number have non-zero mantissa and zero exponent
        	  	if ($signed(a_exponent) == -127) //DENORMALIZING A
        	    		a_exponent <= -126;//IEEE 754 assigns -126 as exponent for denormal numbers
        	  	else
        	    		a_mantissa[23] <= 1;//For normal numbers an extra bit with 1 is added
            		
        	    	if ($signed(b_exponent) == -127) //DENORMALIZING B
        	    		b_exponent <= -126;//IEEE 754 assigns -126 as exponent for denormal numbers
        	  	else
        	    		b_mantissa[23] <= 1;//For normal numbers an extra bit with 1 is added
        	  end
        end
end


always @(state) begin
	if(state == 3'b011) begin //Normalization of a and b 
		if (~a_mantissa[23]) begin //NORMALIZE A
	        	a_mantissa <= a_mantissa << 1;//Shifting the mantissa by 1 bit
	       	a_exponent <= a_exponent - 1; //Subtracting the exponent for the above shifting
	        end
	        if (~b_mantissa[23]) begin //NORMALIZE B
	        	b_mantissa <= b_mantissa << 1;//Shifting the mantissa by 1 bit
	       	b_exponent <= b_exponent - 1;//Subtracting the exponent for the above shifting
	        end
	end
end


always @(state) begin
	if(state == 3'b100) begin //Multiplication of normal numbers
		z_sign <= a_sign ^ b_sign;//sign for result is calculated by XORing the signs of both multiplicands
	        z_exponent <= a_exponent + b_exponent + 1;
			//On multiplying mantissas operands should have 1 integer bit. So the result of the products has 2 integer bits. 
			//So here 1 is added to the exponent here to have 1 integer bit .
        	product <= a_mantissa * b_mantissa * 4;
			//Another 2 bits were added to accomodate guard and round bits giving a total of 50 bits product. 
			//In order to add these additional bits(0s) to the right hand side(fraction bits), 4 is multiplied in order to shift it by 2 places.
	end
end


always @(state) begin
	if(state == 3'b101) begin//
		z_mantissa <= product[49:26];// In Scientic Notation(IEEE 754) it represents mantissa 
       	guard_bit <= product[25];// Guard Bit: The bit after the representation in scientific notation
      		round_bit <= product[24];// Round Bit : The bit after the representation of Guard Bit
      		sticky <= (product[23:0] != 0);// Sticky Bits: The bits after the round bit
	end
end

always @(state) begin
	if(state == 3'b110) begin
		if ($signed(z_exponent) < -126) begin
        		z_exponent <= z_exponent + (-126 -$signed(z_exponent));
    			z_mantissa <= z_mantissa >> (-126 -$signed(z_exponent));
     			guard_bit <= z_mantissa[0];
       		    round_bit <= guard_bit;// Guard bit is equal to round bit
       		    sticky <= sticky | round_bit; //Bitwise OR operation
        	end
		else if (z_mantissa[23] == 0) begin
        		z_exponent <= z_exponent - 1; // /As z_mantissa[23] == 0 so exponent is reduced is 1
                z_mantissa <= z_mantissa << 1; // Left Shifting by 1 bit
				z_mantissa[0] <= guard_bit;
        		guard_bit <= round_bit; // Guard bit is equal to round bit
				round_bit <= 0;
        	end
	        else if (guard_bit && (round_bit | sticky | z_mantissa[0])) begin
        		z_mantissa <= z_mantissa + 1;
          		if (z_mantissa == 24'hffffff) //
            			z_exponent <=z_exponent + 1;
        	end
        end
end

always @(state) begin
	if(state == 3'b111) begin
		z[22:0] <= z_mantissa[22:0]; //Assigning the mantissa value
        	z[30:23] <= z_exponent[7:0] + 127; //Bias exponent
        	z[31] <= z_sign; //Sign_bit
        	if ($signed(z_exponent) == -126 && z_mantissa[23] == 0)
          		z[30:23] <= 0; // z is 0 
        	if ($signed(z_exponent) > 127) begin //IF OVERFLOW RETURN INF
          		z[22:0] <= 0;
          		z[30:23] <= 255;
          		z[31] <= z_sign;
        	end
	end
end


endmodule