module Shifter(
    input [1:0] Sh,
    input [4:0] Shamt5,
    input [31:0] ShIn,
    
    output [31:0] ShOut
    );
wire [31:0] ShOutLSL;
wire [31:0] ShOutLSLA;
assign ShOutLSLA = Shamt5[4]==0 ? ShIn:
        {ShIn[15:0],16'b0};
wire [31:0] ShOutLSLB;
assign ShOutLSLB = Shamt5[3]==0 ? ShOutLSLA:
        {ShOutLSLA[23:0],8'b0};
wire [31:0] ShOutLSLC;
assign ShOutLSLC = Shamt5[2]==0 ? ShOutLSLB:
        {ShOutLSLB[27:0],4'b0};
wire [31:0] ShOutLSLD;
assign ShOutLSLD = Shamt5[1]==0 ? ShOutLSLC:
        {ShOutLSLC[29:0],2'b0};
assign ShOutLSL = Shamt5[0]==0 ? ShOutLSLD:
        {ShOutLSLD[30:0],1'b0};
        
wire [31:0] ShOutLSR;
wire [31:0] ShOutLSRA;
assign ShOutLSRA = Shamt5[4]==0 ? ShIn:
        {16'b0,ShIn[31:16]};
wire [31:0] ShOutLSRB;
assign ShOutLSRB = Shamt5[3]==0 ? ShOutLSRA:
        {8'b0,ShOutLSRA[31:8]};
wire [31:0] ShOutLSRC;
assign ShOutLSRC = Shamt5[2]==0 ? ShOutLSRB:
        {4'b0,ShOutLSRB[31:4]};
wire [31:0] ShOutLSRD;
assign ShOutLSRD = Shamt5[1]==0 ? ShOutLSRC:
        {2'b0,ShOutLSRC[31:2]};
assign ShOutLSR = Shamt5[0]==0 ? ShOutLSRD:
        {1'b0,ShOutLSRD[31:1]};

wire [31:0] ShOutASR;
wire [31:0] ShOutASRA;
assign ShOutASRA = Shamt5[4]==0 ? ShIn:
        {{16{ShIn[31]}},ShIn[31:16]};
wire [31:0] ShOutASRB;
assign ShOutASRB = Shamt5[3]==0 ? ShOutASRA:
        {{8{ShIn[31]}},ShOutASRA[31:8]};
wire [31:0] ShOutASRC;
assign ShOutASRC = Shamt5[2]==0 ? ShOutASRB:
        {{4{ShIn[31]}},ShOutASRB[31:4]};
wire [31:0] ShOutASRD;
assign ShOutASRD = Shamt5[1]==0 ? ShOutASRC:
        {{2{ShIn[31]}},ShOutASRC[31:2]};
assign ShOutASR = Shamt5[0]==0 ? ShOutASRD:
        {{1{ShIn[31]}},ShOutASRD[31:1]};
        
wire [31:0] ShOutROR;
wire [31:0] ShOutRORA;
assign ShOutRORA = Shamt5[4]==0 ? ShIn:
        {ShIn[15:0],ShIn[31:16]};
wire [31:0] ShOutRORB;
assign ShOutRORB = Shamt5[3]==0 ? ShOutRORA:
        {ShOutRORA[7:0],ShOutRORA[31:8]};
wire [31:0] ShOutRORC;
assign ShOutRORC = Shamt5[2]==0 ? ShOutRORB:
        {ShOutRORB[3:0],ShOutRORB[31:4]};
wire [31:0] ShOutRORD;
assign ShOutRORD = Shamt5[1]==0 ? ShOutRORC:
        {ShOutRORC[1:0],ShOutRORC[31:2]};
assign ShOutROR = Shamt5[0]==0 ? ShOutRORD:
        {ShOutRORD[0],ShOutRORD[31:1]};
        
assign ShOut= Sh==2'b00 ? ShOutLSL:
              Sh==2'b01 ? ShOutLSR:
              Sh==2'b10 ? ShOutASR:
              ShOutROR;
endmodule 
