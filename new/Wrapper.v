`timescale 1ns / 1ps
//>>>>>>>>>>>> ******* FOR SIMULATION. DO NOT SYNTHESIZE THIS DIRECTLY (This is used as a component in TOP.v for Synthesis) ******* <<<<<<<<<<<<

module Wrapper
#(
	parameter N_LEDs = 16,       // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs+1). 16 by default
	parameter N_DIPs = 7         // Number of DIPs. 16 by default	                             
)
(
	input  [N_DIPs-1:0] DIP, 		 		// DIP switch inputs, used as a user definied memory address for checking memory content.
	output reg [N_LEDs-1:0] LED, 	// LED light display. Display the value of program counter.
	output reg [31:0] SEVENSEGHEX, 			// 7 Seg LED Display. The 32-bit value will appear as 8 Hex digits on the display. Used to display memory content.
	input  RESET,							// Active high.
	input  CLK								// Divided Clock from TOP.
);                                             



//----------------------------------------------------------------
// ARM signals
//----------------------------------------------------------------
wire[31:0] PC ;
wire[31:0] Instr ;
reg [31:0] Instr1;
assign Instr=Instr1;
reg[31:0] ReadData ;
wire MemWriteM ;
wire[31:0] ALUResult ;
wire[31:0] WriteData ;
wire stall;
wire op;
//----------------------------------------------------------------
// cache signals
//----------------------------------------------------------------
wire cpu_req_valid;
wire cpu_req_rw;
assign cpu_req_rw=MemWriteM;
wire [31:0] cpu_data_read;
reg [31:0] cpu_data_read1;
assign cpu_data_read=cpu_data_read1;
wire cpu_ready;

wire [31:0] cpu_req_addr;
assign cpu_req_addr=ALUResult;
wire [31:0] cpu_data_write;
assign cpu_data_write=WriteData;

//----------------------------------------------------------------
// mem signals
//----------------------------------------------------------------
wire [31:0] mem_req_addr;
wire mem_req_rw;
wire mem_req_valid;
wire [31:0] mem_data_write;
wire [31:0]mem_data_read;
wire mem_ready; 
wire Instr_Mem;
wire Data_Mem;
////----------------------------------------------------------------
//// Address Decode signals
////---------------------------------------------------------------
//wire dec_DATA_CONST, dec_DATA_VAR;  // 'enable' signals from data memory address decoding

//----------------------------------------------------------------
// Memory read for IO signals
//----------------------------------------------------------------
wire [31:0] ReadData_IO;

////----------------------------------------------------------------
//// Memory declaration
////-----------------------------------------------------------------
//reg [31:0] INSTR_MEM		[0:127]; // instruction memory
//reg [31:0] DATA_CONST_MEM	[0:127]; // data (constant) memory
//reg [31:0] DATA_VAR_MEM     [0:127]; // data (variable) memory
//integer i;


////----------------------------------------------------------------
//// Instruction Memory
////----------------------------------------------------------------
//initial begin
//			INSTR_MEM[0] = 32'hE59F120C; 
//			INSTR_MEM[1] = 32'hE59F2200; 
//			INSTR_MEM[2] = 32'hE59F3200; 
//			INSTR_MEM[3] = 32'hE59FB208; 
//			INSTR_MEM[4] = 32'hE59FC200; 
//			INSTR_MEM[5] = 32'hE0080291; 
//			INSTR_MEM[6] = 32'hE0815002; 
//			INSTR_MEM[7] = 32'hE0090293; 
//			INSTR_MEM[8] = 32'hE0816002; 
//			INSTR_MEM[9] = 32'hE0817002; 
//			INSTR_MEM[10] = 32'hE0814002; 
//			INSTR_MEM[11] = 32'hE081A002; 
//			for(i = 12; i < 128; i = i+1) begin 
//				INSTR_MEM[i] = 32'h0; 
//			end
//end

////----------------------------------------------------------------
//// Data (Constant) Memory
////----------------------------------------------------------------
//initial begin
//			DATA_CONST_MEM[0] = 32'h00000810; 
//			DATA_CONST_MEM[1] = 32'h00000820; 
//			DATA_CONST_MEM[2] = 32'h00000830; 
//			DATA_CONST_MEM[3] = 32'h00000005; 
//			DATA_CONST_MEM[4] = 32'h00000006; 
//			DATA_CONST_MEM[5] = 32'h00000003; 
//			DATA_CONST_MEM[6] = 32'hFFFFFFFF; 
//			for(i = 7; i < 128; i = i+1) begin 
//				DATA_CONST_MEM[i] = 32'h0; 
//			end
//end



////----------------------------------------------------------------
//// Data (Variable) Memory
////----------------------------------------------------------------
//initial begin
//            for(i = 0; i < 128; i = i+1) begin 
//				DATA_VAR_MEM[i] = 32'h0; 
//			end
//end


//----------------------------------------------------------------
// ARM port map
//----------------------------------------------------------------
ARM ARM1(
	CLK,
	RESET,
	Instr,
	ReadData,
	MemWriteM,
	PC,
	ALUResult,
	WriteData,
	cpu_req_valid
);

////----------------------------------------------------------------
//// Data memory address decoding
////----------------------------------------------------------------
//assign dec_DATA_CONST		= (ALUResult >= 32'h00000200 && ALUResult <= 32'h000003FC) ? 1'b1 : 1'b0;
//assign dec_DATA_VAR			= (ALUResult >= 32'h00000800 && ALUResult <= 32'h000009FC) ? 1'b1 : 1'b0;
////0010_0000_0000--0011_1111_1100 CONST_MEM
////1000_0000_0000--1001_1111_1100 VAR_MEM

////----------------------------------------------------------------
//// Data memory read 1
////----------------------------------------------------------------
//always@( * ) begin
//if (dec_DATA_VAR)
//	ReadData <= DATA_VAR_MEM[ALUResult[8:2]] ; 
//else if (dec_DATA_CONST)
//	ReadData <= DATA_CONST_MEM[ALUResult[8:2]] ; 	
//else
//	ReadData <= 32'h0 ; 
//end

////----------------------------------------------------------------
//// Data memory read 2
////----------------------------------------------------------------
//assign ReadData_IO = DATA_VAR_MEM[DIP[6:0]];

////----------------------------------------------------------------
//// Data Memory write
////----------------------------------------------------------------
//always@(posedge CLK) begin
//    if( MemWrite && dec_DATA_VAR ) 
//        DATA_VAR_MEM[ALUResult[8:2]] <= WriteData ;
//end

////----------------------------------------------------------------
//// Instruction memory read
////----------------------------------------------------------------
//assign Instr = ( (PC >= 32'h00000000) && (PC <= 32'h000001FC) ) ? // To check if address is in the valid range, assuming 128 word memory. Also helps minimize warnings
//                 INSTR_MEM[PC[8:2]] : 32'h00000000 ; 
////0000_0000_0000--0001_1111_1100 instr


//----------------------------------------------------------------
// LED light - display PC value
//----------------------------------------------------------------
always@(posedge CLK or posedge RESET) begin
    if(RESET)
        LED <= 'b0 ;
    else 
        LED <= PC ;
end

//----------------------------------------------------------------
// SevenSeg LED - display memory content
//----------------------------------------------------------------
always @(posedge CLK or posedge RESET) begin
	if (RESET)
		SEVENSEGHEX <= 32'b0;
	else
		SEVENSEGHEX <= ReadData_IO;
end



//----------------------------------------------------------------
// associative cache
//----------------------------------------------------------------



always @(*) begin
    if(Instr_Mem)
        Instr1=cpu_data_read1;
    else if(Data_Mem)
        ReadData=cpu_data_read1;
    else 
        Instr1=Instr1;
        ReadData=ReadData; 

end

associative_cache associative_cache1(
	CLK,
	RESET,
    //between CPU and cache
    PC,
    cpu_req_addr, //ALUResult, PC
    cpu_req_valid,
    cpu_req_rw,
    cpu_data_write, //store instruction, WriteData
    cpu_data_read, //three conditions, INSTR, DATA_VAR, DATA_CONST
    cpu_ready,
    
    //between cache and mem
    mem_req_addr, //addr mem achieve
    mem_req_rw, //request to writeback to the mem
    mem_req_valid, //request to access the mem
    mem_data_write, //the data need to be writebacked to the mem
    mem_data_read, //the read data from mem
    mem_ready //mem done the work, i.e. mem aviliable when mem_ready=0
);


//----------------------------------------------------------------
// mem module
//----------------------------------------------------------------

Mem Mem1 (
    CLK,
    RESET,
    DIP,
    mem_req_addr,
    mem_req_rw,
    mem_req_valid,
    mem_data_write,
    mem_data_read,
    ReadData_IO,
    mem_ready,
    Instr_Mem,
    Data_Mem
);


endmodule
