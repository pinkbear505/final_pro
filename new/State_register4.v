`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/10 14:07:57
// Design Name: 
// Module Name: State_register2
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


module State_register4(
    input CLK,
    input [31:0] ReadDataM,
    input [31:0] ALUOutM,
    input [3:0] WA3M,
    input PCSrcM,
    input RegWriteM,
    input MemtoRegM,
    input MvalidM,
    input [3:0] MWA3M,    
    input [31:0] WResultM,
    input Float_startM,
    input [31:0] FloatoutM,
    input Cache_Stall,
    input MemWriteM,

    output reg [31:0] ReadDataW,
    output reg [31:0] ALUOutW,
    output reg [3:0] WA3W,
    output reg  PCSrcW,
    output reg  RegWriteW,
    output reg  MemtoRegW,
    output reg MvalidW,
    output reg [3:0] MWA3W,
    output reg [31:0] WResultW,
    output reg Float_startW,
    output reg [31:0] FloatoutW,
    output reg MemWriteW                  
    );
always @(posedge CLK) begin
    if (!Cache_Stall)begin
    ReadDataW<=ReadDataM;
    ALUOutW<=ALUOutM;
    WA3W<=WA3M;
    PCSrcW<=PCSrcM;
    RegWriteW<=RegWriteM;
    MemtoRegW<=MemtoRegM;
    MvalidW<=MvalidM;
    MWA3W<=MWA3M;
    WResultW<=WResultM;
    Float_startW<=Float_startM;
    FloatoutW<=FloatoutM;
    MemWriteW<=MemWriteM;
    end
    else begin
    ReadDataW<=ReadDataW;
    ALUOutW<=ALUOutW;
    WA3W<=WA3W;
    PCSrcW<=PCSrcW;
    RegWriteW<=RegWriteW;
    MemtoRegW<=MemtoRegW;
    MvalidW<=MvalidW;
    MWA3W<=MWA3W;
    WResultW<=WResultW;
    Float_startW<=Float_startW;
    FloatoutW<=FloatoutW;    
    MemWriteW<=MemWriteW;
    end
    
end        
endmodule
