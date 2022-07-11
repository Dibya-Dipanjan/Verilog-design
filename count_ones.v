module count_ones(input [15:0]A, output reg [5:0]ones);
integer i;

always @(A)
begin
  ones=0; //Initialize count 
  for(i=0;i<16;i=i+1) //Check for all bits
    if(A[i] = 1'b1) // Check if bit is 1
        ones = ones + 1; // if one then decrement
end
endmodule
