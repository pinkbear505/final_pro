`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/17 11:50:37
// Design Name: 
// Module Name: Mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Mem#(
	parameter N_LEDs = 16,       // Number of LEDs displaying Result. LED(15 downto 15-N_LEDs+1). 16 by default
	parameter N_DIPs = 7         // Number of DIPs. 16 by default	                             
)( 
input CLK,
input RESET,
input [N_DIPs-1:0]DIP,
input [31:0]mem_req_addr,
input mem_req_rw,
input mem_req_valid,
input [31:0] mem_data_write,
output reg [31:0]mem_data_read,
output reg mem_ready,
output [31:0]ReadData_IO
//output Instr_Mem,
//output Data_Mem

    );
    //reg [31:0] INSTR_MEM		[0:127]; // instruction memory
    reg [31:0] DATA_CONST_MEM    [0:127]; // data (constant) memory
    reg [31:0] DATA_VAR_MEM     [0:127]; // data (variable) memory
    integer i;
//    //----------------------------------------------------------------
//    // Instruction Memory
//    //----------------------------------------------------------------
//    initial begin
//                INSTR_MEM[0] = 32'hE59F120C; 
//                INSTR_MEM[1] = 32'hE59F2200; 
//                INSTR_MEM[2] = 32'hE59F3200; 
//                INSTR_MEM[3] = 32'hE59FB208; 
//                INSTR_MEM[4] = 32'hE59FC200; 
//                INSTR_MEM[5] = 32'hE0080291; 
//                INSTR_MEM[6] = 32'hE0815002; 
//                INSTR_MEM[7] = 32'hE0090293; 
//                INSTR_MEM[8] = 32'hE0816002; 
//                INSTR_MEM[9] = 32'hE0817002; 
//                INSTR_MEM[10] = 32'hE0814002; 
//                INSTR_MEM[11] = 32'hE081A002; 
//                for(i = 12; i < 128; i = i+1) begin 
//                    INSTR_MEM[i] = 32'h0; 
//                end
//    end
    
    //----------------------------------------------------------------
    // Data (Constant) Memory
    //----------------------------------------------------------------
    initial begin
                DATA_CONST_MEM[0] = 32'h00000810; 
                DATA_CONST_MEM[1] = 32'h00000820; 
                DATA_CONST_MEM[2] = 32'h00000830; 
                DATA_CONST_MEM[3] = 32'h00000005; 
                DATA_CONST_MEM[4] = 32'h00000006; 
                DATA_CONST_MEM[5] = 32'h00000003; 
                DATA_CONST_MEM[6] = 32'hFFFFFFFF; 
                for(i = 7; i < 128; i = i+1) begin 
                    DATA_CONST_MEM[i] = 32'h0; 
                end
    end
    //----------------------------------------------------------------
    // Data (Variable) Memory
    //----------------------------------------------------------------
    initial begin
                for(i = 0; i < 128; i = i+1) begin 
                    DATA_VAR_MEM[i] = 32'h0; 
                end
    end

wire dec_DATA_CONST, dec_DATA_VAR, dec_INSTR_MEM;  // 'enable' signals from data memory address decoding
assign dec_DATA_CONST		= (mem_req_addr >= 32'h00000200 && mem_req_addr <= 32'h000003FC) ? 1'b1 : 1'b0;
assign dec_DATA_VAR			= (mem_req_addr >= 32'h00000800 && mem_req_addr <= 32'h000009FC) ? 1'b1 : 1'b0;
//assign dec_INSTR_MEM        = ((mem_req_addr >= 32'h00000000) && (mem_req_addr <= 32'h000001FC)) ? 1'b1 : 1'b0;

//assign Instr_Mem=dec_INSTR_MEM;
//assign Data_Mem=dec_DATA_CONST || dec_DATA_VAR;

    always @(posedge CLK, posedge RESET) begin
        if(RESET)
            mem_ready=1'b0;
        else if(mem_req_valid && mem_req_rw==1'b1 &&!mem_ready)   //write in the data var mem
        begin
            DATA_VAR_MEM[mem_req_addr[8:2]] = mem_data_write;
            mem_ready = 1'b1;
        end
        else if (mem_req_valid&&!mem_req_rw&&!mem_ready)   //read the mem(instr,constant data,var data)
        begin
            if (dec_DATA_VAR)
            begin
                mem_data_read = DATA_VAR_MEM[mem_req_addr[8:2]] ;
                mem_ready=1'b1;
            end 
            else if (dec_DATA_CONST)
            begin
                mem_data_read = DATA_CONST_MEM[mem_req_addr[8:2]] ;
                mem_ready=1'b1;
            end
//            else if(dec_INSTR_MEM)
//            begin
//                mem_data_read <= INSTR_MEM[mem_req_addr[8:2]];
//                mem_ready=1'b1;
//            end      
            else
            begin
                mem_data_read = 32'h0 ; 
                mem_ready=1'b1;
            end
        end
        else if(mem_req_valid&&mem_ready)begin
            mem_ready=1'b0;
        end
    end

assign ReadData_IO = DATA_VAR_MEM[DIP[6:0]];

    
endmodule
