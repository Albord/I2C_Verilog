`timescale 1 ns / 1 ps


module testbench_FULL();


parameter ADDRESSLENGTH = 8;
parameter ADDRESSNUM = 2;
parameter NBYTES = 2;





reg Clk = 1'b0;
wire SDA;
wire SCL;
reg RorW = 1'b1;
reg [ADDRESSLENGTH-1: 0] DirectionBuffer = 8'b00001111;
reg AddressFound = 1'b0;

reg [7:0]OutputBuffer;
wire [7:0]InputBuffer = 8'b0;
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList = 24'b000011110000111000011000;
wire [ADDRESSLENGTH - 1:0] Slave_Address;
wire [3:0] NBytes = 4'b0001; //número de bytes que va haber en cada transferencia
	
wire [7:0]DataToSlave;
reg [7:0]DataFromSlave;


 	

pullup (SDA); 
pullup (SCL); 


I2C_SLAVE#( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave(SDA, SCL, AddressList, DirectionBuffer, InputBuffer, OutputBuffer);

I2C_MASTER#( ADDRESSLENGTH) master(Clk, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave);





initial begin
#10;

#10;

#10;
end
initial begin
	Clk = 0;
end
always #10 Clk = ~Clk; //100KHz


endmodule

