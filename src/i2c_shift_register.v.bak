module I2C_SHIFT_REGISTER #( parameter LENGTH)(Clk, InputBit, Buffer);
	
	input Clk;
	input Enable; 
	input InputBit;
	output reg [LENGTH - 1: 0]Buffer;
	//output reg OutputBit;

    	//if (!Rst) Buffer = 1'b0; En este caso no necesitamos un reset

		//OutputBit <= Buffer[LENGTH - 1: LENGTH - 2]; 
	Buffer = {Buffer[LENGTH - 1: LENGTH - 2], InputBit};
	

endmodule
