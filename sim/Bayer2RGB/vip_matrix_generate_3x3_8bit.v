module  vip_matrix_generate_3x3_8bit
(   input             clk,  
    input             rst_n, 
    input             per_frame_vsync,
    input             per_frame_href,
    input             per_frame_clken,
    input      [7:0]  per_img_y, 
    output            matrix_frame_vsync,
    output            matrix_frame_href,
    output            matrix_frame_clken,
    output reg [7:0]  matrix_p11,
    output reg [7:0]  matrix_p12, 
    output reg [7:0]  matrix_p13,
    output reg [7:0]  matrix_p21, 
    output reg [7:0]  matrix_p22, 
    output reg [7:0]  matrix_p23,
    output reg [7:0]  matrix_p31, 
    output reg [7:0]  matrix_p32, 
    output reg [7:0]  matrix_p33
);

//wire define
wire [7:0] row1_data;  
wire [7:0] row2_data;  
wire       read_frame_href;
wire       read_frame_clken;

//reg define
reg  [7:0] row3_data_r;  
reg  [1:0] per_frame_vsync_r;
reg  [1:0] per_frame_href_r;
reg  [1:0] per_frame_clken_r;
 

wire matrix_frame_vsync_r;
wire matrix_frame_href_r;
wire matrix_frame_clken_r;

assign read_frame_href    = per_frame_href_r[0] ;
assign read_frame_clken   = per_frame_clken_r[0];
assign matrix_frame_vsync_r = per_frame_vsync_r[1];
assign matrix_frame_href_r  = per_frame_href_r[1] ;
assign matrix_frame_clken_r = per_frame_clken_r[1];

wire  [7:0] row3_data;  
//当前数据放在第3行
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        row3_data_r <= 0;
    else begin
        if(per_frame_clken)
            row3_data_r <= per_img_y ;
        else
            row3_data_r <= row3_data_r ;
    end
end

delay20 delay20_inst1(
    .clk        (clk),
    .data_in    (row3_data_r),
    .data_out   (row3_data)
);

wire [7:0] row2_data_r;

//用于存储列数据的RAM
line_shift  u_line_shift_ram_8bit
(
    .clk          (clk), //input clock, 
    .de_i         (per_frame_clken), //input clken,
    .data_i       (per_img_y), //input [7:0]  shiftin,
    .data1_o      (row2_data_r),  // output  [7:0]  taps0x,   
    .data2_o      (row1_data)  // output  [7:0]  taps1x    
);

delay11 delay11_inst2(
    .clk        (clk),
    .data_in    (row2_data_r),
    .data_out   (row2_data)
);

delay11_3 delay11_3_inst1(
    .clk        (clk),
    .data_in    ({matrix_frame_vsync_r, matrix_frame_href_r, matrix_frame_clken_r}),
    .data_out   ({matrix_frame_vsync, matrix_frame_href, matrix_frame_clken})
);



//将同步信号延迟两拍，用于同步化处理
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        per_frame_vsync_r <= 0;
        per_frame_href_r  <= 0;
        per_frame_clken_r <= 0;
    end
    else begin
        per_frame_vsync_r <= { per_frame_vsync_r[0], per_frame_vsync };
        per_frame_href_r  <= { per_frame_href_r[0],  per_frame_href  };
        per_frame_clken_r <= { per_frame_clken_r[0], per_frame_clken };
    end
end

//在同步处理后的控制信号下，输出图像矩阵
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
    end
    else if(read_frame_href) begin
        if(read_frame_clken) begin
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
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
    end
end

endmodule 