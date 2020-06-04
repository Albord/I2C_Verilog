/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_SLAVE_MEMORY
	Modulo de memoria. Podemos acceder y guardar datos. 
	El modulo tiene como parametro, el tamaño de la dirección de memoria, el número de direcciónes ,es decir el número de datos
	y el número de bytes en los datos

*/

module I2C_SLAVE_MEMORY #( parameter ADDRESSLENGTH, parameter ADDRESSNUM, parameter NBYTES)(Enable, Mode, RorW, DirectionBuffer, InputBuffer, OutputBuffer, AddressFound, AddressList, Data, LocalAddressID);
	input Enable; //
	input Mode;
	input RorW;
	input [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList;
	output reg AddressFound = 1'b0;
	input wire [(ADDRESSLENGTH-1): 0] DirectionBuffer;
	input wire [7:0]InputBuffer;
	output reg [7:0]OutputBuffer;
	output reg [8*NBYTES*ADDRESSNUM: 0 ] Data = 1'b0;
	output integer LocalAddressID = 0;
	integer ByteCounter = 0;
	

always @(posedge Enable)//Si se activa el enable, es cuando transferimos los datos del buffer a la memoria
begin
	if (Mode) begin //Modo transferencia, intercambiamos datos entre el buffer y los datos de la memoria
		if (RorW) Data[LocalAddressID*8*NBYTES + (ByteCounter)*(8) +:8] <= InputBuffer;
		else OutputBuffer <= Data[LocalAddressID*8*NBYTES + (ByteCounter)*(8) +:8];
		if (ByteCounter < NBYTES - 1) ByteCounter <= ByteCounter + 1;
		else ByteCounter <= 0;
	end
end

always@(DirectionBuffer) begin
	AddressFound = 1'b0;
	ByteCounter = 0;
	LocalAddressID = 0;
	for(LocalAddressID = 0; (LocalAddressID < ADDRESSNUM) &&  !AddressFound; LocalAddressID = LocalAddressID + 1) begin
		if (AddressList[ADDRESSLENGTH*(LocalAddressID)+:8] == DirectionBuffer) AddressFound = 1'b1;
	end
end


endmodule