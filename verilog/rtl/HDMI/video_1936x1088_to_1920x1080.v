module video_1936x1088_to_1920x1080 (
    input           pixel_clk,
    input           rst_n,

    input           i_hs,
    input           i_vs,
    input           i_de,
    
    output          o_hs,
    output          o_vs,
    output          o_de
);

//1920*1080 分辨率时序参数,60fps 130MHZ
parameter  H_BACK   =  11'd40;  //行显示后沿
parameter  H_DISP   =  11'd1936; //行有效数据
parameter  H_FRONT  =  11'd28;   //行显示前沿
parameter  H_TOTAL  =  11'd2004; //行扫描周期

parameter  V_BACK   =  11'd18;   //场显示后沿
parameter  V_DISP   =  11'd1088;  //场有效数据
parameter  V_FRONT  =  11'd3;    //场显示前沿
parameter  V_TOTAL  =  11'd1109;  //场扫描周期


    reg [11:0]  cnt_h;
    //行计数器对像素时钟计数
    always @(posedge pixel_clk ) begin
        if (!rst_n)
            cnt_h <= 12'd0;
        else begin
            if(i_hs)
                cnt_h <= cnt_h + 1'b1;
            else 
                cnt_h <= 12'd0;
        end
    end

    reg         i_hs_dly;
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n) begin
            i_hs_dly <= 1'b0;
        end else begin
            i_hs_dly <= i_hs;
        end
    end

    wire i_hs_neg  = i_hs_dly & ~i_hs;

    reg [11:0]  cnt_v;
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_v <= 12'd0;
        end else begin
            if (i_vs == 1'b0) begin
                cnt_v <= 12'd0;
            end else if (i_hs_neg) begin
                cnt_v <= cnt_v + 1'b1;
            end else begin
                cnt_v <= cnt_v;
            end
        end
    end

    assign o_hs = ((cnt_h>8) && (cnt_h<H_TOTAL-8)) ? 1'b1 : 1'b0;
    assign o_vs = ((cnt_v>6) && (cnt_v<V_TOTAL-2)) ? 1'b1 : 1'b0;
    assign o_de = (((cnt_h >= H_BACK+8) && (cnt_h < H_BACK+H_DISP-8))
                    && ((cnt_v >= V_BACK+4) && (cnt_v < V_BACK+V_DISP-4)))
                    ? 1'b1 : 1'b0;

endmodule