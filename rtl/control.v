/*组合逻辑控制单元，根据时钟生成为控制信号和内部信号*/
/*
输入：
       din：指令，8位，来自IR；
       clk：时钟信号，1位，上升沿有效；
       rst：复位信号，1位，与cpustate共同组成reset信号；
       cpustate：当前CPU的状态（IN，CHECK，RUN），2位；
       z：零标志，1位，零标志寄存器的输出，如果指令中涉及到z，可加上，否则可去掉；
输出：
      clr：清零控制信号
     自行设计的各个控制信号
*/

//省略号中是自行设计的控制信号，需要自行补充，没用到z的话去掉z

module control(din,clk,rst,z,cpustate,read,write,
membus,busmem,pcbus,drlbus,drhbus,trbus,r1bus,r0bus,
arload,pcload,drload,irload,trload,r1load,r0load,xload,zload,
alus,pcinc,arinc,
clr);

//输入端口说明
input [7:0] din;
input clk;
input rst,z;
input [1:0] cpustate;

//输出端口说明
output reg[3:0] alus;
output arload,arinc,pcload,pcinc,pcbus,drload,drhbus,drlbus,irload,r0load,r0bus,
		 trload,trbus,r1bus,r1load,read,write,membus,busmem,xload,zload,clr;



//parameter's define

wire reset;

//在下方加上自行定义的状态
wire fetch1,fetch2,fetch3;

wire nop1,add1,add2,inc1,inc2,sub1,sub2,
	  and1,and2,or1,or2,xor1,xor2,dec1,dec2, 
	  shr1,shr2,not1,not2,clr1,clr2,mvr1;
wire lad1,lad2,lad3,lad4,lad5;
wire jmp1,jmp2,jmp3;
wire jmpz1,jmpz2,jmpz3;




//加上自行设计的指令，这里是译码器的输出，所以nop指令经译码器输出后为inop。
//类似地，add指令指令经译码器输出后为iadd；inc指令经译码器输出后为iinc，......
reg inop;

reg iadd,isub,iand,ior,ixor,iinc,idec,iclr,ishr,inot,imvr,ilad,ijmp,ijmpz; //在always中赋值

//时钟节拍，8个为一个指令周期，t0-t2分别对应fetch1-fetch3，t3-t7分别对应各指令的执行周期，当然不是所有指令都需要5个节拍的。例如add指令只需要2个节拍：t3和t4
reg t0,t1,t2,t3,t4,t5,t6,t7; //时钟节拍，8个为一个cpu周期

// 内部信号：clr清零，inc自增
wire clr;
wire inc;

assign reset = rst & (cpustate == 2'b11);//?
// assign signals for the cunter

//clr信号是每条指令执行完毕后必做的清零，下面clr赋值语句要修改，需要“或”各指令的最后一个周期
assign clr=nop1||add2||sub2||dec2||and2||or2||xor2||not2||clr2||inc2||shr2||jmp3||jmpz3||mvr1||lad5; 

assign inc=~clr;

//generate the control signal using state information
//取公过程-取指
assign fetch1=t0;
assign fetch2=t1;
assign fetch3=t2;

//什么都不做的译码
assign nop1=inop && t3;//inop表示nop指令，nop1是nop指令的执行周期的第一个状态也是最后一个状态，因为只需要1个节拍t3完成

//加法
assign add1 = iadd&&t3, add2 = iadd&&t4;
//减法
assign sub1 = isub&&t3, sub2 = isub&&t4;
//与
assign and1 = iand&&t3, and2 = iand&&t4;
//或
assign or1  = ior&&t3, or2 = ior&&t4;
//异或
assign xor1 = ixor&&t3, xor2 = ixor&&t4;
//自加
assign inc1 = iinc&&t3, inc2 = iinc&&t4;
//自减
assign dec1 = idec&&t3, dec2 = idec&&t4;
//清零
assign clr1 = iclr&&t3, clr2 = iclr&&t4;
//右移
assign shr1 = ishr&&t3, shr2 = ishr&&t4;
//取非
assign not1  = inot&&t3, not2 = inot&&t4;
//R0->R1
assign mvr1 = imvr&&t3;

//M[T]->R0
assign lad1 = ilad&&t3;
assign lad2 = ilad&&t4;
assign lad3 = ilad&&t5;
assign lad4 = ilad&&t6;
assign lad5 = ilad&&t7;
//GOTO T
assign jmp1 = ijmp&&t3;
assign jmp2 = ijmp&&t4;
assign jmp3 = ijmp&&t5;
//IF(Z==1) GOTO T
assign jmpz1 = ijmpz&&t3;
assign jmpz2 = ijmpz&&t4;
assign jmpz3 = ijmpz&&t5;
//以下写出各条指令状态的表达式

//以下给出了pcbus的逻辑表达式，写出其他控制信号的逻辑表达式
assign read = fetch2 || lad1 || lad2 || lad4 || jmp1 || jmp2 || (jmpz1&&z) || (jmpz2&&z);
assign membus = fetch2 || lad1 || lad2 || lad4 || jmp1 || jmp2 || (jmpz1&&z) || (jmpz2&&z);
assign arload = fetch1 || fetch3 || lad3;
assign arinc = lad1 || jmp1 || (jmpz1&z);

assign pcbus = fetch1 || fetch3;
assign pcload = jmp3 || (jmpz3&&z);
assign pcinc = fetch2 || lad1 || lad2;

assign drload = fetch2 || lad1 || lad2 || lad4 || jmp1 || jmp2 || (jmpz1&&z) || (jmpz2&&z);
assign drhbus = lad3 || jmp3 || (jmpz3&&z);
assign drlbus = lad5;

assign irload = fetch3;
assign trload = jmp2 || lad2 || (jmpz2&&z);
assign trbus = jmp3 || lad3 || (jmpz3&&z);

assign r1load = mvr1;
assign r1bus = add2 || sub2 || dec2 || and2 || or2 || xor2 || not2 || clr2;
assign r0load = shr2 || add2 || sub2 || dec2 || and2 || or2 || xor2 || not2 || clr2 || inc2 || lad5;
assign r0bus = shr1 || add1 || sub1 || dec1 || and1 || or1 || xor1 || not1 || clr1 || inc1 || mvr1;

assign xload = shr1 || add1 || sub1 || dec1 || and1 || or1 || xor1 || not1 || clr1 || inc1;
assign zload = add2 || sub2 || dec2 || and2 || or2 || xor2 || not2 || clr2 || inc2 || shr2 || lad5 || jmpz1 || jmpz2 || jmpz3;


//the finite state

always@(posedge clk or negedge reset)
	begin
		if(!reset)
			begin//各指令清零，以下已为nop指令清零，请补充其他指令，为其他指令清零
				inop<=0;
				iadd<=0;
				iinc<=0;
				imvr<=0;
				ilad<=0;
				ijmp<=0;
				isub<=0;
				iand<=0;
				ior<=0;	
				ixor<=0;	
				idec<=0;
				inot<=0;
				ishr<=0;
				ijmpz<=0;
				iclr<=0;		
				alus<= 4'd15;
			end
		else 
		begin
		
			//alus初始化为x，加上将alus初始化为x的语句，后续根据不同指令为alus赋值
		
			if(din[3:0]==0000)//译码处理过程
			begin
				case(din[7:4])
				4'd0: begin//指令高4位为0，应该是nop指令，因此这里inop的值是1，而其他指令应该清零，请补充为其他指令清零的语句
					inop<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;		
					alus<= 4'd15;
							
				end
				4'd1:  begin
					//指令高4位为0001，应该是add指令，因此iadd指令为1，其他指令都应该是0。
					//该指令需要做加法运算，详见《示例机的设计Quartus II和使用说明文档》中“ALU的设计”，因此这里要对alus赋值
					//后续各分支类似，只有一条指令为1，其他指令为0，以下分支都给出nop指令的赋值，需要补充其他指令，注意涉及到运算的都要对alus赋值
					
					//alus=？，需要为alus赋值inop<=0;
					inop<=0;
					alus<=4'd1;
					iadd<=1;
					
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd2:  begin
//				SUB
					inop<=0;
					alus<=4'd2;
					isub<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd3:  begin
//				AND
					inop<=0;
					alus<=4'd3;
					iand<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd4:  begin
//				OR
					inop<=0;
					alus<=4'd4;
					ior<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd5:  begin
//				XOR
					inop<=0;
					alus<=4'd5;
					ixor<=1;	
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd6:	begin
//				INC
					inop<=0;
					alus<=4'd6;
					iinc<=1;
					
					iadd<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd7:	begin
//				DEC
					inop<=0;
					alus<=4'd7;
					idec<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd8:	begin
//				SHR
					inop<=0;
					alus<=4'd8;
					ishr<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					iclr<=0;
				end
				4'd9:	begin
//				CLR
					inop<=0;
					alus<=4'd0;
					iclr<=1;
					
					iadd<=0;
					iinc<=0;
					imvr<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
				end
					//如果还有分支，可以继续写，如果没有分支了，写上defuault语句	
				4'd10:	begin
//				MVR
					inop<=0;
					imvr<=1;
					
					alus<=4'd15;
					iadd<=0;
					iinc<=0;
					ilad<=0;
					ijmp<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd11:	begin
//				JMP
					inop<=0;
					ijmp<=1;
					
					alus<=4'd15;
					imvr<=0;
					iadd<=0;
					iinc<=0;
					ilad<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				4'd12:	begin
//				JMPZ
					inop<=0;
					ijmpz<=1;
					
					alus<=4'd15;
					ijmp<=0;
					imvr<=0;
					iadd<=0;
					iinc<=0;
					ilad<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					iclr<=0;
				end
				4'd14:	begin
//				LAD
					inop<=0;
					alus<=4'd9;
					ilad<=1;
					
					ijmp<=0;
					imvr<=0;
					iadd<=0;
					iinc<=0;
					isub<=0;
					iand<=0;
					ior<=0;	
					ixor<=0;	
					idec<=0;
					inot<=0;
					ishr<=0;
					ijmpz<=0;
					iclr<=0;
				end
				default:;
				endcase
			end
		end
	end

	/*——————8个节拍t0-t7————*/
	always @(posedge clk or negedge reset)
	begin
		if(!reset) //reset清零
		begin
			t0<=1;
			t1<=0;
			t2<=0;
			t3<=0;
			t4<=0;
			t5<=0;
			t6<=0;
			t7<=0;
		end
		else
		begin
			if(inc) //运行
			begin
				t7<=t6;
				t6<=t5;
				t5<=t4;
				t4<=t3;
				t3<=t2;
				t2<=t1;
				t1<=t0;
				t0<=0;
		end
			else if(clr) //清零
			begin
				t0<=1;
				t1<=0;
				t2<=0;
				t3<=0;
				t4<=0;
				t5<=0;
				t6<=0;
				t7<=0;
			end
		end
	end

/*—————结束—————*/
endmodule
	
		