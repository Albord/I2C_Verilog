/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_SLAVE_MEMORY
	Modulo de memoria. Podemos acceder y guardar datos. 
	El modulo tiene como parametro, el tamaño de la dirección de memoria, el número de direcciónes ,es decir el número de datos
	y el número de bytes en los datos

*/

module I2C_SLAVE_MEMORY #( parameter ADDRESSLENGTH, parameter ADDRESSNUM, parameter NBYTES)(Enable, RorW, DirectionBuffer, InputBuffer, OutputBuffer, AddressFound, AddressList, Data);
	//ADDRESSLENGTH ES EL TAMAÑO DE LA DIRECCIÓN DEL ESCLAVO
	//ADDRESSNUM, EL NÚMERO DE DIRECCIÓNES QUE POSEE EL ESCLAVO, ESTÁ FIJADA A 1
	//NBYTES ES EL NÚMERO DE BYTES QUE CONTIENE LA MEMORIA DEL ESCLAVO POR DIRECCIÓN
	input Enable; //Registro para activar la comunicación etre la memoria y la unidad de control
	input RorW;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir
	input wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList;//Variable para guardar la dirección del esclavo
	output reg AddressFound = 1'b0;//Registro para indicar si la dirección del esclavo coincide con la solicitada
	input wire [(ADDRESSLENGTH-1): 0] DirectionBuffer;//Buffer para guardar la dirección que solicita el maste
	input wire [7:0]InputBuffer;//Bufer donde irán todos los datos guardadosa a la memoriA
	output reg [7:0]OutputBuffer;// Buffer donde irán todos los datos recibidos
	output reg [8*NBYTES*ADDRESSNUM - 1: 0 ] Data = 1'b0;//Memoria del esclavo donde irán todos los datos guardados
	integer LocalAddressID = 0;//Variable para hacer que un eslavo pueda tener diferentes direcciónes
	integer ByteCounter = 0;//Contador de bytes que lleva una transferencia, para no exceder el tamaño de la memoria
	

always @(posedge Enable)//Si se activa el enable, es cuando transferimos los datos del buffer a la memoria
begin
	 //Modo transferencia, intercambiamos datos entre el buffer y los datos de la memoria
	if (RorW) Data[LocalAddressID*8*NBYTES + (ByteCounter)*(8) +:8] <= InputBuffer;//guardamos datos en la memoria
	else OutputBuffer <= Data[LocalAddressID*8*NBYTES + (ByteCounter)*(8) +:8];//obtenemos datos de la memoria
	if (ByteCounter < NBYTES - 1) ByteCounter <= ByteCounter + 1;//SI el contador excede el número de bytes fijado
	else ByteCounter <= 0;//Por seguridad vuelve a 0
end

always@(DirectionBuffer) begin
	
	ByteCounter = 0;//Si la dirección cambia, ponemos el dato el bytecounter a 0
	LocalAddressID = 0;
	if (AddressList[ADDRESSLENGTH*(LocalAddressID)+:8] == DirectionBuffer) AddressFound = 1'b1;//si coindice la direcció	
	else AddressFound = 1'b0;//indicamos si es correcta o no
/* código experimental para probar el sistema de varias direcciones, no obstante el for es problematico en verilog
	for(LocalAddressID = 0; (LocalAddressID < ADDRESSNUM) && !AddressFound; LocalAddressID = LocalAddressID + 1) begin
		if (AddressList[ADDRESSLENGTH*(LocalAddressID)+:8] == DirectionBuffer) AddressFound = 1'b1;
	end
*/
end


endmodule