module video_driver(
    input           pixel_clk,
    input           sys_rst_n,
    
    //RGB接口
    output          video_hs,     //行同步信号
    output          video_vs,     //场同步信号
    output          video_de,     //数据使能
    output  [7:0]   video_data,    
    
    input   [7:0]  pixel_data,   //像素点数据
    // output  [11:0]  pixel_xpos,   //像素点横坐标
    // output  [11:0]  pixel_ypos,   //像素点纵坐标
    output          data_req,
    output  reg     TFT_begin
);

//parameter define

//1936*1088 分辨率时序参数,60fps 130MHZ
parameter  H_SYNC   =  11'd12;  //行同步
parameter  H_BACK   =  11'd40;  //行显示后沿
parameter  H_DISP   =  11'd1936; //行有效数据
parameter  H_FRONT  =  11'd28;   //行显示前沿
parameter  H_TOTAL  =  11'd2016; //行扫描周期

parameter  V_SYNC   =  11'd4;    //场同步
parameter  V_BACK   =  11'd18;   //场显示后沿
parameter  V_DISP   =  11'd1088;  //场有效数据
parameter  V_FRONT  =  11'd3;    //场显示前沿
parameter  V_TOTAL  =  11'd1113;  //场扫描周期

//reg define
reg  [11:0]  cnt_h;
reg  [11:0]  cnt_v;

//wire define
wire        video_en;
wire [11:0] h_disp;
wire [11:0] v_disp;

//*****************************************************
//**                    main code
//*****************************************************

assign video_de  = video_en;

assign video_hs  = ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;  //行同步信号赋值
assign video_vs  = ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;  //场同步信号赋值

//使能RGB数据输出
assign video_en  = (((cnt_h >= H_SYNC+H_BACK) && (cnt_h < H_SYNC+H_BACK+H_DISP))
                 &&((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                 ?  1'b1 : 1'b0;

//RGB888数据输出
assign video_data = video_en ? pixel_data : 8'd0;

//请求像素点颜色数据输入
assign data_req = (((cnt_h >= H_SYNC+H_BACK-1'b1) && 
                    (cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
                  && ((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                  ?  1'b1 : 1'b0;

// //像素点坐标
// assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 11'd0;
// assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 11'd0;


//行计数器对像素时钟计数
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        cnt_h <= 11'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)
            cnt_h <= cnt_h + 1'b1;
        else 
            cnt_h <= 11'd0;
    end
end

//场计数器对行计数
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        cnt_v <= 11'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else 
            cnt_v <= 11'd0;
    end
end

always@(posedge pixel_clk or negedge sys_rst_n)
begin
    if(!sys_rst_n)
        TFT_begin <= 1'b0;
    else if((cnt_h==0)&&(cnt_v==0))
        TFT_begin <= 1'b1;
    else 
        TFT_begin <= 1'b0;
end
	

endmodule