/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_MASTER



*/

module I2C_MASTER #( parameter ADDRESSLENGTH)(CLK, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave, state);
	input CLK;
	input RST;
	input Start;
	inout wire SDA;
	output wire SCL;
	input RorW;
	input wire [ADDRESSLENGTH - 1:0] Slave_Address;
	input wire [3:0] NBytes; //número de bytes que va haber en cada transferencia
	reg [3:0] BytesCounter = 4'b0000;
	input wire [7:0]DataToSlave;
	output reg [7:0]DataFromSlave;
	output reg [3:0]state;
	reg [3:0]nextstate;
	integer Counter = 0;
	reg sda_intern = 1'b1;
	localparam [3:0] // 8 states are required for Moore
    		Idle = 3'b000,
		SendStart = 3'b001,
		SendDirection = 3'b010,
		SendRorW = 3'b011,
		ReciveACK = 3'b100,
		SendData = 3'b101,
		ReciveData = 3'b110,
		SendACK = 3'b111;
		
	
assign SCL = ( state > SendStart ) ? CLK : 1'b1;
assign SDA = ( sda_intern ) ? 1'bz : 1'b0;


always @(posedge SDA) begin //Condición de stop
	if (SCL) state <= 3'b000;
end


always @(RST, Counter, Start, state, SDA)
begin
    
   case (state)
	Idle:
		if (Start) nextstate = SendStart;
	SendStart:
		nextstate = SendDirection;
	SendDirection:
		if (Counter == ADDRESSLENGTH - 1) nextstate = SendRorW;
	SendRorW:
		nextstate = ReciveACK;
	ReciveACK: begin
		if (SDA || (BytesCounter == NBytes)) nextstate = Idle;
		else if (RorW) nextstate = SendData;
		else nextstate = SendData;
	end
	SendData:
		if (Counter == 7) nextstate = ReciveACK;

	ReciveData:
		if (Counter == 7) nextstate = SendACK;
	SendACK: begin
		if (BytesCounter == NBytes) nextstate = Idle;
		else nextstate = ReciveData;
	end
	endcase
	if (!RST) nextstate = Idle;

end


always @(posedge CLK) begin
	case (state)
		Idle: begin
			Counter <= 0;
			sda_intern <= 1;
		end
		SendStart: begin
			Counter <= 0;
			sda_intern <= 0;
		end
		SendDirection: begin
			Counter <= Counter + 1;
		end
		SendRorW: begin
			Counter <= 0;
		end
		ReciveACK: begin
			Counter <= 0;
		end
		SendData: begin
			Counter <= Counter + 1;
		end
		ReciveData: begin
			DataFromSlave[Counter] <= SDA;
			Counter <= Counter + 1;
		end
		SendACK: begin
			Counter <= 0;
			sda_intern <= 1;
		end


	endcase
	state <= nextstate;
end
always @(negedge CLK) begin
	case (state)
		SendDirection:
			sda_intern <= Slave_Address[Counter];
		SendRorW:
			sda_intern <= RorW;
		SendData:
			sda_intern <= DataToSlave[Counter];
		SendACK:
			sda_intern <= 0;
		
	endcase

end

endmodule
