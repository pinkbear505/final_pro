module ARM(
    input CLK,
    input Reset,
    input [31:0] Instr,
    input [31:0] ReadData,
    input current_state,

    output MemWriteM,
    output MemWriteW,
    output [31:0] PC,
    output [31:0] ALUResultM,
    output [31:0] WriteData,
    output cpu_req_valid,
    output [31:0] ALUOutW
);
wire done;
wire MWrite;

    wire Cache_Stall;
    assign Cache_Stall=!current_state;
        

    wire PCSD;
    wire RegWD;
    wire MemWD;
    wire [1:0] FlagWD;
    wire [1:0] ALUControlD;
    wire MemtoRegD;
    wire ALUSrcD;
    wire [1:0] ImmSrcD;
    wire [3:0] RegSrcD;
    wire NoWriteD;
//1
wire [31:0] InstrD;
wire [31:0] InstrF;
assign InstrF=Instr;
//2
wire [3:0] MWA3D;
assign MWA3D= InstrD[19:16];
wire [3:0] WA3D;
assign WA3D= InstrD[15:12];
wire [3:0] WA3E;
wire [31:0] RD1E;
wire [31:0] RD2E;
wire [31:0] ExtImmE;
wire [3:0] Cond;
assign Cond = InstrD[31:28];
wire PCSE;
wire RegWE;
wire MemWE;
wire [1:0] FlagWE;
wire [1:0] ALUControlE;
wire MemtoRegE;
wire ALUSrcE;
wire [3:0] CondE;
wire NoWriteE;
wire [3:0] RA1E;
wire [3:0] RA2E;
wire BusyE;
wire StartE;
wire [31:0] WResultE;
wire Float_startE;///////////////////浮点�
wire[31:0] FloatoutE;///////////////////浮点�
//3
wire [31:0] WriteDataE;
wire [3:0] MWA3E1;

wire [31:0] ALUResultE;
wire [31:0] WriteDataM;
wire [3:0] WA3M;

    wire PCSrcE;
    wire RegWriteE;
    wire MemWriteE;
    
wire PCSrcM;
wire RegWriteM;
wire MemtoRegM;
wire [3:0] RA2M;
wire [31:0] WResultM;
wire Float_startM;///////////////////浮点�
wire[31:0] FloatoutM;///////////////////浮点�
//4
wire [31:0] ReadDataM;
assign ReadDataM=ReadData;
wire [31:0] ALUOutM;
assign ALUOutM=ALUResultM;
wire [31:0] ReadDataW;
wire [3:0] WA3W;
wire  PCSrcW;
wire  RegWriteW;
wire  MemtoRegW; 
wire [31:0] WResultW;
wire Float_startW;///////////////////浮点�
wire[31:0] FloatoutW;///////////////////浮点�
//Condlogic

wire [3:0] ALUFlagsE;
wire [31:0] ResultW;
wire [3:0] ALUFlagsM;


//Mcycle

//Hazard
wire StallF;
wire StallD;
wire FlashD;
wire FlashE;
wire [1:0] ForwardAE;
wire [1:0] ForwardBE;
wire ForwardM;


//
wire WE3;
assign WE3=RegWriteW;
wire [3:0] RA1D;
assign RA1D= RegSrcD[1:0]==2'b00 ? InstrD[19:16]:
           RegSrcD[1:0]==2'b01 ? 15:
           RegSrcD[1:0]==2'b11 ? InstrD[11:8]:
           4'bx;
wire [3:0] RA2D;
wire Float_start;////////////////浮点�?
assign RA2D= (Float_start)? InstrD[3:0]:RegSrcD[2]==0 ? InstrD[3:0]:////////////////浮点�?
            InstrD[15:12];


wire [3:0] A3;

wire [31:0] WD3;

//assign MWrite= ~BusyW & StartW;


//
assign ResultW= MemtoRegW==1 ? ReadDataW: ALUOutW;
wire [31:0] PC_Plus_4F;
wire [31:0] PC_Plus_8D;
assign PC_Plus_8D=PC_Plus_4F;
wire [31:0] R15;
assign R15=PC_Plus_8D;
wire MCycleOpD;
wire StartD;
wire StartE1;

reg preStartE;
reg Mstall=1'b0;
reg MvalidE=0;
wire MCycleOpE;
reg [3:0] MWA3E;
wire [3:0] MWA3M;
wire [3:0] MWA3W;
wire MvalidM;
wire MvalidW;
reg predone;

 // list 3
wire carryD,reverseD,eorD;
wire [1:0]MBMD;
assign StartE1= preStartE==0 && StartE==1;
always@(posedge CLK) begin
    preStartE<=StartE;

    predone<=done;
    if(StartE1 && ~MvalidW) begin
        MWA3E=MWA3E1;
        if (MWA3E==RA1D || MWA3E==RA2D || StartD)
            Mstall=1;
    end
    if(BusyE && ~MvalidW) begin
        if (MWA3E==RA1D || MWA3E==RA2D || StartD)
                Mstall=1;
    end
    if (done) begin
        
        if(predone==0 && done==1)
            MvalidE=1;
        else
            MvalidE=0;
    end
    if(MvalidW)
        Mstall=0;
end
assign WD3= MvalidW==1 ? WResultW: 
            Float_startW==1 ? FloatoutW:
            ResultW;
ProgramCounter ProgramCounter1(
    CLK,
    Reset,
    PCSrcE,
    ALUResultE,
//    Busy,
    StallF,
    Mstall,
    Cache_Stall,
    
    PC,
    PC_Plus_4F    

);

wire addmul;///////////////////浮点�?

ControlUnit ControlUnit1(
    InstrD,

    PCSD,
    RegWD,
    MemWD,
    FlagWD,
    ALUControlD,
    MemtoRegD,
    ALUSrcD,
    ImmSrcD,
    RegSrcD,
    NoWriteD,
    MCycleOpD,
    StartD,
        // list 3

    
    Float_start,///////////////////浮点�?
    addmul,///////////////////浮点�?
    // list 3
    carryD,
    reverseD,
    eorD,
    MBMD
    );
wire [31:0] Src_AE;
wire [31:0] Src_BE;
wire [31:0] ExtImm;
wire [31:0] RD1;
wire [31:0] RD2;
wire [31:0] ShOut;
//Float
 
       wire[31:0] Float1;///////////////////浮点�?
       wire[31:0] Float2;///////////////////浮点�?
       assign Float1=RD1;///////////////////浮点�?
       assign Float2=RD2;///////////////////浮点�?
       wire[31:0] Floatout;///////////////////浮点�?
       
assign A3= MvalidW==1 ? MWA3W :
             WA3W;
assign Src_AE= ForwardAE ==2'b00 ? RD1E:
               ForwardAE ==2'b01 ? ResultW:
               ForwardAE ==2'b10 ? ALUResultM:
               32'bx;
assign WriteDataE= ForwardBE==2'b00 ? RD2E:
                   ForwardBE==2'b01 ? ResultW:
                   ForwardBE==2'b10 ? ALUResultM:
                   32'bx;    
assign Src_BE= ALUSrcE==0 ? WriteDataE:ExtImmE;

wire carryE,reverseE,eorE;
wire [1:0]MBME;
ALU ALU1(
        Src_AE,
        Src_BE,
        ALUControlE,
        // list 3
                carryE,
                reverseE,
                eorE,
                MBME,
                ALUFlagsM,
    
        ALUResultE,
        ALUFlagsE

        );
        

RegisterFile RegisterFile1(
            CLK,
            WE3,
            RA1D,
            RA2D,
            A3,
            WD3,
            R15,
            MvalidW,
            Float_startW,////////////////浮点�?
            
        
            RD1,
            RD2
            );
assign WriteData= ForwardM==1'b0 ? WriteDataM:
                  ResultW;

wire [23:0] InstrImm;
assign InstrImm= InstrD[23:0];
Extend Extend1(
    ImmSrcD,
    InstrImm[23:0],
            
    ExtImm
); 
 
Shifter Shifter1(
    InstrD[6:5],
    InstrD[11:7],
    RD2,
    
    ShOut
    );
MCycle MCycle1(
         CLK,   // Connect to CPU clock
         Reset, // Connect to the reset of the ARM processor.
         StartE1, // Multi-cycle Enable. The control unit should assert this when MUL or DIV instruction is detected.
         MCycleOpE, // Multi-cycle Operation. "0" for unsigned multiplication, "1" for unsigned division. Generated by Control unit.
         Src_AE, // Multiplicand / Dividend
         Src_BE, // Multiplier / Divisor
         WResultE,  //For MUL, assign the lower-32bits result; For DIV, assign the quotient.
         BusyE, // Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
         done
       );

State_register1 State_register1(
           CLK,
           InstrF,
           StallD,
           FlashD,
           Mstall,
           Cache_Stall,
         
           
           InstrD
           );

State_register2 State_register2(
           CLK,
           RD1,
           RD2,
           WA3D,
           ExtImm,
           PCSD,
           RegWD,
           MemWD,
           FlagWD,
           ALUControlD,
           MemtoRegD,
           ALUSrcD,
           Cond,
           NoWriteD,
           RA1D,
           RA2D,
           FlashE,
           StartD,
           MCycleOpD,
           Mstall,
           Cache_Stall,
           MWA3D,
           Float_start,
           Floatout,
            // list 3
                     carryD,
                     reverseD,
                     eorD,
                     MBMD,
           

               
           RD1E,
           RD2E,
           WA3E,
           ExtImmE,
           PCSE,
           RegWE,
           MemWE,
           FlagWE,
           ALUControlE,
           MemtoRegE,
           ALUSrcE,
           CondE,
           NoWriteE,
           RA1E,
           RA2E,
           StartE,
           MCycleOpE,
           MWA3E1,
           Float_startE,
           FloatoutE,
             // list 3
                    carryE,
                    reverseE,
                    eorE,
                    MBME
               );
CondLogic CondLogic1(
           CLK,
           PCSE,
           RegWE,
           MemWE,
           FlagWE,
           CondE,
           NoWriteE,
           ALUFlagsE,
                   
           PCSrcE,
           RegWriteE,
           MemWriteE
); 
State_register3 State_register3(
           CLK,
           WriteDataE,    
           ALUResultE,
           WA3E,
           RegWriteE,
           MemWriteE,
           MemtoRegE,
           RA2E,
           MvalidE,
           MWA3E,
           WResultE,
           ALUFlagsE,
           Float_startE,
           FloatoutE,
           Cache_Stall,
           
                              
           WriteDataM,
           ALUResultM,
           WA3M,
           RegWriteM,
           MemWriteM,
           MemtoRegM,
           RA2M,
           MvalidM,
           MWA3M,
           WResultM,
           Float_startM,
           FloatoutM,
           ALUFlagsM           
);

State_register4 State_register4(
    CLK,
    ReadDataM,
    ALUOutM,
    WA3M,
    PCSrcM,
    RegWriteM,
    MemtoRegM,
    MvalidM,
    MWA3M,
    WResultM,
    Float_startM,
    FloatoutM,    
    Cache_Stall,
    MemWriteM,

    ReadDataW,
    ALUOutW,
    WA3W,
    PCSrcW,
    RegWriteW,
    MemtoRegW,
    MvalidW,
    MWA3W,
    WResultW,
    Float_startW,
    FloatoutW ,
    MemWriteW       
    );
HazardUnit HazardUnit(
        RA1D,
        RA2D,
        RA1E,
        RA2E,
        WA3E,
        MemtoRegE,
        RegWriteE,
        PCSrcE,
        WA3M,
        RegWriteM,
        RA2M,
        MemWriteM,
        WA3W,
        RegWriteW,
        MemtoRegW,
        
        StallF,
        StallD,
        FlashD,
        FlashE,
        ForwardAE,
        ForwardBE,
        ForwardM
    );
    

        Float Float(///////////////////浮点�?
            Float_start,
            Float1,
            Float2,
            addmul,
            Floatout//////////这个怎么写到寄存器里
        );  
        

        
        reg cpu_req_valid1;
        assign cpu_req_valid=cpu_req_valid1;
        always @(*) begin
            if (MemtoRegM || MemtoRegW ||MemWriteM)
                cpu_req_valid1=1'b1;
            else
                cpu_req_valid1=1'b0;
        end
        
        
endmodule