/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_SLAVE_ADDRESS_UC



*/

module I2C_SLAVE_ADDRESS_UC #( parameter ADDRESSLENGTH, parameter MaxAddress)(SDA, SCL,
	output reg Start = 1'b0;
	output reg MasterAddress;
	integer Counter = 1'b0;//(Hay que hacer el counter de más bits)
	input reg HaveAddress;
	reg Buffer[LENGTH || 8 - 1: 0] = 1'b0; // Buffer donde irán todos los datos recibidos, tanto para buscar la dirección como datos a memória
	reg Status = 1'b0;//Estado 0 cuando el master está solicitando conexión. Estado 1, cuando hay transferencia
	reg RorW = 1'b0; //Estado 0 lectura, estado 1 escritura


	reg NexData = 1'b0;
always @(posedge SDA) begin
	if (!SCL) begin //Condición de start
		Counter <= 0;
		Start <= 1'b1;
		Status <= 1'b0;
		RorW <= 1'b0;
	end
end
always @(posedge SCL) begin
	if (Start) begin

		if (Status) begin
			if (Counter < 7) begin//las transferencias son de byte a byte, por lo tanto hay que tener el contador también
				//
				if (RorW) SDA <= NextData;//ponemos el siguiente dato para escribir
				else Buffer[Counter]; //guardamos el dato en el buffer
				Counter = Counter + 1;
			end
			if (Counter == 7) begin //fin del byte de datos, hay enviar o recibir un ack y de paso guardamos el buffer en la memoria
				if (!RorW) SDA <= 1;//modo lectura, enviamos nosotros un ack
				else (SDA)
				Counter = 0;
			end
		

		end



		else begin
			if (Counter < ADDRESSLENGTH) begin //Recibiendo los datos de la dirección de memoria
				Counter <= Counter + 1;
				I2C_SHIFT_REGISTER #( ADDRESSLENGTH)(SCL, SDA, Buffer);
			end
			
			else if (Counter == ADDRESSLENGTH) begin
				/*
				Si la dirección de memoria pertence a este slave
				Procedemos a seleccionar el modo de lectura o escritura segun el último bit recibido
				Ponemos el modo de transferencia y además enviamos un ack
				*/
				if (AddressFound) begin
					RorW <= SDA;
					Counter = 0;
					SDA <= 1;
					Status <= 1'b1;
				end
			end 
			else Start <= 0; //En caso de que la transferencia no sea con este dispositivo, lo desactivamos
		end
	end
end

always @(negedge SCL) begin
/*
	Enviamos la dirección de la memoria y en el modulo de memoría se comprovará
	Si esta dirección de memoria pertenence a este slave	
*/
	if (!Status && Counter ==  ADDRESSLENGTH) MasterAddress <= Buffer[ADDRESSLENGTH:0];
	if (!Status && RoW && Counter < 8) NextData; <= Buffer[Counter];

end


endmodule