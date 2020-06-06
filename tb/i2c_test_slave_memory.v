`timescale 1 ns / 1 ns


module testslavememory();

parameter ADDRESSLENGTH = 8;
parameter ADDRESSNUM = 1;
parameter NBYTES = 2;


reg Enable = 1'b0;
reg Mode = 1'b0;
reg RorW = 1'b0;
wire[4:0] LocalAddressID;
reg [ADDRESSLENGTH-1: 0] DirectionBuffer = 1'b0;
wire AddressFound;
wire[8*NBYTES*ADDRESSNUM - 1: 0 ]Data;
wire [7:0]OutputBuffer;
reg [7:0]InputBuffer = 8'b00110011;
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList = 8'b01010101;


I2C_SLAVE_MEMORY #( ADDRESSLENGTH, ADDRESSNUM, NBYTES) i2c_slave_memory(Enable, RorW, DirectionBuffer, InputBuffer, OutputBuffer, AddressFound, AddressList, LocalAddressID);





//Prueba de la memoria
initial begin
#10; //Comprovamos que no disponemos de esta dirección y la bandera no se pone en alto
DirectionBuffer = 8'b00101111;//Dirección incorrecta
Mode = 1'b1;
Enable = 1'b0;
#10
Mode = 1'b1;
#10;
Mode = 1'b0;
#10
Enable = 1'b1;
#10
DirectionBuffer = 8'b11111111;//Dirección correcta
Enable = 1'b0;
#10;
Enable = 1'b1;
#10;
Enable = 1'b0;
#10;//Comprovamos el modulo de escritura
Mode = 1'b1;
InputBuffer = 8'b01010101;
RorW = 1'b1;
#10;
Enable = 1'b1;//Escribimos
#10;
Enable = 1'b0;//Vamos a añadir otro dato en la memoria
InputBuffer = 8'b11110101;
#10;
Enable = 1'b1;
#10;
Enable = 1'b0; //pasamos al modo lectura, vamos a leer los dos datos guardados
Mode = 1'b0;
#10 //Por seguridad, hay que mirar si disponemos de la dirección otra vez, además es lo que haría naturalmente el slave
Enable = 1'b1;
#10
Enable = 1'b0;//Procedemos a leer los datos guardados, el primer dato tiene que ser el 01010101 y el segundo 11110101
Mode = 1'b1;
RorW = 1'b0;
#10
Enable = 1'b1;
#10
Enable = 1'b0;
#10
Enable = 1'b1;
#10
Mode = 1'b1;
end




endmodule



