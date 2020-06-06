/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_SLAVE_ADDRESS_MATCH

Modulo para comprovar si el slave tiene la dirección de memoría la cual solicita el master.
El modulo dispone de dos funciones seleccionables con la variable modo. La primera es comprovar si el dispositivo
tiene esa dirección de memoria como hemos mencionado anteriormente o si queremos añadir una nueva dirección de memoria.
Para ello habrá la posibilidad de tener diferentes direcciones de memoria, las cuales no tienen porque ser consecutivas
y debido a que habrá un tamaño fijado de direcciones, se procederá a actuar como LIFO.No obstante el añadir memorias será recomendable
hacerlo al inicio del programa como una configuración previa.

*/

module I2C_SLAVE_ADDRESS_MATCH #( parameter LENGTH, parameter MaxAddress)(Clk, Rst, Enable, Mode, InputAddress, AddressFound);
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
		if (Mode) AddressFound = 1'b0; //Falta añadir cosas
	end
end

endmodule