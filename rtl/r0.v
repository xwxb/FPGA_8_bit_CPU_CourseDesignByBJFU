/*r0通用寄存器*/
module r0(din, clk, rst, r0load, dout);

	input clk,rst,r0load;
	input [7:0] din;
	output [7:0] dout;

	reg [7:0] dout;
	
	always@(posedge clk or negedge rst)
		if(!rst)
			dout<=0;
		else
			if(r0load)
				dout<=din;

endmodule
