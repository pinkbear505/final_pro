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


module State_register3(
    input CLK,
    input [31:0] WriteDataE,    
    input [31:0] ALUResultE,
    input [3:0] WA3E,
    input RegWriteE,
    input MemWriteE,
    input MemtoRegE,
    input [3:0] RA2E,
    input MvalidE,
    input [3:0] MWA3E,
    input [31:0] WResultE,
    input [3:0]  ALUFlagsE,
    input Float_startE,
    input [31:0] FloatoutE,

    
    output reg [31:0] WriteDataM,
    output reg [31:0] ALUResultM,
    output reg [3:0] WA3M,
    output reg RegWriteM,
    output reg MemWriteM,
    output reg MemtoRegM,
    output reg [3:0] RA2M,
    output reg MvalidM,
    output reg [3:0] MWA3M,
    output reg [31:0] WResultM,
    output reg Float_startM,
    output reg [31:0] FloatoutM,
     // list 3
       output reg [3:0]  ALUFlagsM   
    );
always @(posedge CLK) begin
     ALUResultM<=ALUResultE;
     WriteDataM<=WriteDataE;
     WA3M<=WA3E;
     RegWriteM<=RegWriteE;
     MemWriteM<=MemWriteE;
     MemtoRegM<=MemtoRegE;
     RA2M<=RA2E;
     MvalidM<=MvalidE;
     MWA3M<=MWA3E;
     WResultM<=WResultE;
     Float_startM<=Float_startE;
     FloatoutM<=FloatoutE;
      // list 3
         ALUFlagsM<=ALUFlagsE;
end     
endmodule
