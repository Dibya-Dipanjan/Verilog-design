`timescale 1ns/1ns
module rom_tb;
reg [3:0]addr;
reg rd_en;
reg cs;
wire [9:0] data;
integer a;

rom uut(.addr(addr),.data(data));
initial 
begin
    $dumpfile("rom1.vcd");
    $dumpvars(0,rom_tb);
    for(a=0;a<10;a=a+1)// declaring and running loop
    begin
        addr=a;#30;
        $display("%h",data); // output as per text file
    end 

    
end

endmodule