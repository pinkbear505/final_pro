// The multiplier template is provided, and you should modify it to the improved one and share the hardware resource to implement division.
module MCycle
  #(parameter width = 32) // 32-bits for ARMv3
   (
     input CLK,   // Connect to CPU clock
     input RESET, // Connect to the reset of the ARM processor.
     input Start, // Multi-cycle Enable. The control unit should assert this when MUL or DIV instruction is detected.
     input MCycleOp, // Multi-cycle Operation. "0" for unsigned multiplication, "1" for unsigned division. Generated by Control unit.
     input [width-1:0] Operand1, // Multiplicand / Dividend
     input [width-1:0] Operand2, // Multiplier / Divisor
     output [width-1:0] Result,  //For MUL, assign the lower-32bits result; For DIV, assign the quotient.
     output reg Busy, // Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
     output reg done
   );

  localparam IDLE = 1'b0;
  localparam COMPUTING = 1'b1;
  reg state, n_state;
//  reg done;
  // state machine
  always @(posedge CLK or posedge RESET)
  begin
    if(RESET)
      state <= IDLE;
    else
      state <= n_state;
  end

  always @(*)
  begin
    case(state)
      IDLE:
      begin
        if(Start)
        begin
          n_state = COMPUTING;
          Busy = 1'b1;
        end
        else
        begin
          n_state = IDLE;
          Busy = 1'b0;
        end
      end
      COMPUTING:
      begin
        if(~done)
        begin
          n_state = COMPUTING ;
          Busy = 1'b1 ;
        end
        else
        begin
          n_state = IDLE;
          Busy = 1'b0;
        end
      end
    endcase
  end

  reg [5:0] count = 0 ; // assuming no computation takes more than 64 cycles.
  reg [2*width-1:0] temp_sum = 0 ;
  reg [2*width-1:0] shifted_op1 = 0 ;
//  reg [width-1:0] shifted_op2 = 0 ;
  
wire [2*width-1:0] t;
assign t=shifted_op1 + temp_sum[2*width-1:0];
wire [2*width:0] subres;
assign subres = temp_sum-shifted_op1;
wire sign_extend;
assign sign_extend=subres[2*width];
  // Multi-cycle Multiplier & divider
  always@(posedge CLK or posedge RESET)
  begin: COMPUTING_PROCESS // process which does the actual computation
    if( RESET )
    begin
      count <= 0 ;
      temp_sum <= { {width{1'b0}}, Operand1 } ;
      shifted_op1 <= {  Operand2,{width{1'b0}} } ;
 //     shifted_op2 <= Operand2;
      done <= 0;
    end
    // state: IDLE
    else if(state == IDLE)
    begin
      if(n_state == COMPUTING)
      begin
        count <= 0 ;
        temp_sum <= {{width{1'b0}}, Operand1 }  ;
        shifted_op1 <= {  Operand2,{width{1'b0}} } ;
 //       shifted_op2 <= Operand2;
        done <= 0;
      end
      // else IDLE->IDLE: registers unchanged
    end
    // state: COMPUTING
    else if(n_state == COMPUTING)
    begin
      if( ~MCycleOp )
      begin // Multiply operation
        // The intial version of multiplier template, modify it to the improved one
 //       if(count==0)
 //           temp_sum<={ {width{1'b0}}, Operand2 };
        if(count == width-1)
        begin // last cycle
          done <= 1'b1 ;
          count <= 0;
        end
        else
        begin
          done <= 1'b0;
          count <= count + 1;
        end
        if(count>=0)begin
            if(temp_sum[0])
                temp_sum <= {1'b0,t[2*width-1:1]};
            else
                temp_sum <= {1'b0,temp_sum[2*width-1:1]};
        end
      end
      // Multiplier end
      else
      begin // Divide operation
        //
        // Fit with your code to design divider, remember to share the hardware resource with the improved multiplier
        //
        if(count == width)
        begin // last cycle
          done <= 1'b1 ;
          count <= 0;
        end
        else
        begin
          done <= 1'b0;
          count <= count + 1;
        end
        if(sign_extend)
            temp_sum<={temp_sum[2*width-2:0],1'b0};
        else begin
            temp_sum<={subres[2*width-2:0],1'b1};
        end
            
      end
    end
    // else COMPUTING->IDLE: registers unchanged
  end

  assign Result = temp_sum[width-1:0];

endmodule

