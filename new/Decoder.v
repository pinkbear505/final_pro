module Decoder(
    input [31:0] Instr,
	
    output PCS,
    output RegW, 
    output MemW, 
    output MemtoReg,
    output ALUSrc,
    output [1:0] ImmSrc,
    output [3:0] RegSrc,
    output reg [1:0] ALUControl,
    output reg [1:0] FlagW,
    output reg  NoWrite,
    output MCycleOp,
    output Start,
    output Float_start,////////////////浮点数
    output addmul,////////////////浮点数    
    output carry,    // ADC SBC RSC
    output reverse, //RSC  RSB
    output eor,   //EOR  TEQ  
    output [1:0]MBM //MOV:01 MVN:11 BIC:10  other condition:00
    ); 
assign Float_start=Instr[27:24]==4'b1110 & Instr[4]==1'b0;//判断浮点数运算是否执行
assign addmul= ({Instr[23],Instr[21],Instr[20],Instr[6]}==4'b0100)? 1'b1://判断是加法还是乘法,1乘法0加法
               ({Instr[23],Instr[21],Instr[20],Instr[6]}==4'b0110)? 1'b0:1'bx;
    
    
    
    wire [1:0] ALUOp ; 
    wire Branch ;
    wire [3:0] Rd;
    wire [1:0] Op;
    wire [5:0] Funct;
    wire Mul;
    wire Div;
    
  
assign Rd=Instr[15:12];    
assign Op=Instr[27:26];
assign Funct=Instr[25:20];  
//list 3
assign carry = ((Funct[4:1]==4'b0101)||(Funct[4:1]==4'b0110)||(Funct[4:1]==4'b0111)) ? 1 : 0;
assign reverse =((Funct[4:1]==4'b0011)||(Funct[4:1]==4'b0111))? 1 : 0;
assign eor=(Funct[4:1]==4'b0001||Funct[4:1]==4'b1001)&&(Op==2'b00)? 1 : 0;
reg [1:0]MBM1;
assign MBM = MBM1;

assign Mul= Op==2'b00 && Instr[25] == 0 && Instr[7:4] == 4'b1001 && Instr[24:21] == 4'b0000;
assign Div= Op==2'b01 && Instr[25:20] == 6'b111111 && Instr[7:4] == 4'b1111;
assign Start = Mul | Div;
assign MCycleOp = Div;
assign Branch=(Op==2'b10);//op=10时为branch指令
assign MemtoReg= (Op==2'b01) & Funct[0]==1? 1://STR时result=readdata LDR时readdata=ALUresult 其余result=ALUresult
                 (Op==2'b01) & Funct[0]==0? 1'bx:
                 0;
assign MemW=(Op==2'b01) & Funct[0]==0;//STR时写入DATA MEMORY
assign ALUSrc=(Op==2'b00) & Funct[5]==0 ? 0://DP指令 I=0时选择shift后的Rm 其余选择Extlmm
                1;
assign ImmSrc=(Op==2'b00) & Funct[5]==0 ? 2'bxx://选Imm8，Imm12，Imm24
              (Op==2'b00) & Funct[5]==1 ? 2'b00:
              (Op==2'b01) ? 2'b01:
              (Op==2'b10) ? 2'b10:
              2'bxx;

assign RegW=(Op==2'b00) & Funct[5]==0 ? 1://写入Register File时为1 DP和LDR
              (Op==2'b00) & Funct[5]==1 ? 1:
              (Op==2'b01) & Funct[0]==0 ? 0:
              (Op==2'b01) & Funct[0]==1 ? 1:              
              (Op==2'b10) ? 0:
               0;
assign RegSrc= Start ? 4'b1011: //[1:0]控制A1 [2]控制A2 [3]控制A3
              (Op==2'b00) & Funct[5]==0 ? 4'b0000://Branch时第零位为1，此时RA1=15  第一位为零时DP reg 选择Rm，1时STR选Rd 其余不用A2
              (Op==2'b00) & Funct[5]==1 ? 4'b0x00:
              (Op==2'b01) & Funct[0]==0 ? 4'b0100:
              (Op==2'b01) & Funct[0]==1 ? 4'b0x00:              
              (Op==2'b10) ? 4'b0x01:
               4'bx;
assign ALUOp=(Op==2'b00) & Funct[5]==0 ? 2'b11://DP指令reg
            (Op==2'b00) & Funct[5]==1 ? 2'b11://DP指令imm
            (Op==2'b01) & (Funct[0]==0) & (Funct[3]==1) ? 2'b01://STR Pos Imm
            (Op==2'b01) & (Funct[0]==0) & (Funct[3]==0) ? 2'b10://STR Neg Imm            
            (Op==2'b01) & Funct[0]==1 & (Funct[3]==1) ? 2'b01://LDR Pos Imm 
            (Op==2'b01) & Funct[0]==1 & (Funct[3]==0) ? 2'b10://LDR Neg Imm             
            (Op==2'b10) ? 2'b00://B
            0;
assign PCS=((Rd==15) & RegW)| Branch;//判断是否将result传回PC或PC=PC+4

// list 3
always@(*) begin   
if(Op==2'b01)begin MBM1=2'b00;
    end
else if(Op==2'b00)begin
     if(Funct[4:1]==4'b1101)begin  MBM1=2'b01; end  //MOV
     else if(Funct[4:1]==4'b1110)begin MBM1=2'b10;end //BIC
     else if(Funct[4:1]==4'b1111)begin MBM1=2'b11;end//MVN
     else begin MBM1=2'b00;end
    end
else  MBM1=2'b00;
end

always@(*) begin
    if(ALUOp==2'b00) begin
        ALUControl=2'b00;
        FlagW=2'b00;
        NoWrite=0;
    end
    else if(ALUOp==2'b11) begin
        if(Funct[4:1]==4'b0100) begin//add
            ALUControl=2'b00;
            NoWrite=0;
            if(Funct[0]==0)
                 FlagW=2'b00;
            else
                 FlagW=2'b11;
        end
        else if(Funct[4:1]==4'b0010) begin//sub
            ALUControl=2'b01;
            NoWrite=0;
            if(Funct[0]==0)
                FlagW=2'b00;
            else
                FlagW=2'b11;    
        end
        else if(Funct[4:1]==4'b0000) begin//and
            ALUControl=2'b10;
            NoWrite=0;
            if(Funct[0]==0)
                FlagW=2'b00;
            else
                FlagW=2'b10;            
        end
        else if(Funct[4:1]==4'b1100) begin//orr
            ALUControl=2'b11;
            NoWrite=0;
            if(Funct[0]==0)
                FlagW=2'b00;
            else
                FlagW=2'b10;            
        end
        else if(Funct[4:1]==4'b1010 & Funct[0]==1) begin//cmp
                FlagW=2'b11;
                ALUControl=2'b01;
                NoWrite=1;           
        end
        else if(Funct[4:1]==4'b1011 & Funct[0]==1) begin//cmp
                FlagW=2'b11;
                ALUControl=2'b00;
                NoWrite=1;           
        end
        // list 3
                else if(Funct[4:1]==4'b0101) begin// ADC
                        ALUControl=2'b00;
                        NoWrite=0;
                        if(Funct[0]==0)
                           FlagW=2'b00;
                        else
                           FlagW=2'b11;           
                end
                else if(Funct[4:1]==4'b0110) begin// SBC
                        ALUControl=2'b01;
                        NoWrite=0;
                         if(Funct[0]==0)
                              FlagW=2'b00;
                          else
                              FlagW=2'b11;           
                end
                else if(Funct[4:1]==4'b0111||Funct[4:1]==4'b0011) begin// RSC RSB
                        ALUControl=2'b01;
                        NoWrite=0;
                       if(Funct[0]==0)
                          FlagW=2'b00;
                       else
                          FlagW=2'b11;           
               end
               else if(Funct[4:1]==4'b0001) begin   // EOR
               ALUControl=2'b11; NoWrite=0;
                       if(Funct[0]==0)
                           FlagW=2'b00;
                       else
                           FlagW=2'b10; 
               end
               else if(Funct[4:1]==4'b1001) begin   // TEQ
                      ALUControl=2'b11; NoWrite=0; FlagW=2'b10; 
               end
               else if(Funct[4:1]==4'b1000) begin   // TST
                      ALUControl=2'b10; NoWrite=0; FlagW=2'b10; 
               end
               else if(Funct[4:1]==4'b1101) begin   // MOV
                     ALUControl=2'b10; NoWrite=0;
                    if(Funct[0]==0)
                        FlagW=2'b00;
                    else
                        FlagW=2'b10;
               end
               else if(Funct[4:1]==4'b1111) begin   // MVN
                     ALUControl=2'b10; NoWrite=0;
                           if(Funct[0]==0)
                               FlagW=2'b00;
                           else
                               FlagW=2'b10;
                end
                else if(Funct[4:1]==4'b1110) begin   // BIC
                        ALUControl=2'b10; NoWrite=0;
                            if(Funct[0]==0)
                                FlagW=2'b00;
                            else
                                FlagW=2'b10;
                end
        else begin
            ALUControl=2'b00;
            FlagW=2'b00;
            NoWrite=0; 
        end
    end
    else if(ALUOp==2'b01) begin
        ALUControl=2'b00;
        FlagW=2'b00;
        NoWrite=0;    
    end
    else if(ALUOp==2'b10) begin
        ALUControl=2'b01;
        FlagW=2'b00;
        NoWrite=0;    
    end
    else begin
    ALUControl=2'b00;
            FlagW=2'b00;
            NoWrite=0;
    end
        
end              
endmodule