module RegisterFile(
    input CLK,
    input WE3,
    input [3:0] RA1D,
    input [3:0] RA2D,
    input [3:0] A3,
    input [31:0] WD3,
    input [31:0] R15,
    input MvalidW,
    input Float_startW,


    output [31:0] RD1,
    output [31:0] RD2
    );
        
    // declare RegBank
    reg [31:0] RegBank[0:14] ;
 //   reg [31:0] FloatBank[0:14] ;
assign RD1=  RA1D==15 ? R15:RegBank[RA1D];////////////////浮点�?
assign RD2=  RA2D==15 ? R15:RegBank[RA2D];////////////////浮点�?

always @(negedge CLK) begin
     if(WE3 || MvalidW || Float_startW)////////////////浮点�?
          RegBank[A3]<=WD3;
    
end 
    
endmodule