module ControlUnit(
    input [31:0] InstrD,

    output PCSD,
    output RegWD,
    output MemWD,
    output [1:0] FlagWD,
    output [1:0] ALUControlD,
    output MemtoRegD,
    output ALUSrcD,
    output [1:0] ImmSrcD,
    output [3:0] RegSrcD,
    output NoWrite,
    output MCycleOp,
    output Start,
    output Float_start,
    output addmul,
    output carryD,
    output reverseD,
    output eorD,
    output [1:0]MBMD
    ); 
    
//    wire [3:0] Cond;
//    wire RegW, MemW;
//    wire [1:0] FlagW;
//    wire PCS;
//    assign Cond=InstrD[31:28];

//    CondLogic CondLogic1(
//     CLK,
//     PCS,
//     RegW,
//     MemW,
//     FlagW,
//     Cond,
//     ALUFlags,
//     NoWrite,

//     PCSrcD,
//     RegWrite,
//     MemWrite
//    );

    Decoder Decoder1(
     InstrD,
     PCSD,
     RegWD,
     MemWD,
     MemtoRegD,
     ALUSrcD,
     ImmSrcD,
     RegSrcD,
     ALUControlD,
     FlagWD,
     NoWrite,
     MCycleOp,
     Start,
     Float_start,////////////////浮点�?
     addmul,////////////////浮点�
     carryD,
     reverseD,
     eorD,
     MBMD     
    );
endmodule