`timescale 1ps/1ps
module test;
    reg clk = 1'b1;
    always #10 clk = ~clk;
    reg rst_n = 1'b0;

    reg iValid = 1'b0;
    reg [7:0] iData = 0;

    wire matrix_vs;
    wire matrix_hs;

    wire oValid;
    wire [7:0] oData_11;
    wire [7:0] oData_12;
    wire [7:0] oData_13;
    wire [7:0] oData_21;
    wire [7:0] oData_22;
    wire [7:0] oData_23;
    wire [7:0] oData_31;
    wire [7:0] oData_32;
    wire [7:0] oData_33;

    initial begin
        #20 rst_n <= 1'b1;
        #20 iValid <= 1'b1;
        // 第一行数据
        repeat(640) begin
            iData <= iData + 1;
            #20;
        end
        iValid <= 1'b0;

        #100 iValid <= 1'b1;
        // 第二行数据
        repeat(640) begin
            iData <= iData + 1;
            #20;
        end
        iValid <= 1'b0;

        #100 iValid <= 1'b1;
        // 第三行数据
        repeat(640) begin
            iData <= iData + 1;
            #20;
        end
        #500 $stop;
    end
    

vip_matrix_generate_3x3_8bit vip_matrix_generate_3x3_8bit_inst(   
    .clk                (clk),  
    .rst_n              (rst_n), 
    .per_frame_vsync    (iValid),
    .per_frame_href     (iValid),
    .per_frame_clken    (iValid),
    .per_img_y          (iData), 
    .matrix_frame_vsync (),
    .matrix_frame_href  (),
    .matrix_frame_clken (oValid),
    .matrix_p11         (oData_11),
    .matrix_p12         (oData_12), 
    .matrix_p13         (oData_13),
    .matrix_p21         (oData_21), 
    .matrix_p22         (oData_22), 
    .matrix_p23         (oData_23),
    .matrix_p31         (oData_31), 
    .matrix_p32         (oData_32), 
    .matrix_p33         (oData_33)
);



endmodule
