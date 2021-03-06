/*
	Autor: Albert Espi�a Rojas
	Modulo: I2C_SLAVE_MEMORY
	Modulo de memoria. Podemos acceder y guardar datos. 
	El modulo tiene como parametro, el tama�o de la direcci�n de memoria, el n�mero de direcci�nes ,es decir el n�mero de datos
	y el n�mero de bytes en los datos

*/

module I2C_SLAVE_MEMORY #( parameter ADDRESSLENGTH, parameter ADDRESSNUM, parameter NBYTES)(Enable, RorW, DirectionBuffer, InputBuffer, OutputBuffer, AddressFound, AddressList, Data);
	//ADDRESSLENGTH ES EL TAMA�O DE LA DIRECCI�N DEL ESCLAVO
	//ADDRESSNUM, EL N�MERO DE DIRECCI�NES QUE POSEE EL ESCLAVO, EST� FIJADA A 1
	//NBYTES ES EL N�MERO DE BYTES QUE CONTIENE LA MEMORIA DEL ESCLAVO POR DIRECCI�N
	input Enable; //Registro para activar la comunicaci�n etre la memoria y la unidad de control
	input RorW;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir
	input wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList;//Variable para guardar la direcci�n del esclavo
	output reg AddressFound = 1'b0;//Registro para indicar si la direcci�n del esclavo coincide con la solicitada
	input wire [(ADDRESSLENGTH-1): 0] DirectionBuffer;//Buffer para guardar la direcci�n que solicita el maste
	input wire [7:0]InputBuffer;//Bufer donde ir�n todos los datos guardadosa a la memoriA
	output reg [7:0]OutputBuffer;// Buffer donde ir�n todos los datos recibidos
	output reg [8*NBYTES*ADDRESSNUM - 1: 0 ] Data = 1'b0;//Memoria del esclavo donde ir�n todos los datos guardados
	integer LocalAddressID = 0;//Variable para hacer que un eslavo pueda tener diferentes direcci�nes(desactivado)
	integer ByteCounter = 0;//Contador de bytes que lleva una transferencia, para no exceder el tama�o de la memoria
	

always @(posedge Enable)//Si se activa el enable, es cuando transferimos los datos del buffer a la memoria
begin
	 //Modo transferencia, intercambiamos datos entre el buffer y los datos de la memoria
	if (RorW) Data[LocalAddressID*8*NBYTES + (ByteCounter)*(8) +:8] <= InputBuffer;//guardamos datos en la memoria
	else OutputBuffer <= Data[LocalAddressID*8*NBYTES + (ByteCounter)*(8) +:8];//obtenemos datos de la memoria
	if (ByteCounter < NBYTES - 1) ByteCounter <= ByteCounter + 1;//SI el contador excede el n�mero de bytes fijado
	else ByteCounter <= 0;//Por seguridad vuelve a 0
end

always@(DirectionBuffer) begin
	ByteCounter = 0;//Si la direcci�n cambia, ponemos el dato el bytecounter a 0
	if (AddressList[ADDRESSLENGTH-1:0] == DirectionBuffer) AddressFound = 1'b1;//si coindice la direcci�	
	else AddressFound = 1'b0;//indicamos si es correcta o no
/* c�digo experimental para probar el sistema de varias direcciones, no obstante el for es problematico en verilog
	for(LocalAddressID = 0; (LocalAddressID < ADDRESSNUM) && !AddressFound; LocalAddressID = LocalAddressID + 1) begin
		if (AddressList[ADDRESSLENGTH*(LocalAddressID)+:8] == DirectionBuffer) AddressFound = 1'b1;
	end
*/
end


endmodule