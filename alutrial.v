//Starting a Module
module ALU(D,A,B,Cin,F);
//Input Variables
input [3:0] A,B,Cin,F;
//Output Variable
output [3:0] D;
reg [3:0] D;
always @(F,A,B,Cin)
begin
  case(F)
    4'b0000: D<=~A; //negation
    4'b0001: D<=A-B-Cin; //subtraction
    4'b0010: D<=A+B+Cin; //addition
    4'b0011: D<= A & B; //AND
    4'b0100: D<= A | B; //OR
    4'b0101: D<= A ^ B; //XOR
    4'b0110: D<= A ~^ B; //XNOR
    4'b0111: D<=A*B; //Multiplication
    4'b1000: D<=A/B; //Division
    4'b1001: D<=A<<1; //Left shift
    4'b1010: D<= A>>1; //Right shift
    4'b1011: D<=A+1; //Increment A 
    4'b1100: D<=A-1; //Decrement A 
  endcase
end
endmodule
