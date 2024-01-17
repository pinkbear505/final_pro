`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/15 17:16:40
// Design Name: 
// Module Name: associative_cache
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


module associative_cache(
input CLK,
input RESET,
//between CPU and cache
input [31:0]PC,
input [31:0]cpu_req_addr, //ALUResult
input cpu_req_valid,
input cpu_req_rw,
input [31:0]cpu_data_write, //store instruction, WriteData
output [31:0]cpu_data_read, // INSTR_MEM[PC[8:2]]
output cpu_ready,
output Cache_Stall,

//between cache and mem
output  [31:0]mem_req_addr, //addr mem achieve
output  mem_req_rw, //request to writeback to the mem
output  mem_req_valid, //request to access the mem
output  [31:0]mem_data_write, //the data need to be writebacked to the mem
input [31:0]mem_data_read, //the read data from mem
input mem_ready //mem done the work, i.e. mem aviliable when mem_ready=0
    );
    reg [31:0]cpu_data_read1; // INSTR_MEM[PC[8:2]]
    reg cpu_ready1;
    assign cpu_data_read=cpu_data_read1;
    assign cpu_ready=cpu_ready1;
    
    reg  [31:0]mem_req_addr1; //addr mem achieve
    reg  mem_req_rw1; //request to writeback to the mem
    reg  mem_req_valid1; //request to access the mem
    reg  [31:0]mem_data_write1; //the data need to be writebacked to the mem
    assign mem_req_addr=mem_req_addr1;
    assign mem_req_rw=mem_req_rw1;
    assign mem_req_valid=mem_req_valid1;
    assign mem_data_write=mem_data_write1;
    
    reg [55:0] cache_data [0:1023];
    
    reg [1:0] state,next_state;
    parameter IDLE=0;
    parameter CompareTag=1;
    parameter Allocate=2;
    parameter WriteBack=3;
    reg hit;
    reg hit1,hit2,hit3,hit4;
    reg way;
    
    wire [1:0] offset;
    wire [7:0] index;
    wire [21:0] tag;
    parameter V=55;
    parameter D=54;
    parameter TagMSB=53;
    parameter TagLSB=32;
    parameter BlockMSB=31;
    parameter BlockLSB=0;
    
    assign offset=cpu_req_addr[1:0];
    assign index=cpu_req_addr[9:2];
    assign tag=cpu_req_addr[31:10];
    
    integer i;
     //initialize cache
     initial begin
        for(i=0;i<1023;i=i+1) cache_data[i]=56'd0; 
     end 
    
    always @(posedge CLK or posedge RESET) begin 
        if (RESET)
            state<=IDLE;
        else begin
            state<=next_state;
        end    
    end
    
    reg Cache_Stall1;
    assign Cache_Stall=Cache_Stall1;
    always @(*) begin
        if (RESET)
            Cache_Stall1=1'b0;
        else if (state==IDLE)
            Cache_Stall1=1'b1;
        else 
            Cache_Stall1=1'b0;
    end
    
    //state machine
    always @(*) begin
        case (state)
            IDLE:if(cpu_req_valid)
                    next_state=CompareTag;
                  else
                    next_state=IDLE;
            CompareTag:if(hit) 
                            next_state=IDLE;
                        else if (cache_data[24*index+way][V:D]==2'b11) //the block is valid and dirty, however miss, writeback needed 
                            next_state=WriteBack;
                        else
                            next_state=Allocate; //miss but no need to write back, i.e. not valid or not dirty; start to fetch data or write data in the cache
            Allocate:if(mem_ready)
                        next_state=CompareTag;
                     else
                        next_state=Allocate;
            WriteBack:if(mem_ready)
                        next_state=Allocate;
                      else 
                        next_state=WriteBack; 
            default:next_state=IDLE;
        endcase
    end
    
    
    //hit in the first way; hit1
    always @(*) begin
        if(state==CompareTag)
            if(cache_data[4*index][V]&&cache_data[4*index][TagMSB:TagLSB]==tag)
                hit1=1;
            else 
                hit1=0;
    end
    //hit in the second way; hit2
    always @(*) begin
        if(state==CompareTag)
            if(cache_data[4*index+1][V]&&cache_data[4*index+1][TagMSB:TagLSB]==tag)
                hit2=1;
            else 
                hit2=0;
    end    
    //hit in the third way; hit3
    always @(*) begin
        if(state==CompareTag)
            if(cache_data[4*index+2][V]&&cache_data[4*index+2][TagMSB:TagLSB]==tag)
                hit3=1;
            else 
                hit3=0;
    end   
    //hit in the fourth way; hit4
    always @(*) begin
        if(state==CompareTag)
            if(cache_data[4*index+3][V]&&cache_data[4*index+3][TagMSB:TagLSB]==tag)
                hit4=1;
            else 
                hit4=0;
    end    
    
    //hit
    always @(*) begin
        if (state==CompareTag)
            hit=hit1||hit2||hit3||hit4;
        else
            hit=0;
    end
    
    
   //way, the location of the target block when cache miss 
    always @(*) begin
        if ((state==CompareTag)&&(!hit))
            case({cache_data[4*index][V],cache_data[4*index+1][V],cache_data[4*index+2][V],cache_data[4*index+3][V]})
                4'b0000:way=2'd0;
                4'b0001:way=2'd0;
                4'b0010:way=2'd0;
                4'b0011:way=2'd0;
                4'b0100:way=2'd0;
                4'b0101:way=2'd0;
                4'b0110:way=2'd0;
                4'b0111:way=2'd0;
                4'b1000:way=2'd1;
                4'b1001:way=2'd1;
                4'b1010:way=2'd1;
                4'b1011:way=2'd1;
                4'b1100:way=2'd2;
                4'b1101:way=2'd2;
                4'b1110:way=2'd3;
                4'b1111:way=2'd0;
                default:way=2'd0;
            endcase
    end
    
    //compare tag
    always @(posedge CLK) begin
        if (state==CompareTag&&hit)
            if(cpu_req_rw==1'b0) //red hit
            begin
                cpu_ready1<=1'b1;
                if(hit1)
                    cpu_data_read1<=cache_data[4*index][32*offset+:32]; //offset is byte offset, should be 0 cause data is transfered as a word at a single time
                else if (hit2)
                    cpu_data_read1<=cache_data[4*index+1][32*offset+:32];
                else if (hit3)
                    cpu_data_read1<=cache_data[4*index+2][32*offset+:32];
                else
                    cpu_data_read1<=cache_data[4*index+3][32*offset+:32];
            end
            else //write hit
            begin
                cpu_ready1<=1'b1;
                if(hit1)
                begin
                    cache_data[4*index][32*offset+:32]<=cpu_data_write;
                    cache_data[4*index][D]<=1'b1;
                end
                else if(hit2)
                begin
                    cache_data[4*index+1][32*offset+:32]<=cpu_data_write;
                    cache_data[4*index+1][D]<=1'b1;                
                end
                else if(hit3)
                begin
                    cache_data[4*index+2][32*offset+:32]<=cpu_data_write;
                    cache_data[4*index+2][D]<=1'b1;                
                end
                else
                begin
                    cache_data[4*index+3][32*offset+:32]<=cpu_data_write;
                    cache_data[4*index+3][D]<=1'b1;                
                end  
            end
        else 
            cpu_ready1<=1'b0;
    end
    
    
    
    //Allocate and WriteBcak
    always @(posedge CLK) begin
        if (state==Allocate) 
            if(!mem_ready)
            begin
                if((PC>= 32'h00000000) && (PC <= 32'h000001FC))
                begin
                    mem_req_valid1<=1'b1;
                    mem_req_addr1<={PC[31:2],2'b00}; // transfer the addr to the mem to get the data in INSTR_MEM
                    mem_req_rw1<=1'b0;
                end
                else
                begin
                    mem_req_valid1<=1'b1;
                    mem_req_addr1<={cpu_req_addr[31:2],2'b00}; // transfer the addr to the mem to get the data in VAR_DATA or CONST_MEM
                    mem_req_rw1<=1'b0;
                end
            end
            else
            begin
                mem_req_valid1<=1'b0;
                cache_data[4*index+way]<={2'b10,tag,mem_data_read}; // data has been fetched, update the data in cache
            end
        else if(state==WriteBack) //miss occur, if dirty block, writeback first, then treat it as a write hit
            if(!mem_ready)
            begin
                mem_req_valid1<=1'b1;
                mem_req_addr1<={cache_data[4*index+way][TagMSB:TagLSB],index,2'b00}; //mem requested addr when writeback
                mem_data_write1<=cache_data[4*index+way][BlockMSB:BlockLSB]; // data being writebacked
                mem_req_rw1<=1'b1;
            end
            else
            begin
                mem_req_valid1<=1'b0;
            end
        else
            mem_req_valid1<=1'b0;
    end 
endmodule
