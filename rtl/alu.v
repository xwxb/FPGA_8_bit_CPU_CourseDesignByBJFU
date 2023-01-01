/*算术逻辑单元*/
module alu(alus, x, bus, dout);

	input wire[7:0] x, bus;
	input wire[3:0] alus;
	
	output reg[7:0] dout;

	always@(*)
		begin
			case(alus)
				4'b0000:dout=8'b00000000;
				4'b0001:dout=bus + x;
				4'b0010:dout=bus - x;
				4'b0011:dout=x & bus;
				4'b0100:dout=x | bus;
				4'b0101:dout=x^bus;
				4'b0110:dout=x + 8'b00000001;
				4'b0111:dout=x - 8'b00000001;
				4'b1000:dout=x >> 8'b00000001;
				4'b1001:dout=bus+8'b00000000;
				4'b1010:dout=~x + 1'b1;
				default:dout=8'b11111111;
			endcase
		end

endmodule
