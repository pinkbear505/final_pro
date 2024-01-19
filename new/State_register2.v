`timescale 1ns / 1ps

module State_register2(
    input CLK,
    input [31:0] RD1,
    input [31:0] RD2,
    input [3:0] WA3D,
    input [31:0] ExtImm,
    input PCSD,
    input RegWD,
    input MemWD,
    input [1:0] FlagWD,
    input [1:0] ALUControlD,
    input MemtoRegD,
    input ALUSrcD,
    input [3:0] Cond,
    input NoWriteD,
    input [3:0] RA1D,
    input [3:0] RA2D,
    input FlashE,
    input StartD,
    input MCycleOpD,
    input Mstall,
    input Cache_Stall,
    input [3:0] MWA3D,
    input Float_startD,
    input [31:0] FloatoutD,
      //list 3
      input carryD,
      input reverseD,
      input eorD,
      input [1:0]MBMD,
    
    output reg [31:0] SrcAE,
    output reg [31:0] SrcBE0,
    output reg [3:0] WA3E,
    output reg [31:0] ExtImmE,
    output reg PCSE,
    output reg RegWE,
    output reg MemWE,
    output reg [1:0] FlagWE,
    output reg [1:0] ALUControlE,
    output reg MemtoRegE,
    output reg ALUSrcE,
    output reg [3:0] CondE,
    output reg NoWriteE,
    output reg [3:0] RA1E,
    output reg [3:0] RA2E,
    output reg StartE,
    output reg MCycleOpE,
    output reg [3:0] MWA3E1,
    output reg Float_startE,
    output reg [31:0] FloatoutE,
     // list 3
       output reg carryE,
       output reg reverseE,
       output reg eorE,
       output reg [1:0]MBME
    );
always @(posedge CLK) begin
    if(FlashE) begin
    SrcAE<=0;
    SrcBE0<=0;
    WA3E<=0;
    ExtImmE<=0;
    PCSE<=0;
    RegWE<=0;
    MemWE<=0;
    FlagWE<=0;
    ALUControlE<=0;
    MemtoRegE<=0;
    ALUSrcE<=0;
    CondE<=0;
    NoWriteE<=0;
    RA1E<=0;
    RA2E<=0;
    StartE<=0;
    MCycleOpE<=0;
    MWA3E1<=0;
    Float_startE<=0;
    FloatoutE<=0;
    // list 3
        carryE<=0;
        reverseE<=0;
        eorE<=0;
        MBME<=2'b00;
    end
    else if(Mstall || Cache_Stall) begin
    SrcAE<=SrcAE;
    SrcBE0<=SrcBE0;
    WA3E<=WA3E;
    ExtImmE<=ExtImmE;
    PCSE<=PCSE;
    RegWE<=RegWE;
    MemWE<=MemWE;
    FlagWE<=FlagWE;
    ALUControlE<=ALUControlE;
    MemtoRegE<=MemtoRegE;
    ALUSrcE<=ALUSrcE;
    CondE<=CondE;
    NoWriteE<=NoWriteE;
    RA1E<=RA1E;
    RA2E<=RA2E;
    StartE<=StartE;
    MCycleOpE<=MCycleOpE; 
    MWA3E1<=MWA3E1;
    Float_startE<=Float_startE;
    FloatoutE<=FloatoutE;
       // list 3
      carryE<=carryE;
      reverseE<=reverseE;
      eorE<=eorE;
      MBME<=MBME;
    end
    else begin
        SrcAE<=RD1;
        SrcBE0<=RD2;
        WA3E<=WA3D;
        ExtImmE<=ExtImm;
        PCSE<=PCSD;
        RegWE<=RegWD;
        MemWE<=MemWD;
        FlagWE<=FlagWD;
        ALUControlE<=ALUControlD;
        MemtoRegE<=MemtoRegD;
        ALUSrcE<=ALUSrcD;
        CondE<=Cond;
        NoWriteE<=NoWriteD;
        RA1E<=RA1D;
        RA2E<=RA2D;
        StartE<=StartD;
        MCycleOpE<=MCycleOpD;
        MWA3E1<=MWA3D;
        Float_startE<=Float_startD;
        FloatoutE<=FloatoutD;
        // list 3
               carryE<=carryD;
               reverseE<=reverseD;
               eorE<=eorD;
               MBME<=MBMD;
    end  
end    
endmodule
