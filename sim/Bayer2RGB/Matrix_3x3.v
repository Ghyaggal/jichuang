//耗时2clk
module  Matrix_3X3 
(
    input            clk,  
    input            rst_n,
         
    input            vs,
    input            hs,
    input            de,
    input     [7:0]       data_in,
     
    output           matrix_vs,
    output           matrix_hs,
    output           matrix_de,
    output reg  [7:0]  matrix_p11,
    output reg  [7:0]  matrix_p12, 
    output reg  [7:0]  matrix_p13,
    output reg  [7:0]  matrix_p21, 
    output reg  [7:0]  matrix_p22, 
    output reg  [7:0]  matrix_p23,
    output reg  [7:0]  matrix_p31, 
    output reg  [7:0]  matrix_p32, 
    output reg  [7:0]  matrix_p33
);
  
wire  [7:0]  row1_data;  
wire  [7:0]  row2_data;  
wire  read_vs;
wire  read_de;
//wire  data_bw;
reg  [7:0]  row3_data;  
reg  [1:0]  vs_r;
reg  [1:0]  hs_r;
reg  [1:0]  de_r;

assign read_vs    =  hs_r[0];
assign read_de    =  de_r[0];
assign matrix_vs  =  vs_r[1];
assign matrix_hs  =  hs_r[1];
assign matrix_de  =  de_r[1];//延迟两个周期产生矩阵

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        row3_data <= 0;
    else begin
        if(de)
            row3_data <= data_in ;
        else
            row3_data <= row3_data ;
    end
end
//产生平行数据,1clk
fifo_ctrl  fifo_ctrl_m0
(
    .clk          (clk),
    .vs           (vs),
    .de           (de),
    .rst_n        (rst_n),
    .shiftin        (data_in  ),   //二值化后的数据1bit，且取反，1代表白色，0代表黑色
    .taps2x         (row2_data),   
    .taps1x         (row1_data)    
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        vs_r <= 0;
        hs_r <= 0;
        de_r <= 0;
    end
    else begin
        vs_r <= { vs_r[0],vs };
        hs_r <= { hs_r[0],hs };
        de_r <= { de_r[0],de };
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_p11, matrix_p12, matrix_p13} <=  24'b0;//初始化为黑色
        {matrix_p21, matrix_p22, matrix_p23} <=  24'b0;
        {matrix_p31, matrix_p32, matrix_p33} <=  24'b0;
    end
    else if(read_vs) begin //延迟一个clk与输出的平行数据同步
                if(read_de) begin
                    {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, row1_data};
                    {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, row2_data};
                    {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, row3_data};
                end
                else begin
                    {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p11, matrix_p12, matrix_p13};
                    {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p21, matrix_p22, matrix_p23};
                    {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p31, matrix_p32, matrix_p33};
                end	
    end
    else begin
        {matrix_p11, matrix_p12, matrix_p13} <=  24'b0;
        {matrix_p21, matrix_p22, matrix_p23} <=  24'b0;
        {matrix_p31, matrix_p32, matrix_p33} <=  24'b0;
    end
end
 
endmodule 
