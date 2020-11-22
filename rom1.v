module rom(addr,data,rd_en,cs);

input [3:0]addr;
output [9:0]data;
input rd_en,cs;
reg [9:0] mem[9:0]; // declaring memory array of 9-bits
reg [9:0]data;
initial 
begin
    
    $readmemh("rom.txt",mem); //syntax to read hexadecimal file

end
always @(addr)
    begin
        case(addr)
        //assigning the adder corresponding values
            4'b0000: data=mem[0];
            4'b0001: data=mem[1]; 
            4'b0010: data=mem[2];
            4'b0011: data=mem[3];
            4'b0100: data=mem[4]; 
            4'b0101: data=mem[5]; 
            4'b0110: data=mem[6]; 
            4'b0111: data=mem[7]; 
            4'b1000: data=mem[8]; 
            4'b1001: data=mem[9]; 
        endcase
    end

endmodule