module fmultiplier(clk, rst, a, b, z);

input clk, reset;
input [31:0] a, b;
output reg [31:0] z;
reg [23:0] a_mantissa, b_mantissa, z_mantissa; //Mantissa
reg [9:0] a_exponent, b_exponent, z_exponent; //EXPONENTS
reg a_sign, b_sign, z_sign; // Sign_Bit

reg [49:0] product;

reg guard_bit, round_bit, sticky;
reg       [3:0] state;
parameter   start         = 4'd0,
            unpack        = 4'd1,
            special_cases = 4'd2,
            normalise_a   = 4'd3,
            normalise_b   = 4'd4,
            multiply_0    = 4'd5,
            multiply_1    = 4'd6,
            normalise_1   = 4'd7,
            normalise_2   = 4'd8,
            round         = 4'd9,
            pack          = 4'd10,
            put_z         = 4'd11;

always @(posedge clk or rst) begin
	if (reset)
	     state<=start;
    else begin 
	   
	    case(state)
	        start;
        
		unpack:
        begin		
	    //IEEE 754 Representation
		a_mantissa <= a[22:0];
	        b_mantissa <= b[22:0];
	        a_exponent <= a[30:23] - 127;
        	b_exponent <= b[30:23] - 127;
	        a_sign <= a[31];
        	b_sign <= b[31];
			state<=special_cases;
        end



            special_cases:
            begin
                if ((a_exponent == 128 && a_mantissa != 0) || (b_exponent == 128 && b_mantissa != 0)) begin
                //if a is NaN or b is NaN return NaN
                //IEEE 754 defines NaN as number with all exponent bits as 1 and non-zero mantissa 
                //if either operand is NaN, the result is NaN
                z[31] <= 1; 
                z[30:23] <= 255; //because NaN have all exponent bits as 1
                z[22] <= 1;      //because NaN has non-zero mantissa
                z[21:0] <= 0;
                state <= put_z;
                end 
                
                if((($signed(a_exponent) == -127) && (a_mantissa == 0) ) || ( ($signed(b_exponent) == -127) && (b_mantissa == 0))) begin
                    //If a or b is 0 then return 0
                    //IEEE 754 defines zero as all exponent and mantissa to be 0
                    z[31] <= a_sign ^ b_sign; 
                    z[30:23] <= 0; //because zero has all exponent bits 0
                    z[22:0] <= 0;  //because zero has mantissa 0
                    state <= put_z;
                end
                if((a_exponent==128 && a_mantissa == 0) && ($signed(b_exponent==-127) && (b_mantissa == 0))) begin
                // a is infinity and b is zero then result is NaN
                    z[31] <= 1;
                    z[30:23] <=255; //because NaN have all exponent bits as 1
                    z[22] <= 1;    //because NaN has non-zero mantissa
                    z[21:0] <=0;
                state <= put_z;
                end
                if((b_exponent==128 && b_mantissa == 0) && ($signed(a_exponent == -127) && (b_mantissa ==0))) begin
                // b is infinity and a is zero then result is NaN    
                    z[31] <= 1;
                    z[30:23] <=255; //because NaN have all exponent bits as 1
                    z[22] <= 1;    //because NaN has non-zero mantissa
                    z[21:0] <=0;
                    state <=put_z;
                end 
                if ((a_exponent==128 && a_mantissa==0) || (b_exponent==128 && b_mantissa==0)) begin
                    // either a or b is infinity then result is infinity
                    z[31] <= a_sign ^ b_sign;
                    z[30:23] <= 255;
                    z[22:0] <= 0;
                    state <=put_z;
                end
				if (($signed(a_exponent) == -127) && a_mantissa!=0) begin
                    //Denormalised Number have non-zero mantissa and zero exponent 
                    a_exponent <= -126; //IEEE 754 assigns -126 as exponent for denormal numbers
                end else begin
                    a_mantissa[23] <= 1; //For normal numbers an extra bit with 1 is added
                end
                //Denormalised Number have non-zero mantissa and zero exponent 
                if (($signed(b_exponent) == -127) && a_mantissa!=0) begin
                    b_exponent <= -126; //IEEE 754 assigns -126 as exponent for denormal numbers
                end else begin
                    b_mantissa[23] <= 1; //For normal numbers an extra bit with 1 is added
                end
                state <= normalise_a;
            end

            normalise_a:
			begin
	    
		    if (~a_mantissa[23]) begin//NORMALIZE A
			    state<=normalise_b;
				and else begin
	        	a_mantissa <= a_mantissa << 1;//Left shifting of mantissa of 'a' by 1-bit
	       	    a_exponent <= a_exponent - 1;// As left shift is there so exponent decreases by 1.
	            end
			end	
			normalise_b:
			begin
	           if (~b_mantissa[23]) begin//NORMALIZE B
		       state<=multiply_0;
               end else begin			   
	        	b_mantissa <= b_mantissa << 1;//Left shifting of mantissa of 'b' by 1-bit
	       	    b_exponent <= b_exponent - 1;//As left shift is there so exponent decreases by 1.
	        end
	     end



always @(counter) begin
	if(counter == 3'b100) begin //GET THE SIGNS XORED and EXPONENTS ADDED and GET THE INTERMEDIATE MANTISSA MULTIPLICATION
		z_sign <= a_sign ^ b_sign;
	        z_exponent <= a_exponent + b_exponent + 1 ;
        	product <= a_mantissa * b_mantissa *4;
	end
end


always @(counter) begin
	if(counter == 3'b101) begin
		z_mantissa <= product[49:26];
       	guard_bit <= product[25];
      		round_bit <= product[24];
      		sticky <= (product[23:0] != 0);
	end
end

always @(counter) begin
	if(counter == 3'b110) begin
		if ($signed(z_exponent) < -126) begin
        		z_exponent <= z_exponent + (-126 -$signed(z_exponent));
    			z_mantissa <= z_mantissa >> (-126 -$signed(z_exponent));
     			guard_bit <= z_mantissa[0];
       		round_bit <= guard_bit;
       		sticky <= sticky | round_bit;
        	end
		else if (z_mantissa[23] == 0) begin
        		z_exponent <= z_exponent - 1;
        		z_mantissa <= z_mantissa << 1;
        		z_mantissa[0] <= guard_bit;
        		guard_bit <= round_bit;
        		round_bit <= 0;
        	end
	        else if (guard_bit && (round_bit | sticky | z_mantissa[0])) begin
        		z_mantissa <= z_mantissa + 1;
          		if (z_mantissa == 24'hffffff)
            			z_exponent <=z_exponent + 1;
        	end
        end
end

always @(counter) begin
	if(counter == 3'b111) begin
		z[22:0] <= z_mantissa[22:0];
        	z[30:23] <= z_exponent[7:0] + 127;
        	z[31] <= z_sign;
        	if ($signed(z_exponent) == -126 && z_mantissa[23] == 0)
          		z[30:23] <= 0;
        	if ($signed(z_exponent) > 127) begin //IF OVERFLOW RETURN INF
          		z[22:0] <= 0;
          		z[30:23] <= 255;
          		z[31] <= z_sign;
        	end
	end
end


endmodule