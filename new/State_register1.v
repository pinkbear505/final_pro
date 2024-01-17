`timescale 1ns / 1ps

module State_register1(
    input CLK,
    input [31:0] InstrF,
    input StallD,
    input FlashD,
    input Mstall,
    
    output reg [31:0] InstrD
    );
always @(posedge CLK) begin
    if(FlashD)
        InstrD<=0;
    else if(StallD || Mstall)
        InstrD<=InstrD;
    else
        InstrD<=InstrF;
end    
endmodule
