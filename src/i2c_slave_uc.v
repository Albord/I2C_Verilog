/*
	Autor: Albert Espi�a Rojas
	Modulo: I2C_SLAVE_ADDRESS_UC



*/

module I2C_SLAVE_ADDRESS_UC #( parameter ADDRESSLENGTH)(SDA, SCL, HaveAddress, Buffer, RorW, Status, MemoryEnable);
	
	input SCL;
	output reg SDA;
	input HaveAddress;//Input de la memoria para indicar que el dispositivo tiene la direcci�n de memoria solicitada

	output reg [ADDRESSLENGTH || 8 - 1: 0] Buffer = 1'b0; // Buffer donde ir�n todos los datos recibidos, tanto para buscar la direcci�n como datos a mem�ria
	output reg RorW = 1'b0; //Estado 0 lectura, estado 1 escritura
	output reg Status = 1'b0;//Estado 0 cuando el master est� solicitando conexi�n. Estado 1, cuando hay transferencia
	output reg MemoryEnable = 1'b0; //Registro para activar la comunicaci�n etre la memoria y la unidad de control
	reg Start = 1'b0;//Estado para activar el dispositivo slave
	integer Counter = 1'b0;//Contador de los bits del sda, 
	
	
	
always @(negedge SDA) begin //Condici�n de start
	if (SCL) begin 
		Counter <= 0;
		Start <= 1'b1;
		Status <= 1'b0;
		RorW <= 1'b0;
		MemoryEnable <= 1'b0;
	end
end
always @(posedge SDA) begin //Condici�n de stop
	if (SCL) Start <= 1'b0;
end
always @(posedge SCL) begin
	if (Start) begin

		if (Status) begin
			if (Counter < 8) begin//las transferencias son de byte a byte, por lo tanto hay que tener el contador tambi�n
				if (!RorW) Buffer[Counter] <= SDA; //guardamos el dato en el buffer ya que estamos recibiendo
				
			end
			if (Counter == 8) begin //fin del byte de datos, hay que mirar si hemos recibido un ack o un nack en el caso de modo escritura
				if (RorW) MemoryEnable <= SDA; //Si tenemos un 1 es un ack y por lo tanto podemos pedir el siguiente dato
			end
		
		end
		else begin
			if (Counter < ADDRESSLENGTH) begin //Recibiendo los datos de la direcci�n de memoria
				Buffer[Counter] <= SDA;
				Counter <= Counter + 1;
				
			end
			if (Counter == ADDRESSLENGTH-1) MemoryEnable <= 1'b1; //Preguntamos a la memoria si disponemos de la direcci�n
			else if (Counter == ADDRESSLENGTH) begin //Al siguiente ciclo el master especificar� si la tranasferencia es read or write
				if (HaveAddress) begin //Si disponemos de la direcci�n, pasamos al modo de transferencia de datos
					RorW <= SDA;
					Counter <= 0;
					SDA <= 1'b1;
					Status <= 1'b1;
				end
			end 
			else Start <= 0; //En caso de que la transferencia no sea con este dispositivo, lo desactivamos
		end
	end
end

always @(negedge SCL) begin
/*
	El flanco de bajada del clock est� destinado para que el slave env�e datos a trav�s del sda, cuando sea necesario
*/

	if (Status) begin
		//En este caso enviamos r�fagas de 8 bits y esperamos a recibir el ack si estamos escribiendo
		if (Counter < 8) begin 
			if (RorW) SDA <= Buffer[Counter];
			Counter <= Counter + 1;	
		end

		 //fin del byte de datos, hay enviar o recibir un ack y de paso guardamos el buffer en la memoria
		if (Counter >= 8) begin 
			if (!RorW) SDA <= 1;//modo lectura, enviamos nosotros un ack
			Counter <= 0;
		end
	end
end
endmodule