`timescale 1 ns / 1 ns


module testbench();


parameter ADDRESSLENGTH = 8;//ADDRESSLENGTH ES EL TAMAÑO DE LA DIRECCIÓN DEL ESCLAV
parameter ADDRESSNUM = 1;//ADDRESSNUM, EL NÚMERO DE DIRECCIÓNES QUE POSEE EL ESCLAVO, ESTÁ FIJADA A
parameter NBYTES = 2;//NBYTES ES EL NÚMERO DE BYTES QUE CONTIENE LA MEMORIA DEL ESCLAVO POR DIRECCIÓ
	
reg Start = 1'b0;//Variable para iniciar la solicitud de una nueva transferencia
reg Clk = 1'b0;//Reloj externo, con este reloj se generará el Scl
reg RST = 1'b1;//Reset activo con estado bajo
wire SDA;//Pin de datos entre el maestro y los esclavos
wire SCL;//Pin de reloj entre el maestro y el esclavo
reg RorW = 1'b0;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir
wire [ADDRESSLENGTH-1: 0] DirectionBuffer;
wire AddressFound = 1'b0;
wire [3:0]state;//Estado en el cual la FSM del master se encuentra
wire [7:0]OutputBuffer;
wire [7:0]InputBuffer;
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList = 8'b10101010;//Dirección de nuestro esclavo
wire [ADDRESSLENGTH - 1:0] Slave_Address = 8'b10101010;//Direcció nque vamos a solicitar a los esclavos
wire [3:0] NBytes = 4'b0010; //número de bytes que va haber en cada transferencia
wire [7:0]DataToSlave = 8'b00110011;//Datos que van a ser enviados al slave
wire [7:0]DataFromSlave;//Datos que han sido enviados por el slave
wire [8*NBYTES*ADDRESSNUM - 1: 0 ] Data;//Memoria del esclavo donde irán todos los datos guardados
wire slave_state;//Estado del esclavo
wire start;//Registro para activar la comunicación etre la memoria y la unidad de control

pullup (SDA); //COLOCAMOS EL PULLUP AL SDA Y AL SCL PARA QUE EN CASO DE QUE NADIE UTILICE EL PIN, ESTÉ POR DEFECTO EN 1
pullup (SCL); 



//Si desmarcamos el eslave, podemos testear el caso de que no encuentra el esclavo con la dirección correct o bien cambiando la dirección
I2C_SLAVE#( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave(SDA, SCL, AddressList, DirectionBuffer, InputBuffer, OutputBuffer, slave_state, start, Data);

I2C_MASTER#( ADDRESSLENGTH) master(Clk, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave, state);

initial begin
#20;
RST = 1'b0;//Hacemos un reset inicial
RorW = 1'b1;//Ponemos la transferencia en modo envío de datos al esclavo
#20;
RST = 1'b1;//Desactivamos el reset puede operar con normalidad
#10;
Start = 1'b1;//Indicamos al maestro que puead empezar con la transferencia de datos
#1000;//Esperamos un tiempo para ver como se desarrolla 
//Hacemos un test de lectura
#20;
RST = 1'b0;//Hacemos el mismo procedimiento anterior
#20
RorW = 1'b0;
#20;
RST = 1'b1;
#1000;
$stop;

end
initial begin //Generamos el reloj
	Clk = 0;
end
always #10 Clk = ~Clk;


endmodule

