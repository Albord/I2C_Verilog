/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_SLAVE_ADDRESS_UC



*/

module I2C_SLAVE_ADDRESS_UC #( parameter LENGTH, parameter MaxAddress)(SDA, SCL,
	output reg Start = 1'b0;
	output reg MasterAddress;
	reg Counter = 1'b0;
always @(posedge SDA) begin
	if (!SCL) begin //Condición de start
		Counter = 1'b0;
		Start <= 1'b1;
	end
end
always @(posedge SCL) begin
	if (Start) begin
		I2C_SHIFT_REGISTER #( LENGTH)(SCL, SDA, Buffer);
		if (Start == LENGTH) Start = 1'b0;
		else Counter = Counter + 1;
	end
end
always @(Counter) begin
	if (Counter ==  7) begin//Procedemos a mirar la dirección

	end


	
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
		if (Mode) AddressFound = 1'b0; //Falta añadir cosas
		else AddressFound = 1'b0; //Falta añadir cosas
	end
end
*/

endmodule