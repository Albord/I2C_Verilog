/*
	Autor: Albert Espi�a Rojas
	Modulo: I2C_SLAVE_ADDRESS_UC



*/

module I2C_SLAVE_ADDRESS_UC #( parameter ADDRESSLENGTH, parameter MaxAddress)(SDA, SCL,
	output reg Start = 1'b0;
	output reg MasterAddress;
	reg Counter = 1'b0;//(Hay que hacer el counter de m�s bits)
	input reg HaveAddress;
	reg Buffer[LENGTH || 8 - 1: 0] = 1'b0; // Buffer donde ir�n todos los datos recibidos, tanto para buscar la direcci�n como datos a mem�ria
	reg Status = 1'b0;//Estado 0 cuando el master est� solicitando conexi�n. Estado 1, cuando hay transferencia
	reg RorW = 1'b0; //Estado 0 lectura, estado 1 escritura
always @(posedge SDA) begin
	if (!SCL) begin //Condici�n de start
		Counter = 1'b0;
		Start <= 1'b1;
		Status <= 1'b0;
	end
end
always @(posedge SCL) begin
	if (Start) begin
		if (!Mode) begin
			if (Counter < ADDRESSLENGTH) begin //Recibiendo los datos de la direcci�n de memoria
				I2C_SHIFT_REGISTER #( ADDRESSLENGTH)(SCL, SDA, Buffer);
				Counter = Counter + 1;
			end
			
			if (Counter == ADDRESSLENGTH) begin
				RorW <= SDA;
				Counter = Counter + 1;
			end //En otro caso, hay que esperar la informaci�n de los otros modulos
		end
	end
end

always @(Counter) begin
	if (Status){
		if (RorW)

	}





/*
	Enviamos la direcci�n de la memoria y en el modulo de memor�a se comprovar�
	Si esta direcci�n de memoria pertenence a este slave	
*/
	if (Counter ==  ADDRESSLENGTH) MasterAddress <= Buffer[ADDRESSLENGTH:0];
	



	/*
	Despu�s de un par de ciclos de reloj(por precauci�n), comprovamos si el dispositivo tiene la direcci�n la cual
	el maestro est� solicitando una transferencia.
	En caso de que no la tenga podemos desactivar la transferencia, ya que por lo tanto
	la transferencia se tendr� que hacer con otro esclavo 
*/
	if (Counter == ADDRESSLENGTH + 2) if (!HaveAddress) Start = 'b0;
	


	
end






/*
Rst, Enable, Mode, InputAddress, AddressFound);
	input Clk;
 	input Rst; 
	input Enable; 
	input Mode;
	input [LENGTH - 1: 0]InputAddress;
	output reg [LENGTH - 1: 0]AddressFound;
	reg [(LENGTH - 1)*MaxAddress: 0]AddressList;
always @(posedge Clk)
begin
    	if (!Rst) AddressFound = 1'b0;
  	else if (Enable) begin
		if (Mode) AddressFound = 1'b0; //Falta a�adir cosas
		else AddressFound = 1'b0; //Falta a�adir cosas
	end
end
*/

endmodule