`timescale 1 ns / 1 ns
//test para comprobar el correcto funcionamiento tanto del maestro como del esclavo

// Retard entre el flanc de rellotge i la comprovacio
`define DELAY 5


module testbench();

//Parametros
parameter ADDRESSLENGTH = 8;//ADDRESSLENGTH ES EL TAMA�O DE LA DIRECCI�N DEL ESCLAV
parameter ADDRESSNUM = 1;//ADDRESSNUM, EL N�MERO DE DIRECCI�NES QUE POSEE EL ESCLAVO, EST� FIJADA A
parameter NBYTES = 2;//NBYTES ES EL N�MERO DE BYTES QUE CONTIENE LA MEMORIA DEL ESCLAVO POR DIRECCI�
	

//Se�ales del maestro y del esclavo
wire SDA;//Pin de datos entre el maestro y los esclavos
wire SCL;//Pin de reloj entre el maestro y el esclavo
pullup (SDA); //COLOCAMOS EL PULLUP AL SDA Y AL SCL PARA QUE EN CASO DE QUE NADIE UTILICE EL PIN, EST� POR DEFECTO EN 1
pullup (SCL); 


//Inputs outputs que vamos a analizar del maestro
reg Clk = 1'b0;//Reloj externo, con este reloj se generar� el Scl
wire [3:0]MasterState;//Estado de la FSM del maestro
reg [7:0]DataToSlave;//Datos que van a ser enviados al slave
wire [7:0]DataFromSlave;//Datos que han sido enviados por el slave
wire [3:0] NBytes = 4'b0010; //n�mero de bytes que va haber en cada transferencia, en este caso 2
reg Start = 1'b0;//Condici�n para permitir la transferencia de datos del maestro
reg Rst = 1'b1;//Reset activo con estado bajo
reg RorW = 1'b0;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir
reg [ADDRESSLENGTH - 1:0] SlaveAddress;//Direcci�n de memoria con la que el maestro se va a comunicar


//Inputs outputs del esclavo
wire AddressFound;//BANDERA DE LA MEMORIA PARA INDICAR QUE DISPONE DE LA DIRECCI�N SOLICITADA POR EL MAESTRO
wire [ADDRESSLENGTH-1: 0] AddressBuffer;//Buffer para guardar la direcci�n que el maestro est� solicitando
wire [7:0]OutputBuffer;//Buffer para guardar el byte que vamos a enviar al maestro con esta transferencia
wire [7:0]InputBuffer;//Buffer para guardar el byte que est� transfiriendo el esclavo
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList = 8'b10101010;//Direcci�n del dispositivo esclavo
wire [8*NBYTES*ADDRESSNUM - 1: 0 ] SlaveMemoryData;//Memoria del esclavo donde ir�n todos los datos guardados
wire SlaveState;//Estado del esclavo
wire SlaveEnable;//Bandera indicando que el esclavo est� activo(No tiene porque estar transfiriendo datos)


//Llamamos a los modulos de maestro y esclavo
I2C_SLAVE#( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave(SDA, SCL, AddressList, AddressBuffer, InputBuffer, OutputBuffer, SlaveState, SlaveEnable, SlaveMemoryData, AddressFound);
I2C_MASTER#( ADDRESSLENGTH) master(Clk, Rst, Start, SDA, SCL, RorW, SlaveAddress, NBytes, DataToSlave, DataFromSlave, MasterState);

initial begin
$display("PRIMERA PARTE DEL TEST");
Rst = 1'b0;//Hacemos un reset inicial
SlaveAddress = 8'b10101011;//Solicitamos una transferenica con un esclavo que no existe
Start = 1'b0; //Todav�a no vamos a empezar la transferencia de datos
waitClk;//Esperamos un reloj
Rst = 1'b1;//Desactivamos el reset
repeat (2) waitClk; //Esperamos dos relojes para ver si el maestro o el esclavo est�n funcioando
SystemStartCheck; //Como no se ha indicado un start, maestro y esclavo tienen que estar inoperativos
waitClk;//Esperamos un reloj, y procedemos a activar el start
Start = 1'b1;
waitStartBit;//Esperamos a que el maestro produzca un startbit
SystemStartCheck;//Comprobamos si el maestro y el esclavo se han iniciado correctamente
repeat (10) waitClk;//Esperamos los ciclos necesarios para que el maestro env�e la solictud de transferencia de datos
AddressCheck;//Comprovamos si el esclavo tiene la direcci�n y si est� realizando la acci�n correcta
NackCheck;//Como el esclavo no tiene la direcci�n solicitada, no se produce un ack


$display("SEGUNDA PARTE DEL TEST");
SlaveAddress = 8'b10101010;//Solicitamos una nueva transferencia con el la direcci�n del esclavo correcto
RorW = 1'b1;//Ponemos la transferencia en modo env�o de datos al esclavo
//Ahora vamos a enviar 2 bytes 
DataToSlave = 8'b11110000; //este es el primer byte a enviar
repeat (13) waitClk;//Volvemos a esperar los ciclos necesarios para que transferir la direcci�n por el sda
AddressCheck;//Comprobamos que la direcci�n coincide
AckCheck;//Como coinicide la direcci�n tiene que haber un ack
repeat (9) waitClk;//Esperamos los ciclos necesarios para enviar el byte
DataToSlave = 8'b10101010; //ya se ha enviado todo el byte y podemos poner en el buffer el siguiente byte a enviar
AckCheck;//Comprobamos que se ha recibido otro ack
repeat (9) waitClk;
AckCheck;
SlaveDataCheck; //Comprobamos que los datos de la memoria del esclavo son 8'b11110000 + 8'b10101010 es decir los dos bytes enviados
waitStopBit;//Esperamos a que el maestro haga un stop bit
waitStartBit;//Esperamos a que el maestro haga un start bit para otra transferencia
RorW = 1'b0;//Ahora vamos a recibir los datos que habiamos enviado al esclavo, es decir los dos bytes

$display("TERCERA PARTE DEL TEST");
repeat (10) waitClk;
AddressCheck;
AckCheck;
repeat (9) waitClk;//Durante estos ciclos de reloj, el esclavo va a enviar cada bit del primer byte
MasterDataCheck1;//Comprobamos si el byte recibido es 8'b11110000 
repeat (9) waitClk;
MasterDataCheck2;//Comprobamos si el byte recibido es 8'b10101010 
waitStopBit;//La transferencia ha finalizado esperamos el stop bit
Start = 1'b0; //Indicamos que no vamos a realizar m�s transferencias al maestro
repeat (3) waitClk; //Esperamos unos ciclos para comprobar que ni el maestro ni el esclavo est�n operativos
SystemStartCheck;//Por �ltimo comprobamos que tanto el maestro como el esclavo est�n desactivados

$stop;

end
initial begin //Generamos el reloj
	Clk = 0;
end
always #10 Clk = ~Clk;

task waitClk; begin//Esperamos al flanco de subida para hacer un delay y sincronizar el test
        @(posedge Clk);
        #`DELAY;
    end //begin
endtask

task SystemStartCheck; //Comprobamos que el maestro y el esclavo est�n desactivados o activos
begin
	if (!Start) begin //En el caso de que no se haya dado la orden de arrancar
		if (MasterState != 0) $display("Error: El maestro no est� en el estado de espera.");
		if (SlaveEnable != 0) $display("Error: El eslavo est� en funcionamiento.");
		else $display("Correcto: Los dispositivos est�n todos desactivados ya que no se ha dado la orden de start.");
	end
	else begin //Si se ha dado la orden de start comprobamos si los dos dispositivos est�n en funcionamiento
		if (MasterState == 0) $display("Error: El maestro est� en estado de espera.");
		if (SlaveEnable == 0) $display("Error: El eslavo est� inoperativo.");
		else $display("Correcto: Tanto el maestro como el esclavo han aceptado la orden de start.");
	end
end
endtask

task AddressCheck;//Comprobamos si el esclavo tiene la direcci�n de memoria solicitada
	begin
		if (AddressBuffer == AddressList[7:0]) begin
			if (AddressFound) $display("Correcto: El eslavo ha encontrado la direcci�n correctamente");
			else $display("Error: El eslavo a�n teniendo la direcci�n, no la ha encontrado.");
		end
		else if (AddressFound) $display("Error: El eslavo ha indicado que tiene la direcci�n, pero no la tiene");
		else $display("Correcto: El esclavo, no tiene la direcci�n y por lo tanto no ha indicado al maestro que la tiene");

	end
endtask

task waitStartBit; begin //Funci�n que espera hasta que se produzca un startbit
//Si es un env�o de datos normal, es decir al blanco negativo del reloj, da error 
        @(negedge SDA);
	if(Clk) $display("Correcto: Se ha producido el startbit");
	else $display("Error: No se ha producido el startbit");
        #`DELAY;
	end
endtask
task waitStopBit; begin//Funci�n para detectar el stopbit, similar al startbit
        @(posedge SDA);
	if(Clk) $display("Correcto: Se ha producido el stopbit");
	else $display("Error: No se ha producido el stopbit");
        #`DELAY;
	end
endtask


task AckCheck; begin//Funci�n para comprobar que el sda est� a 0 y por lo tanto es un ack
	if (!SDA) $display("Correcto: Se ha transmitido un ack");
	else $display("Error: No hay ack");
	end
endtask
task NackCheck; begin//Funci�n inversa del ackcheck
	if (SDA) $display("Correcto: Se ha transmitido un nack");
	else $display("Error: Hay un ack inesperado");
	end
endtask

task SlaveDataCheck; begin//Funci�n para comprar los datos de la memoria del esclavo con los que tendr�a que tener
	if (SlaveMemoryData[15:0] == 16'b1010101011110000) $display("Correcto: Se ha guardado en el slave los datos correctos.");
	else $display("Error: Los datos guardados en el slave est�n incorrectos.");
	end
endtask


task MasterDataCheck1;begin//Funci�n para comprar el primer byte recibido del esclavo con el esperado
	if (DataFromSlave == 8'b11110000) $display("Correcto: El primer byte es correcto");
	else $display("Error: El primer byte es erroneo");
end
endtask
task MasterDataCheck2;begin
	if (DataFromSlave == 8'b10101010) $display("Correcto: El segundo byte es correcto");
	else $display("Error: El segundo byte es erroneo");
end
endtask


endmodule

