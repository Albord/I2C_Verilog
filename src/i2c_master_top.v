/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_MASTER
	Modulo maestro de la implementación i2c
	Se le puede especificar como parametro el tamaño de la dirección del slave

*/

module I2C_MASTER #( parameter ADDRESSLENGTH)(Clk, Rst, Start, Sda, Scl, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave, State);
	input Clk;//Reloj externo, con este reloj se generará el Scl
	input Rst;//Reset activo con estado bajo
	input Start;//Variable para iniciar la solicitud de una nueva transferencia
	inout wire Sda;//Pin de datos entre el maestro y los esclavos
	output wire Scl;//Pin de reloj entre el maestro y el esclavo
	input RorW;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir
	input wire [ADDRESSLENGTH - 1:0] Slave_Address;//Input de la dirección del esclavo con el que nos queremos comunicar
	input wire [3:0] NBytes; //Número de bytes que va haber en cada transferencia
	reg [3:0] Bytescounter = 4'b0000;//Contador con los bytes que llevamos en la transferencia que se está realizando
	input wire [7:0]DataToSlave;//Datos que van a ser enviados al slave
	output reg [7:0]DataFromSlave;//Datos que han sido enviador por el slave
	output reg [3:0]State;//Estado en el cual la FSM se encuentra
	reg [3:0]nextstate;//Estado futuro que se actualizará en el flanco de subida del reloj
	integer counter = 0;//Contador para registrar cuandos bits se han enviado o recibido
	reg sda_intern = 1'b1;//para que no haya conflictos con el sda tenemos un sda interno
	localparam [3:0] // estados definidos por la máquina
    		IDLE = 3'b000,//Estado por defecto, modo ausente
		SENDSTOP = 3'b001,//estado para enviar un bit de stop
		SENDSTART = 3'b010,//estado para enviar el bit de start
		SENDDIRECTION = 3'b011,//estado para enviar la dirección del slave con el que nos vamos a comunicar
		GETACK = 3'b100,//Estado para recibir la confirmación del slave
		SENDDATA = 3'b101,//Estado para enviar datos al slave
		GETDATA = 3'b110,//Estado para recibir datos del slave
		SENDACK = 3'b111;//Estado para enviar ack al slave
		
	
assign Scl = ( State == IDLE ) ? 1'b1 : Clk;//Si el estado es ausente, no hace falta generar el SCL
assign Sda = ( sda_intern ) ? 1'bz : 1'b0;//Si sda es 0 asignamos el valor, si no, no modifcamos el valor del sda


always @(posedge Sda) begin //Condición de stop flanco de subida del sda y scl positivo
	if (Scl) State <= 3'b000;
end


always @(Rst, counter, Start, State, Sda)//Always para calcular el siguiente estado
begin
    
   case (State)
	IDLE:
		if (Start) nextstate = SENDSTART;//si el start está en alto, podemos comenzar e enviar el start bit
	SENDSTOP:
		nextstate = IDLE; //enviamos el stop bit y ya podemos pasar al estado de espera
	SENDSTART:
		nextstate = SENDDIRECTION;//al darle a start podemos pasar al estado de envío de la dirección
	SENDDIRECTION:
		if (counter == ADDRESSLENGTH) nextstate = GETACK;//si se ha enviado todos los datos podemos mirar si ha llegado el ack
	GETACK: begin
		if (Sda || (Bytescounter == NBytes)) nextstate = SENDSTOP;//si ya se ha enviado todos los bytes o no hay ack podemos parar 		
		else if (RorW) nextstate = SENDDATA;//si estamos en el modo de enviar datos, al recibir ack podemos enviar los 8 bits
		else nextstate = GETDATA;//si no pasamos a recibir datos
	end
	SENDDATA:
		if (counter == 7) nextstate = GETACK;//Si se han enviado los 8 bits pasamos a buscar el ack

	GETDATA:
		if (counter == 7) nextstate = SENDACK;
	SENDACK: begin
		if (Bytescounter == NBytes) nextstate = SENDSTOP;//lo mismo que el estado getack, pero como no cambiaremos de 
		else nextstate = GETDATA;//read a write en una transferencia, no hace falta poner esa condición
	end
	endcase
	if (!Rst) nextstate = SENDSTOP;//Si el rst está en bajo, el siguiente estado será el de parar en cualquier caso

end


always @(posedge Clk) begin//Acciones vamos a realizar en el flanco de subida del reloj
//El flanco de subida es utilizado para capturar el estado de sda enviado por los slaves
	case (State)
		IDLE: begin
			counter <= 0;
			sda_intern <= 1;//en este caso sería similar a la condición de stop para asegurarnos de que ningún slave trabaje
			Bytescounter <= 4'b0000;
		end
		SENDSTOP: begin
			counter <= 0;
			sda_intern <= 1;//condición de stop
			Bytescounter <= 4'b0000;
		end
		SENDSTART: begin
			counter <= 0;
			sda_intern <= 0;//al ponerlo a 0 cuando el reloj está en alto, cumplimos la condición de start
			Bytescounter <= 4'b0000;
		end
		SENDDIRECTION: begin
			counter <= counter + 1;//autoincrementamos el contador
			Bytescounter <= 4'b0000;
		end
		GETACK: begin
			counter <= 0;//al pasar cada vez por este estado incrementamos el contador de bytes en 1
			Bytescounter <= Bytescounter + 1;//aunque se podría hacer con el counter, pero sería más complejo
		end
		SENDDATA: begin
			counter <= counter + 1;
			Bytescounter <= Bytescounter;
		end
		GETDATA: begin
			DataFromSlave[counter] <= Sda;//recibimos los datos
			counter <= counter + 1;//incrementamos el contador en 1 para guardar el proóximo dato en la siguiente posició
			Bytescounter <= 4'b0000;
		end
		SENDACK: begin
			counter <= 0;
			sda_intern <= 1;
			Bytescounter <= Bytescounter + 1;
		end


	endcase
	State <= nextstate;//actualizamos el estado de la máquina
end
always @(negedge Clk) begin//En el flanco de subida enviamos los datos normales del sda
	sda_intern <= 1;
	case (State)
		SENDSTOP:
			sda_intern <= 0;//ponemos el sda a 0 para asegurarnos un flanco de subida al realizar el stopbit
		SENDDIRECTION://si el contador no ha llegado al tamaño de la dirección enviamos la dirección
			if (counter < ADDRESSLENGTH) sda_intern <= Slave_Address[counter];
			else sda_intern <= RorW;//si no, el bit para indicar si enviamos o recibimos datos
		SENDDATA:
			sda_intern <= DataToSlave[counter];//enviamos los datos al slave
		SENDACK:
			sda_intern <= 0;//enviamos un ack que es un estado bajo del sda, si no sería un nack
		
	endcase

end

endmodule
