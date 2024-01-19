module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc,
    input [31:0] Result,
//    input Busy,
    input StallF,
    input Mstall,
    input Cache_Stall,
    
    output reg [31:0] PC,
    output [31:0] PC_Plus_4
); 

//fill your Verilog code here
reg [31:0] next_PC;
reg [31:0] current_PC;
assign PC_Plus_4=current_PC+4;
always @(*) begin
    PC=current_PC;
    if(PCSrc)
        next_PC=Result;
    else
        next_PC=PC_Plus_4;
end
always @(posedge CLK or posedge Reset) begin
    if(Reset)
        current_PC<=0;
    else if (StallF || Mstall || Cache_Stall)
        current_PC<=current_PC;
    else begin
        current_PC<=next_PC;
    end
end

endmodule