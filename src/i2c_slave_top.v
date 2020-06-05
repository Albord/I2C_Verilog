module I2C_SLAVE #( parameter ADDRESSLENGTH, parameter ADDRESSNUM, parameter NBYTES)(SDA, SCL, AddressList, DirectionBuffer, InputBuffer, OutputBuffer);

input SDA;
input SCL;
input wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0] AddressList;
reg HaveAddress;
output wire [(ADDRESSLENGTH-1): 0] DirectionBuffer; //Buffer para guardar la dirección que solicita el master
output wire [7:0]InputBuffer; //Bufer donde irán todos los datos guardadosa a la memoria
output wire [7:0]OutputBuffer;
reg RorW;
reg MemoryEnable;



I2C_SLAVE_ADDRESS_UC #( ADDRESSLENGTH) slave_uc(SDA, SCL, HaveAddress, DirectionBuffer, InputBuffer, OutputBuffer, RorW, MemoryEnable);

I2C_SLAVE_MEMORY #( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave_memory(MemoryEnable, RorW, DirectionBuffer, InputBuffer, OutputBuffer, AddressFound, AddressList);


endmodule



