/*标志寄存器*/
module z(din, clk, rst, zload, dout);

	input[7:0] din;
	input clk,rst,zload;
	output dout;

	reg dout;
	
	always@(posedge clk or negedge rst)
		if(!rst)
			dout<=0;
		else
			if(zload)
				begin
					if(din==8'b00000000)
						dout<=4'd1;
					else
						dout<=4'd0;
				end

endmodule 