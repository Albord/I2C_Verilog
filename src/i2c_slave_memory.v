/*
	Autor: Albert Espi�a Rojas
	Modulo: I2C_SLAVE_MEMORY
	Modulo de memoria. Podemos acceder y guardar datos. 
	El modulo tiene como parametro, el tama�o de la direcci�n de memoria, el n�mero de direcci�nes ,es decir el n�mero de datos
	y el n�mero de bytes en los datos

*/

module I2C_SLAVE_ADDRESS_MATCH #( parameter ADDRESSLENGTH, parameter ADDRESSNUM, parameter NBYTES)(Enable, Mode, RorW, Buffer, AddressFound, Data, AddressList);
	input Enable; //
	input Mode;
	input RorW;
	
	output reg AddressFound = 1'b0;


	output reg [ADDRESSLENGTH || 8 - 1: 0] Buffer;
	output reg [8*NBYTES*ADDRESSNUM: 0 ] Data;

	
	input [(ADDRESSLENGTH - 1)*ADDRESSNUM: 0]AddressList;
	
	
	integer LocalAddressID = 0;
	integer ByteCounter = 0;
	

always @(posedge Enable)//Si se activa el enable, es cuando transferimos los datos del buffer a la memoria
begin
	if (Mode) begin //Modo transferencia, intercambiamos datos entre el buffer y los datos de la memoria
		
		

		if (RorW) Buffer <= Data[(ByteCounter+1)*(8) +:1];
		else Data[LocalAddressID*8*NBYTES +:(ByteCounter)*(8)] <= Buffer;
		if (ByteCounter < NBYTES - 1) ByteCounter <= ByteCounter + 1;
	end
	else begin //El enable tambi�n puede ser para ver si se dispone de una direcci�n de memoria
		AddressFound <= 1'b0;
		ByteCounter <= 0;
		for(LocalAddressID = 0; (LocalAddressID < ADDRESSNUM) ||  !AddressFound; LocalAddressID = LocalAddressID + 1) begin
			if (AddressList[ADDRESSLENGTH*(LocalAddressID+1):ADDRESSLENGTH*(LocalAddressID)] == Buffer[ADDRESSLENGTH:0]) AddressFound <= 1'b1;
		end
	end
end

endmodule