`timescale 1 ns / 1 ns


module testbench_FULL();


parameter ADDRESSLENGTH = 8;
parameter ADDRESSNUM = 1;
parameter NBYTES = 2;




reg Start = 1'b0;
reg Clk = 1'b0;
reg RST = 1'b1;
wire SDA;
wire SCL;
reg RorW = 1'b0;
wire [ADDRESSLENGTH-1: 0] DirectionBuffer;
wire AddressFound = 1'b0;
wire [3:0]state;
wire [7:0]OutputBuffer;
wire [7:0]InputBuffer;
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList = 8'b10101010;
wire [ADDRESSLENGTH - 1:0] Slave_Address = 8'b10101010;
wire [3:0] NBytes = 4'b0010; //número de bytes que va haber en cada transferencia
	
wire [7:0]DataToSlave = 8'b00110011;
wire [7:0]DataFromSlave;


wire [8*NBYTES*ADDRESSNUM - 1: 0 ] Data;
wire slave_state;
wire start;

pullup (SDA); 
pullup (SCL); 


I2C_SLAVE#( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave(SDA, SCL, AddressList, DirectionBuffer, InputBuffer, OutputBuffer, slave_state, start, Data);

I2C_MASTER#( ADDRESSLENGTH) master(Clk, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave, state);





initial begin
#20;
RST = 1'b0;
RorW = 1'b1;
#20;
RST = 1'b0;
#10;
RST = 1'b1;
#10;
Start = 1'b1;
#1000;
//test de lectura, vamos a leer los datos
#20;
RST = 1'b0;
#20
RorW = 1'b0;
#20;
RST = 1'b1;
#1000;
$stop;

end
initial begin
	Clk = 0;
end
always #10 Clk = ~Clk;


endmodule

