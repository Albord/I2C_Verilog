/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_MASTER



*/

module I2C_MASTER #( parameter ADDRESSLENGTH)(CLK, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave);
	input CLK;
	input RST;
	input Start;
	output reg SDA;
	output wire SCL;
	input RorW;
	input wire [ADDRESSLENGTH - 1:0] Slave_Address;
	input wire [3:0] NBytes; //número de bytes que va haber en cada transferencia
	reg [3:0] BytesCounter = 4'b0000;
	input wire [7:0]DataToSlave;
	output reg [7:0]DataFromSlave;
	reg ACK;
	reg [3:0]state;
	reg [3:0]nextstate;
	integer Counter = 0;
	localparam [3:0] // 8 states are required for Moore
    		Idle = 3'b000,
		SendStart = 3'b001,
		SendDirection = 3'b010,
		SendRorW = 3'b011,
		ReciveACK = 3'b100,
		SendData = 3'b101,
		ReciveData = 3'b110,
		SendACK = 3'b111;
		
	
assign SCL = ( state > SendStart ) ? SCL : 1'b1;


always @(posedge SDA) begin //Condición de stop
	if (SCL) state <= 3'b0;
end


always @(RST, Counter, Start, state, ACK)
begin
    if (!RST) state = Idle;
   case (state)
	Idle:
		if (Start) nextstate = SendStart;
	SendStart:
		nextstate = SendDirection;
	SendDirection:
		if (Counter == ADDRESSLENGTH) nextstate = SendRorW;
	SendRorW:
		nextstate = ReciveACK;
	ReciveACK: begin
		if (ACK || BytesCounter == NBytes -1) nextstate = Idle;
		else if (RorW) nextstate = SendData;
		else nextstate = SendData;
	end
	SendData:
		if (Counter == 8) nextstate = ReciveACK;

	ReciveData:
		if (Counter == 8) nextstate = SendACK;
	SendACK: begin
		if (BytesCounter == NBytes -1) nextstate = Idle;
		else nextstate = ReciveData;
	end

endcase
end


always @(posedge CLK) begin
	
	case (state)
		Idle: begin
			Counter <= 0;
			SDA <= 1;
		end
		SendStart: begin
			Counter <= 0;
			SDA <= 0;
		end
		SendDirection:
			Counter <= Counter + 1;
		SendRorW:
			Counter <= 0;
		ReciveACK: begin
			Counter <= 0;
			ACK <= SDA; 
		end
		SendData:
			Counter <= Counter + 1;
		ReciveData: begin
			DataFromSlave[Counter] <= SDA;
			Counter <= Counter + 1;
		end
		SendACK:
			Counter <= 0;
		


	endcase
	state <= nextstate;
end
always @(negedge CLK) begin
	
	case (state)
		SendDirection:
			SDA <= Slave_Address[Counter];
		SendRorW:
			SDA <= RorW;
		SendData:
			SDA <= DataToSlave[Counter];
		SendACK:
			SDA <= 0;
	endcase

end

endmodule
