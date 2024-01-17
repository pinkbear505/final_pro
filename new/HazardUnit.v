`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/11 10:53:05
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
    input [3:0] RA1D,
    input [3:0] RA2D,
    input [3:0] RA1E,
    input [3:0] RA2E,
    input [3:0] WA3E,
    input MemtoRegE,
    input RegWriteE,
    input PCSrcE,
    input [3:0] WA3M,
    input RegWriteM,
    input [3:0] RA2M,
    input MemWriteM,
    input [3:0] WA3W,
    input RegWriteW,
    input MemtoRegW,
    
    output StallF,
    output StallD,
    output FlashD,
    output FlashE,
    output [1:0] ForwardAE,
    output [1:0] ForwardBE,
    output ForwardM
);
wire Match_1E_M;
wire Match_2E_M;
assign Match_1E_M = (RA1E == WA3M);
assign Match_2E_M = (RA2E == WA3M);
wire Match_1E_W;
wire Match_2E_W;
assign Match_1E_W = (RA1E == WA3W);
assign Match_2E_W = (RA2E == WA3W);
assign ForwardAE = (Match_1E_M & RegWriteM) ? 2'b10:
                   (Match_1E_W & RegWriteW) & ((RA1E!=WA3M)||(!RegWriteM)) ? 2'b01:
                   2'b00;
assign ForwardBE = (Match_2E_M & RegWriteM) ? 2'b10:
                   (Match_2E_W & RegWriteW) & ((RA2E!=WA3M)||(!RegWriteM))? 2'b01:
                   2'b00;
assign ForwardM = (RA2M == WA3W) & MemWriteM & MemtoRegW & RegWriteW;
wire Match_12D_E;
assign Match_12D_E = (RA1D == WA3E) || (RA2D == WA3E);
wire ldrstall;
assign ldrstall = Match_12D_E & MemtoRegE & RegWriteE;
assign StallF = ldrstall;
assign StallD = ldrstall;
assign FlashE = ldrstall || PCSrcE;
assign FlashD = PCSrcE;


endmodule
