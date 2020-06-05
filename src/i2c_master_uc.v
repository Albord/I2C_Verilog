/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_MASTER_UC



*/

module I2C_MASTER_UC #( parameter ADDRESSLENGTH)(CLK, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave);
	input CLK;
	input RST;
	input Start;
	output SDA;
	output SCL;
	input RorW;
	input [ADDRESSLENGTH - 1:0] Slave_Address;
	input wire [3:0] NBytes = 4'b0000; //número de bytes que va haber en cada transferencia
	output [7:0]DataToSlave;
	output [7:0]DataFromSlave;

	reg state [3:0]
	reg nextstate [3:0]
	localparam [3:0] // 8 states are required for Moore
    		SendStop = 3'b000;
		Idle = 3'b001,
		SendStart = 3'b010,
		SendDirection = 3'b011,
		ReciveACK = 3'b100,
		SendData = 3'b101,
		ReciveData = 3'b110,
		SendACK = 3'b111;
		




	
assign SCL = ( state > SendStart ) ? SCL : 1'b1;


always @(posedge SDA) begin //Condición de stop
	if (SCL) state <= 1'b0;
end


always @(RST, Counter, Start, state, ACK)
begin
    if (!RST) state = SendStop;
   case (state)
	SendStop:
		nextstate = Idle;
	Idle:
		if (Start) nextstate = SendStart;
	SendStart:
		nextstate = SendDirection;
	SendDirection:
		if (Counter == ADDRESSLENGTH) nextstate = SendAck;
	ReciveACK:
		if (ACK || BytesCounter == NBYTES) nextstate = SendStop;
		else if (RorW) nextstate = SendData;
		else nextstate = SendData;
	SendData:
		if (Counter == 8) nextstate = ReciveACK;

	ReciveData:
		if (Counter == 8) nextstate = SendAck;
	SendACK:
		if (BytesCounter == NBYTES) nextstate = SendStop;
		else nextstate = ReciveData;
	default:
endcase



always @(posedge CLK) begin
	
	case (state)

		SendStart:
			SDA <= 0;
			Counter <= 0;
		ACKStatus
			Counter <= 0;
			ACK <= SDA; 
		default :



always @(negedge CLK) begin
	
	case (state)


		SendDirection: 
			SDA <= Slave_Address[Counter];
			Counter <= Counter + 1;
		SendRorW:
			SDA <= RorW;
		default:


end

endmodule
