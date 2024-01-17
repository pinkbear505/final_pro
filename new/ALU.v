module ALU(
    input [31:0] Src_A,
    input [31:0] Src_B,
    input [1:0] ALUControl,
    input carry,
    input reverse,
    input eor,
    input [1:0]MBM,
    input [3:0]  ALUFlagsM,
    output [31:0] ALUResult,
    output [3:0]  ALUFlagsE
    );

      reg [32:0] sum;   
      reg Cout;

   reg [31:0]ALUResulta;
   assign ALUResult= ALUResulta;

 always@(*)begin                 
 
 case(ALUControl)
      2'b00 :begin                  
        if(!carry)begin  //ADD               
            sum=Src_B+Src_A;
            ALUResulta=sum[31:0];
        end
        else begin      //ADC
            sum=Src_A+Src_B+ALUFlagsM[1];
            ALUResulta=sum[31:0];
        end
            Cout=sum[32];                       
       end  
     2'b01: begin 
       if(!carry)begin 
           if(!reverse)begin //SUB
            sum=Src_A+~Src_B+1'b1;
           end
           else begin //RSB
            sum=~Src_A+Src_B+1'b1;
           end
           ALUResulta=sum[31:0];
       end
       else begin      
           if(!reverse)begin//SBC
            if(ALUFlagsM[1])
                sum=Src_A+~Src_B+1'b1;
            else
                sum=Src_A+~Src_B+1'b1-1;         
           end
           else begin  //RSC
             if(ALUFlagsM[1])
                 sum=~Src_A+Src_B+1'b1;
              else
                 sum=~Src_A+Src_B+1'b1-1;                                      
           end        
       end
            Cout=sum[32];  ALUResulta=sum[31:0];                         
       end       
     2'b10: begin //AND
           if(MBM==2'b00)begin
            sum= Src_A&Src_B;end
           else if(MBM==2'b01)begin  //MOV
            sum = Src_B;end
           else if(MBM==2'b11)begin  //MVN
           sum = ~Src_B;end
           else if(MBM==2'b10)begin  //BIC
           sum= Src_A&~Src_B;end
           else sum= Src_A&Src_B;
           ALUResulta=sum[31:0];
      end        
     2'b11: begin //OR
        if(!eor)begin
           sum= Src_A|Src_B;ALUResulta=sum[31:0]; end
        else begin  sum = Src_A^Src_B;ALUResulta=sum[31:0];end  // EOR TEQ                 
     end
                    
 endcase
 
 end
          

assign ALUFlagsE[3]=ALUResult[31];//N                                      
assign ALUFlagsE[2]=(ALUResult==32'b0)?1:0; //Z
assign ALUFlagsE[1]=Cout&(~ALUControl[1]);  //C
assign ALUFlagsE[0]=~(ALUControl[0]^Src_A[31]^Src_B[31])&(Src_A[31]^sum[31])&(~ALUControl[1]); //V
        
endmodule