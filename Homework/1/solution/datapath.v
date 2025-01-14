`timescale 1ns/1ns

module data_path(
	clk,
	rst,
	RegDst,
	Jmp,
	DataC,
	RegWrite,
	AluSrc,
	Branch,
	MemRead,
	MemWrite,
	MemtoReg,
	AluOperation,
	func,
	opcode,
	out1,
	out2
	);

	input 					clk,rst;
	input       [1:0]		RegDst,Jmp;
	input 					DataC,RegWrite,AluSrc,Branch,MemRead,MemWrite,MemtoReg;
	input       [2:0]		AluOperation;
	output reg  [5:0] 		func,opcode;
	output wire [31:0] 		out1,out2;

	wire        [31:0] 		in_pc,out_pc,instruction,write_data_reg,read_data1_reg,read_data2_reg,pc_adder,mem_read_data,
							inst_extended,alu_input2,alu_result,read_data_mem,shifted_inst_extended,out_adder2,out_branch;
	wire 		[4:0] 		write_reg;
	wire 		[25:0] 		shl2_inst;
	wire 					and_z_b,zero;
	wire [31:0] shifted_imm;
	// IF/ID Pipeline Registers
    	reg [31:0] IF_ID_PC;
    	reg [31:0] IF_ID_Instruction;

    	// ID/EX Pipeline Registers
    	reg [31:0] ID_EX_PC;
    	reg [31:0] ID_EX_RegValue1, ID_EX_RegValue2;
    	reg [4:0]  ID_EX_RegDst;
    	// EX/MEM Pipeline Registers
    	reg [31:0] EX_MEM_ALUResult;
    	reg [31:0] EX_MEM_WriteData;
    	reg [4:0]  EX_MEM_RegDst;
	// MEM/WB Pipeline Registers
  	reg [31:0] MEM_WB_ReadData;
        reg [31:0] MEM_WB_ALUResult;
    	reg [4:0]  MEM_WB_RegDst;
	
	// ID Stage Logic
	always @(posedge clk) begin
    	if (!rst) begin
        // Decode the instruction
        ID_EX_Opcode <= IF_ID_Instruction[31:26];
        ID_EX_Func <= IF_ID_Instruction[5:0];
        ID_EX_RegRs <= IF_ID_Instruction[25:21];
        ID_EX_RegRt <= IF_ID_Instruction[20:16];
        ID_EX_RegRd <= IF_ID_Instruction[15:11];
        ID_EX_Immediate <= IF_ID_Instruction[15:0];

        // Read data from the register file
        RegFile Read(
            .read_reg1(ID_EX_RegRs),
            .read_reg2(ID_EX_RegRt),
            .read_data1(ID_EX_RegValue1),
            .read_data2(ID_EX_RegValue2),
        );

        
    	end
	end
	// EX Stage Logic
	always @(posedge clk) begin
  	if (!rst) begin
        // Perform ALU operations
        ALU Execute(
            .data1(ID_EX_RegValue1),
            .data2(ID_EX_RegValue2),
            .alu_op(/* decoded from ID_EX_Opcode and ID_EX_Func */),
            .alu_result(EX_MEM_ALUResult),
            
        );
        end
	end

   	always @(posedge clk) begin
        if (rst) begin
            in_pc <= 32'b0;
            IF_ID_PC <= 32'b0;
            IF_ID_Instruction <= 32'b0;
        end else begin
            // Fetch the instruction and update in_pc
            IF_ID_Instruction <= instruction; // Store fetched instruction
            IF_ID_PC <= in_pc;

            
            in_pc <= in_pc + 4;
        end
   	end
	// MEM Stage Logic
	always @(posedge clk) begin
    	if (!rst) begin
        // Access memory if needed
        data_memory MemAccess(
            .mem_read(/* control signal */),
            .mem_write(/* control signal */),
            .adr(EX_MEM_ALUResult),
            .write_data(EX_MEM_WriteData),
            .read_data(MEM_WB_ReadData),
            
        );
        MEM_WB_ALUResult <= EX_MEM_ALUResult;
    	end
	end
	// WB Stage Logic
	always @(posedge clk) begin
    		if (!rst) begin
        // Write back results to the register file
        	if (write_data_reg) begin
            RegFile Write(
                .write_reg(write_reg),
                .write_data(/* data to write, from ALU or memory */),
            );
        end
        end
	end


	pc PC(.clk(clk),.rst(rst),.in(in_pc),.out(out_pc));

	adder adder_of_pc(.clk(clk),.data1(out_pc),.data2(32'd4),.sum(pc_adder));

	adder adder2(.clk(clk), .data1(shifted_imm << 2), .data2(pc_adder), .sum(out_adder2));

	alu ALU(.clk(clk),.data1(read_data1_reg),.data2(alu_input2),.alu_op(AluOperation),.alu_result(alu_result),.zero_flag(zero));

	inst_memory InstMem(.clk(clk),.rst(rst),.adr(out_pc),.instruction(instruction));

	reg_file RegFile(.clk(clk),.rst(rst),.RegWrite(RegWrite),.read_reg1(instruction[25:21]),.read_reg2(instruction[20:16]),
					 .write_reg(write_reg),.write_data(write_data_reg),.read_data1(read_data1_reg),.read_data2(read_data2_reg));

	data_memory data_mem(.clk(clk),.rst(rst),.mem_read(MemRead),.mem_write(MemWrite),.adr(alu_result),
						 .write_data(read_data2_reg),.read_data(read_data_mem),.out1(out1),.out2(out2)); 

	mux3_to_1 #5 mux3_reg_file(.clk(clk),.data1(instruction[20:16]),.data2(instruction[15:11]),.data3(5'd31),.sel(RegDst),.out(write_reg));

	mux3_to_1 #32 mux3_jmp(.clk(clk), .data1(out_branch), .data2({pc_adder[31:28], instruction[25:0] << 2}), .data3(read_data1_reg), .sel(Jmp), .out(in_pc));


	assign and_z_b=zero & Branch;

	mux2_to_1 #32 mux2_reg_file(.clk(clk),.data1(mem_read_data),.data2(pc_adder),.sel(DataC),.out(write_data_reg));

	sign_extension sign_ext(.clk(clk), .primary(instruction[15:0]), .extended(inst_extended));
    	shl2 #32 shl2_of_imm(.clk(clk), .adr(inst_extended), .sh_adr(shifted_imm));  


	mux2_to_1 #32 alu_mux(.clk(clk), .data1(read_data2_reg), .data2(inst_extended), .sel(AluSrc), .out(alu_input2));

	mux2_to_1 #32 mux_of_mem(.clk(clk),.data1(alu_result),.data2(read_data_mem),.sel(MemtoReg),.out(mem_read_data));

	mux2_to_1 #32 mux2_branch(.clk(clk),.data1(pc_adder),.data2(out_adder2),.sel(and_z_b),.out(out_branch));

	shl2 #26 shl2_1(.clk(clk),.adr(instruction[25:0]),.sh_adr(shl2_inst));

	shl2 #32 shl2_of_adder2(.clk(clk),.adr(inst_extended),.sh_adr(shifted_inst_extended));

	assign func=instruction[5:0];

	assign opcode=instruction[31:26];

endmodule
