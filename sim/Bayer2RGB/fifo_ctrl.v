//延迟一个clk
module fifo_ctrl
#(
    parameter H = 10'd3,//图像高
    parameter W = 10'd640//图像宽
)
(
    input clk,
    input vs,
    input de,
    input rst_n,
    input  [7:0] shiftin,  //输入的数据，延迟一个周期就是第三行数据，为什么？为了与第二第一行数据保持同步
    output  [7:0] taps2x,   //输出的数据，第二行数据
    output  [7:0] taps1x    //输出的数据，第一行数据   
);

wire [7:0] rd_data1 ;//移位寄存器宽度1，深度1024
wire [7:0] rd_data2 ;//第二级移位寄存器
assign taps2x = rd_data1;
assign taps1x = rd_data2;
reg [9:0] cnt_row;
reg de_d,vs_d;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        cnt_row<=10'd0;
    else if(!de && de_d)
        cnt_row<=cnt_row+1;
    else if(!vs && vs_d)
        cnt_row<=10'd0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        de_d<=1'b0;vs_d<=1'b0;
    end
    else begin
        de_d<=de;vs_d<=vs;
    end
end
wire wr_en1,rd_en1,wr_en2,rd_en2;
assign wr_en1 = (de && cnt_row < H-1)? 1'b1:1'b0;//不写最后一行，0~766
assign rd_en1 = (de && cnt_row > 0  )? 1'b1:1'b0;//从第一行开始读，1~767
assign wr_en2 = (de && cnt_row < H-2)? 1'b1:1'b0;//不写最后两行，0~765
assign rd_en2 = (de && cnt_row > 1  )? 1'b1:1'b0;//从第二行开始读，2~767

//fifo深度 >= 2*W
 line_shift_fifo fifo_row2 (
  .clk                (clk       ),      // input
  .rst                (!rst_n    ),      // input
  .we              (wr_en1    ),      // input
  .di            (shiftin   ),      // input
  .full_flag            (          ),      // output
  .re              (rd_en1    ),      // input
  .do            (rd_data1  ),      // output
  .empty_flag           (          )
);

 line_shift_fifo fifo_row1 (
  .clk                (clk       ),      // input
  .rst                (!rst_n    ),      // input
  .we              (wr_en2    ),      // input
  .di            (shiftin   ),      // input
  .full_flag            (          ),      // output
  .re              (rd_en2    ),      // input
  .do            (rd_data2  ),      // output
  .empty_flag           (          )
);



endmodule
