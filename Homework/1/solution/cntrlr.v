`define RT 6'b000000
`define addi 6'b001000
`define add 6'b100000
`define addu 6'b100001
`define sub  6'b100010  
`define sub 6'b100011  
`define slt  6'b101010
`define and 6'b100100  
`define or  6'b100101  
`define xor 6'b100110  
`define nor 6'b100111
`define sll  6'b000000
`define srl  6'b000010
`define sla  6'b000011  
`define sllv 6'b000100
`define srlv 6'b000110
`define srav 6'b000111
`define j    6'b000010
`define jal  6'b000011
`define jalr 6'b001001
`define jr 6'b001000
`define addiu 6'b001001
`define slti  6'b001010
`define sltiu 6'b001011
`define andi  6'b001100
`define ori   6'b001101
`define xori  6'b001110
`define lui   6'b001111
`define lw    6'b100011
`define sw    6'b101011
`define beq   6'b000100
`define bne   6'b000101



module controller(
	clk,
	rst,
	opcode,
	func,
	RegDst,
	Jmp,
	DataC,
	Regwrite,
	AluSrc,
	Branch,
	MemRead,
	MemWrite,
	MemtoReg,
	AluOperation
	);
	input 				clk,rst;
	input      [5:0] 	opcode,func;
	output reg [1:0]	RegDst,Jmp;
	output reg		    DataC,Regwrite,AluSrc,Branch,MemRead,MemWrite,MemtoReg;
	output reg [2:0]    AluOperation;

	always@(opcode,func) begin
		    {RegDst,Jmp,DataC,Regwrite,AluSrc,Branch,MemRead,MemWrite,MemtoReg,AluOperation}=0;
			case(opcode) 
				`RT: begin
					RegDst=2'b01;
					Regwrite=1;
					AluOperation=func[2:0];
				 end
				 `add: begin
				        RegDst = 2'b01;    
 				        Regwrite = 1;      
				        AluSrc = 0;        
  				        AluOperation = 3'b010; 
   				 end

				`addi: begin
					Regwrite=1;
					AluSrc=1;
					AluOperation=3'b010;
				 end
				`addu: begin
        				RegDst = 2'b01;    
  				        Regwrite = 1;      
        				AluSrc = 0;        
        				AluOperation = 3'b010; 
    				end
				`sub, `subu: begin
  				        RegDst = 2'b01;    
        				Regwrite = 1;      
        				AluSrc = 0;        
				        AluOperation = 3'b011; 
    				end
				`slt: begin
    				        RegDst = 2'b01;    
        				Regwrite = 1;      
     				   	AluSrc = 0;        
        				AluOperation = 3'b100; 
    				end
				`and: begin
        				RegDst = 2'b01;    
        				Regwrite = 1;      
        				AluSrc = 0;        
        				AluOperation = 3'b000; 
    				end
    				`or: begin
        				RegDst = 2'b01;    
        				Regwrite = 1;      
        				AluSrc = 0;   
        				AluOperation = 3'b001;
    				end
    				`xor: begin
        				RegDst = 2'b01;    
        				Regwrite = 1;      
        				AluSrc = 0;
        				AluOperation = 3'b010;
    				end
    				`nor: begin
        				RegDst = 2'b01;    
        				Regwrite = 1;      
        				AluSrc = 0;
        				AluOperation = 3'b011;
    				end
				`sll, `srl, `sla: begin
        				RegDst = 2'b01;
				        Regwrite = 1;
        				AluSrc = 1;  
        				AluOperation = func; 
    				end
    				`sllv, `srlv, `srav: begin
        				RegDst = 2'b01;
				        Regwrite = 1;
        				AluSrc = 0;  
        				AluOperation = func; 
    				end
   				`jr: begin
        				
        				Jmp = 2'b10; 
    				end
    				`jalr: begin
				        RegDst = 2'b10;
				        Regwrite = 1;
				        Jmp = 2'b10; 
				        
			        `endsll,`srl, `sla: begin
	        			RegDst = 2'b01;
	        			Regwrite = 1;
        				AluSrc = 1;  
        				AluOperation = func; 
    				end
				 `addiu: begin
				        Regwrite = 1;
        				AluSrc = 1;
        				AluOperation = 3'b010; 
    				end
    				`slti: begin
        				Regwrite = 1;
        				AluSrc = 1;
       					AluOperation = 3'b100; 
    				end
    				`sltiu: begin
				        Regwrite = 1;
        				AluSrc = 1;
        				AluOperation = 3'b101;  
    				end
    				`andi: begin
				        Regwrite = 1;
  					AluSrc = 1;
        				AluOperation = 3'b110;  
    				end
    				`ori: begin
				        Regwrite = 1;
        				AluSrc = 1;
        				AluOperation = 3'b111;  
    				end
    				`xori: begin
				        Regwrite = 1;
        				AluSrc = 1;
        				AluOperation = 3'b001;  
    				end
    				`lui: begin
				        Regwrite = 1;
        				
    				end
    				`lw: begin
				        Regwrite = 1;
        				MemRead = 1;
				        MemtoReg = 1;
				        AluSrc = 1;
				        AluOperation = 3'b010;  
				        end
    				`sw: begin
				        MemWrite = 1;
        				AluSrc = 1;
        				AluOperation = 3'b010;  
    				end
    				`beq: begin
        				Branch = 1;
        				AluOperation = 3'b011;  
    				end
    				`bne: begin
        				Branch = 1;
        				AluOperation = 3'b011;  
    				end
				`j: begin
				        Jmp = 2'b01; 
    				end
    				`jal: begin
        				Jmp = 2'b01;
        				Regwrite = 1; 
        				RegDst = 2'b10; 
        				DataC = 1; 
    				end
				`jr: begin
					Jmp=2'b10;
				 end
			endcase
	end
endmodule
