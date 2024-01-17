`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/20 18:13:50
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Float(
    input Float_start,//判断是否是浮点数运算,=1时是浮点数运算
    input[31:0] Float1,
    input[31:0] Float2,
    input addmul,//0:add,1:mul写在control模块里
    output[31:0] Floatout 
);
    wire sign1;
    wire sign2;
    wire[7:0] exponent1;
    wire[7:0] exponent2;
    wire[22:0] mantissa1;
    wire[22:0] mantissa2;
    wire[24:0] num1_wire_add;
    wire[24:0] num2_wire_add;
    wire[47:0] num1_wire_mul;
    wire[47:0] num2_wire_mul;

    assign sign1=Float1[31];
    assign sign2=Float2[31];
    assign exponent1=Float1[30:23];
    assign exponent2=Float2[30:23];
    assign mantissa1=Float1[22:0];
    assign mantissa2=Float2[22:0];
    assign num1_wire_add={1'b0,1'b1,mantissa1};
    assign num2_wire_add={1'b0,1'b1,mantissa2};
    assign num1_wire_mul={24'b0,1'b1,mantissa1};
    assign num2_wire_mul={24'b0,1'b1,mantissa2};

    wire Float1_zero;
    wire Float2_zero;
    wire Float1_posinfinity;
    wire Float2_posinfinity;
    wire Float1_neginfinity;
    wire Float2_neginfinity;
    wire Float1_nan;
    wire Float2_nan;

    assign Float1_zero= exponent1==8'b0 & mantissa1==23'b0;
    assign Float2_zero= exponent2==8'b0 & mantissa2==23'b0;
    assign Float1_posinfinity= sign1==1'b0 & exponent1==8'b11111111 & mantissa1==23'b0;
    assign Float2_posinfinity= sign2==1'b0 & exponent2==8'b11111111 & mantissa2==23'b0;
    assign Float1_neginfinity= sign1==1'b1 & exponent1==8'b11111111 & mantissa1==23'b0;
    assign Float2_neginfinity= sign2==1'b1 & exponent2==8'b11111111 & mantissa2==23'b0;
    assign Float1_nan= exponent1==8'b11111111 & mantissa1!=23'b0;
    assign Float2_nan= exponent2==8'b11111111 & mantissa2!=23'b0;

    reg[7:0] exponent_diff;
    wire[1:0] need_shift;//0:不移,1:float1右移,2:float2右移
    assign need_shift=(exponent1>exponent2)? 2'd2:
                      (exponent1<exponent2)? 2'd1:
                      2'd0;
    reg[24:0] num_sum;
    reg[24:0] num1_reg_add;
    reg[24:0] num2_reg_add;
    reg[47:0] num_mul;
    reg[47:0] num1_reg_mul;
    reg[47:0] num2_reg_mul;

    reg sign_out;
    reg[7:0] exponent_out;
    reg[22:0] mantissa_out;
    assign Floatout[31:0]={sign_out,exponent_out,mantissa_out};
    
    reg[8:0] exponent_sum;
    always @(*) begin
        if(Float_start)begin
            num1_reg_add=num1_wire_add;
            num2_reg_add=num2_wire_add;
            num1_reg_mul=num1_wire_mul;
            num2_reg_mul=num2_wire_mul;
            if (Float1_nan|Float2_nan) begin
                sign_out=1'bx;
                exponent_out=8'bxxxx_xxxx;
                mantissa_out=23'dx;
            end else if (addmul==1'b0) begin//////////////////FADD
                if ((Float1_zero & Float2_zero)|(Float1_posinfinity & Float2_neginfinity)
                    |(Float1_neginfinity & Float2_posinfinity)) begin/////结果为0
                    sign_out=1'bx;
                    exponent_out=8'b0;
                    mantissa_out=23'b0;
                end else if ((Float1_zero & Float2_posinfinity)|(Float1_posinfinity & (!Float2_neginfinity))
                    |((!Float1_neginfinity) & Float2_posinfinity)) begin/////结果为正无穷
                    sign_out=1'b0;
                    exponent_out=8'b1111_1111;
                    mantissa_out=23'b0;
                end else if ((Float1_zero & Float2_neginfinity)|(Float1_neginfinity & (!Float2_posinfinity))
                    |((!Float1_posinfinity) & Float2_neginfinity)) begin/////结果为负无穷
                    sign_out=1'b1;
                    exponent_out=8'b1111_1111;
                    mantissa_out=23'b0;
                end else if ((Float1_zero & (!Float2_zero))|((!Float1_zero) & Float2_zero)) begin/////其中一个是0 
                    sign_out=Float2_zero? sign1:sign2;
                    exponent_out=Float2_zero? exponent1:exponent2;
                    mantissa_out=Float2_zero? mantissa1:mantissa2;
                end else if (sign1==sign2) begin/////常规同号加法
                    sign_out=sign1;
                    exponent_diff=(exponent1>=exponent2)? exponent1-exponent2:exponent2-exponent1;
                    case (need_shift)
                        2'd0:;
                        2'd1:num1_reg_add=num1_reg_add>>exponent_diff;
                        2'd2:num1_reg_add=num2_reg_add>>exponent_diff; 
                        default:;
                    endcase
                    num_sum=num1_reg_add+num2_reg_add;
                    if (num_sum[24]==1'b0) begin//没有进位
                        exponent_out=(exponent1>=exponent2)? exponent1:exponent2;
                        mantissa_out[22:0]=num_sum[22:0];
                    end else begin//进位
                        exponent_out=(exponent1>=exponent2)? exponent1+1'b1:exponent2+1'b1;
                        mantissa_out[22:0]=(exponent_out==8'b1111_1111)? 23'b0:num_sum[23:1];//exponent达到8'b1111_1111，变成无穷
                    end
                end else if (sign1!=sign2) begin/////常规异号加法
                    case (need_shift)
                        2'd0:begin
                            if (mantissa1==mantissa2) begin
                                sign_out=1'bx;
                                exponent_out=8'b0;
                                mantissa_out=23'b0;
                            end else begin
                                num_sum=(mantissa1>=mantissa2)? num1_reg_add-num2_reg_add:num2_reg_add-num1_reg_add;
                                sign_out=(mantissa1>=mantissa2)? sign1:sign2;
                                case (1'b1)
                                    num_sum[22]:begin 
                                        if (exponent1==8'd0) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd1;
                                            mantissa_out={num_sum[21:0],1'b0};
                                        end
                                    end
                                    num_sum[21]:begin
                                        if (exponent1<=8'd1) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd2;
                                            mantissa_out={num_sum[20:0],2'b0};
                                        end
                                    end
                                    num_sum[20]:begin
                                        if (exponent1<=8'd2) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd3;
                                            mantissa_out={num_sum[19:0],3'b0};
                                        end
                                    end
                                    num_sum[19]:begin
                                        if (exponent1<=8'd3) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd4;
                                            mantissa_out={num_sum[18:0],4'b0};
                                        end
                                    end
                                    num_sum[18]:begin
                                        if (exponent1<=8'd4) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd5;
                                            mantissa_out={num_sum[17:0],5'b0};
                                        end
                                    end
                                    num_sum[17]:begin
                                        if (exponent1<=8'd5) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd6;
                                            mantissa_out={num_sum[16:0],6'b0};
                                        end
                                    end
                                    num_sum[16]:begin
                                        if (exponent1<=8'd6) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd7;
                                            mantissa_out={num_sum[15:0],7'b0};
                                        end
                                    end
                                    num_sum[15]:begin
                                        if (exponent1<=8'd7) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd8;
                                            mantissa_out={num_sum[14:0],8'b0};
                                        end
                                    end
                                    num_sum[14]:begin
                                        if (exponent1<=8'd8) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd9;
                                            mantissa_out={num_sum[13:0],9'b0};
                                        end
                                    end
                                    num_sum[13]:begin
                                        if (exponent1<=8'd9) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd10;
                                            mantissa_out={num_sum[12:0],10'b0};
                                        end
                                    end
                                    num_sum[12]:begin
                                        if (exponent1<=8'd10) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd11;
                                            mantissa_out={num_sum[11:0],11'b0};
                                        end
                                    end
                                    num_sum[11]:begin
                                        if (exponent1<=8'd11) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd12;
                                            mantissa_out={num_sum[10:0],12'b0};
                                        end
                                    end
                                    num_sum[10]:begin
                                        if (exponent1<=8'd12) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd13;
                                            mantissa_out={num_sum[9:0],13'b0};
                                        end
                                    end
                                    num_sum[9]:begin
                                        if (exponent1<=8'd13) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd14;
                                            mantissa_out={num_sum[8:0],14'b0};
                                        end
                                    end
                                    num_sum[8]:begin
                                        if (exponent1<=8'd14) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd15;
                                            mantissa_out={num_sum[7:0],15'b0};
                                        end
                                    end
                                    num_sum[7]:begin
                                        if (exponent1<=8'd15) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd16;
                                            mantissa_out={num_sum[6:0],16'b0};
                                        end
                                    end
                                    num_sum[6]:begin
                                        if (exponent1<=8'd16) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd17;
                                            mantissa_out={num_sum[5:0],17'b0};
                                        end
                                    end
                                    num_sum[5]:begin
                                        if (exponent1<=8'd17) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd18;
                                            mantissa_out={num_sum[4:0],18'b0};
                                        end
                                    end
                                    num_sum[4]:begin
                                        if (exponent1<=8'd18) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd19;
                                            mantissa_out={num_sum[3:0],19'b0};
                                        end
                                    end
                                    num_sum[3]:begin
                                        if (exponent1<=8'd19) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd20;
                                            mantissa_out={num_sum[2:0],20'b0};
                                        end
                                    end
                                    num_sum[2]:begin
                                        if (exponent1<=8'd20) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd21;
                                            mantissa_out={num_sum[1:0],21'b0};
                                        end
                                    end
                                    num_sum[1]:begin
                                        if (exponent1<=8'd21) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd22;
                                            mantissa_out={num_sum[0],22'b0};
                                        end
                                    end
                                    num_sum[0]:begin
                                        if (exponent1<=8'd22) begin
                                            exponent_out=8'b0;
                                            mantissa_out=23'b0;
                                        end else begin
                                            exponent_out=exponent1-5'd23;
                                            mantissa_out={23'b0};
                                        end
                                    end
                                    default:;
                                endcase
                            end
                        end
                        2'd1:begin
                            exponent_diff=exponent2-exponent1;
                            num1_reg_add=num1_reg_add>>exponent_diff;
                            num_sum=num2_reg_add-num1_reg_add;
                            sign_out=sign2;
                            exponent_out=(num_sum[23]==1'b1)? exponent2:exponent2-1'b1;
                            mantissa_out=(num_sum[23]==1'b1)? num_sum[22:0]:{num_sum[21:0],1'b0};
                        end
                        2'd2:begin
                            exponent_diff=exponent1-exponent2;
                            num2_reg_add=num2_reg_add>>exponent_diff;
                            num_sum=num1_reg_add-num2_reg_add;
                            sign_out=sign1;
                            exponent_out=(num_sum[23]==1'b1)? exponent1:exponent1-1'b1;
                            mantissa_out=(num_sum[23]==1'b1)? num_sum[22:0]:{num_sum[21:0],1'b0};
                        end 
                        default:; 
                    endcase
                end
            end else begin////////////////FMUL
                if (Float1_zero|Float2_zero) begin//结果是0
                    sign_out=1'bx;
                    exponent_out=8'b0;
                    mantissa_out=23'b0;
                end else if (!Float1_zero & !Float2_zero & 
                    (Float1_posinfinity|Float1_neginfinity|Float2_posinfinity|Float2_neginfinity)) begin//结果是无穷
                    sign_out=(sign1==sign2)? 1'b0:1'b1;
                    exponent_out=8'b1111_1111;
                    mantissa_out=23'b0;
                end else begin//常规乘法
                    sign_out=(sign1==sign2)? 1'b0:1'b1;
                    num_mul=$unsigned(num1_reg_mul)*$unsigned(num2_reg_mul);
                    exponent_sum=exponent1+exponent2;
                    exponent_out=(num_mul[47]==1'b1)? ((exponent_sum>=8'd254)? 8'd255:exponent1+exponent2+1'b1):
                                                      ((exponent_sum>=8'd255)? 8'd255:exponent1+exponent2);//判断是否溢出
                    mantissa_out[22:0]=(exponent_out==8'd255)? 23'b0:((num_mul[47==1'b1])? num_mul[46:24]:num_mul[45:23]);
                end 
            end
        end
    end
endmodule
