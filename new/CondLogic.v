module CondLogic(
    input CLK,
    input PCSE,
    input RegWE,
    input MemWE,
    input [1:0] FlagWE,
    input [3:0] CondE,
    input [3:0] ALUFlags,
    input NoWriteE,
    
    output PCSrcE,
    output RegWriteE,
    output MemWriteE
    ); 
    
    reg CondEx ;
    reg N = 0, Z = 0, C = 0, V = 0 ;
    wire [1:0] FlagWrite;
 assign FlagWrite[0]=FlagWE[0] & CondEx;
 assign FlagWrite[1]=FlagWE[1] & CondEx;
 assign PCSrcE= CondEx & PCSE;
 assign RegWriteE= CondEx & RegWE & (~NoWriteE);
 assign MemWriteE= CondEx & MemWE;
 always@(*) begin
    case(CondE)
        4'b0000: CondEx=Z;
        4'b0001: CondEx=~Z;
        4'b0010: CondEx=C;
        4'b0011: CondEx=~C;
        4'b0100: CondEx=N;
        4'b0101: CondEx=~N;
        4'b0110: CondEx=V;
        4'b0111: CondEx=~V;
        4'b1000: CondEx=(~Z)&C;
        4'b1001: CondEx=Z|(~C);
        4'b1010: CondEx=~(N^V);
        4'b1011: CondEx=N^V;
        4'b1100: CondEx=(~Z)&(~(N^V));
        4'b1101: CondEx=Z|(N^V);
        4'b1110: CondEx=1;
        default: CondEx=0;
    endcase
 end
  always@(posedge CLK) begin
    if(FlagWrite[0]==1) begin
        C<=ALUFlags[1];
        V<=ALUFlags[0];
    end
    else begin
        C<=C;
        V<=V;
    end
    if(FlagWrite[1]==1) begin
            N<=ALUFlags[3];
            Z<=ALUFlags[2];
        end
        else begin
            N<=N;
            Z<=Z;
        end
  end
endmodule