module I2C_SHIFT_REGISTER #( parameter LENGTH)(Clk, Rst, Enable, Buffer, InputBit, OutputBit);
	
	input Clk;
 	input Rst; 
	input Enable; 
	input InputBit;
	output reg [LENGTH - 1: 0]Buffer;
	output reg OutputBit;
always @(posedge Clk)
begin
    	if (!Rst) Buffer = 1'b0;
  	else if (Enable) begin
		OutputBit <= Buffer[LENGTH - 1: LENGTH - 2];
		Buffer <= {Buffer[LENGTH - 1: LENGTH - 2], InputBit};
	end
end

endmodule
