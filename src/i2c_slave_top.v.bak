module I2C_SLAVE #( parameter ADDRESSLENGTH, parameter ADDRESSNUM, parameter NBYTES)(SDA, SCL, AddressList, DirectionBuffer, InputBuffer, OutputBuffer, state, start, Data);

input SDA;
input SCL;
input wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0] AddressList;
wire HaveAddress;
output wire [(ADDRESSLENGTH-1): 0] DirectionBuffer; //Buffer para guardar la dirección que solicita el master
output wire [7:0]InputBuffer; //Bufer donde irán todos los datos guardadosa a la memoria
output wire [7:0]OutputBuffer;
wire RorW;
wire MemoryEnable;


output wire [8*NBYTES*ADDRESSNUM - 1: 0 ] Data;
output wire state;
output wire start;



I2C_SLAVE_UC #( ADDRESSLENGTH) slave_uc(SDA, SCL, HaveAddress, DirectionBuffer, InputBuffer, OutputBuffer, RorW, MemoryEnable, start, state);

I2C_SLAVE_MEMORY #( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave_memory(MemoryEnable, RorW, DirectionBuffer, InputBuffer, OutputBuffer, HaveAddress, AddressList, Data);


endmodule



