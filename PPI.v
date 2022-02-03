`timescale 1ns / 1ps

 module ppi (PA,PB,PC,D,A,RD,WR,CS,reset);
 
	 inout  [7:0]PA; //8-bits of Port-A
	 inout  [7:0]PB; //8-bits of Port-B
	 inout  [7:0]PC; //8-bits of Port-C
	 inout  [7:0]D;  //8-bits of Data
	 input  [1:0] A; //2-bit for port selection
	 input  RD, // on low read  data from ports 
			  WR, // on low write data into ports 
			  CS, // on low processor selects this chip
			  reset; // all ports became in input state
 
      
	wire [3:0] PCu;
	wire [3:0] PCl;
	assign PC={PCu,PCl};
	
		reg [7:0]PAr;
		reg [7:0]PBr;
		reg [7:0]PCr; 
		reg [7:0]Dr;

		reg PAout,PBout,PCuout,PClout,Dout; //flags
 
		//conditioning inout 
 
	  assign PA =(PAout)?PAr:8'bzzzz_zzzz;
	  assign PB =(PBout)?PBr:8'bzzzz_zzzz;
	  assign PCu =(PCuout)?PCr[7:4]:4'bzzzz;
	  assign PCl =(PClout)?PCr[3:0]:4'bzzzz;
	  assign D = (Dout) ?Dr:8'bzzzz_zzzz;

 //on reset
 
	always@(reset)
 
	begin
		if(reset == 1)
		begin
			PAout=0;
			PBout=0;
			PCuout=0;
			PClout=0;
			Dout =0;
		end
	end 

//BSR mode 

	always@(CS or D)
	begin
		if(CS==1 && D[7]==1'b0 && reset==0 && A==2'b11)
		begin
			PCuout=1;
			PClout=1;
			if(D[0]==1'b1)
			begin
				PCr[D[3:1]] <= 1'b1;
			end 
			else if(D[0]==1'b0)
			begin	
				PCr[D[3:1]] <= 1'b0;
			end
		end 
	end  
  
   //mode 0
	

	always@(CS or PA or PB or PC or A or D)
  
	begin
   
		if(CS==1 && D[7]==1'b1 && reset==0 )
		begin 
		  //read mode
		  
		  if( RD==1 )
		  begin 
			
				if(A == 2'b00)
				begin
				  Dout<=1;
				  Dr<=PA;
				end 
				
				else if (A ==2'b01)
				begin 
				  Dout<=1;
				  Dr<=PB;		  
				end
				
				else if (A == 2'b10)
				begin
				  Dout<=1;
				  Dr<=PC;
				end
				else if(A ==2'b11 )
					begin
						Dout    <= 0;
						PAout   <= ~(D[4]);
						PBout   <= ~(D[1]);
						PCuout  <= ~(D[3]);
						PClout  <= ~(D[0]);	
					end

		  end
		
			else if ( WR==1)
				
				if(A == 2'b00)
				begin
				  Dout<=0;
				  PAr<=D;
				end 
				
				else if (A ==2'b01)
				begin 
				  Dout<=0;
				  PBr<=D;		  
				end
				
				else if (A == 2'b10)
				begin
				  Dout<=0;
				  PCr<=D;
				end
				
				else if(A ==2'b11)
					begin
						Dout    <= 0;
						PAout   <= ~(D[4]);
						PBout   <= ~(D[1]);
						PCuout  <= ~(D[3]);
						PClout  <= ~(D[0]);	
					end
		  end
		end 
 endmodule
 
module TB(
    );

wire [7:0] PA,PB,PC,D;
reg [7:0] PAr,PBr,PCr,Dr;

reg reset,CS,RD,WR;
reg [1:0] A;

reg PAout;
reg PBout;
reg PCout;
reg  Dout;
assign PA = (~PAout)?PAr:8'bzzzzzzzz;
assign PB = (~PBout)?PBr:8'bzzzzzzzz;
assign PC = (~PCout)?PCr:8'bzzzzzzzz;
assign D  = (~Dout) ? Dr:8'bzzzzzzzz;

initial
begin
#5
$display("|    port A    |    port B    |    port C    |    port D    |  A |RD|WR|reset|CS |");
$monitor("| %b | %b | %b | %b| %b |%b|%b|   %b   | %b |",PA,PB,PC,D,A,RD,WR,reset,CS);
//reset
PAout=0;
PBout=0;
PCout=0;
Dout=0;

CS = 1'b1;
reset = 1;
#10
reset = 0;

//BSR mode 
A = 3;

PCout=1;

Dr = 8'b00001011;
#10

//mode 0 writing on ports 

PAout=1;
PBout=1;
PCout=1;
Dout=0;

A=3;
Dr= 8'b10000000;
RD = 1'b0;
WR = 1'b1;
#10
A=0;
Dr = 8'b11110000;
#10
A=1;
Dr = 8'b11001100;
#10
A=2;
Dr = 8'b10001010;
#10

//mode 0 reading from ports 
WR = 1'b0;
RD = 1'b1;
PAout = 0;
PBout = 0;
PCout = 0;
Dout  = 0;

A=3;
Dr  = 8'b1001_1011;
PAr = 8'b1100_0011;
PBr = 8'b0011_1100;
PCr = 8'b1010_1010;
#10

A = 0;
Dout=1;
#10
A = 1;
#10
A = 2;

end
ppi ppi1(PA,PB,PC,D,A,RD,WR,CS,reset);

endmodule
