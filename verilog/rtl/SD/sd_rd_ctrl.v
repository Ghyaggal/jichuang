module sd_rd_ctrl (
    input clk,
    input rst_n,

    input rd_addr_reset,
    input rd_stop,  
    input rd_retro,
    input [31:0] rd_addr_setting,
    input read_end,
    output reg [31:0] rd_addr,
    output reg bin_read_over,
    output reg frame_read_over,
    output reg [15:0] read_data_cnt,
    output reg [7:0] read_frame_cnt,
    output reg one_frame_finish
);

    parameter READ_DATA_CNT_MAX = 8228; //读取一帧图像的次数
    parameter READ_FRAME_MAX = 180; //读取一个文件的总帧数

    reg  rd_addr_reset_state;

    reg read_end_r1, read_end_r2;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            read_end_r1 <= 1'b0;
            read_end_r2 <= 1'b0;
        end
        else begin
            read_end_r1 <= read_end;
            read_end_r2 <= read_end_r1;
        end
    end

    wire read_end_pose = (read_end_r1 & ~read_end_r2);

    //rd_addr_reset_state:rd_addr:复位状态
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_addr_reset_state <= 1'b0;
        end else if (rd_addr_reset) begin
            rd_addr_reset_state <= 1'b1;
        end else begin
            rd_addr_reset_state <= 1'b0;
        end 
    end

    reg [31:0] rd_addr_setting_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_addr_setting_r <= rd_addr_setting;
        end else if (rd_addr_reset_state & bin_read_over) begin
            rd_addr_setting_r <= rd_addr_setting;
        end else if (frame_read_over) begin 
            rd_addr_setting_r <= rd_addr_setting;
        end else begin
            rd_addr_setting_r <= rd_addr_setting_r;
        end
    end

    //rd_addr:地址设置
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_addr <= rd_addr_setting;
        end else if (rd_addr_reset_state & bin_read_over) begin
            rd_addr <= rd_addr_setting;
        end else if (frame_read_over) begin 
            rd_addr <= rd_addr_setting;
        end else if (read_end_pose) begin
            if ((read_data_cnt == READ_DATA_CNT_MAX-1'b1)) begin
                if (rd_stop) begin
                    rd_addr <= rd_addr - 8227;
                end else if (rd_retro) begin
                    if (rd_addr - 16455 > rd_addr_setting_r) begin
                        rd_addr <= rd_addr - 16455;
                    end else begin
                        rd_addr <= rd_addr_setting_r;
                    end
                end else begin
                    rd_addr <= rd_addr + 1;
                end
            end else begin
                rd_addr <= rd_addr + 1;
            end
        end else begin
            rd_addr <= rd_addr;
        end
    end

    // reg [15:0] read_data_cnt;
    // reg [7:0] read_frame_cnt;

    //read_data_cnt:读取一帧图像计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data_cnt <= 16'd0;
            bin_read_over <= 1'b0;
            one_frame_finish <= 1'b0;
        end else if (read_end_pose) begin 
            if (read_data_cnt == READ_DATA_CNT_MAX-1'b1) begin
                read_data_cnt <= 16'd0;
                bin_read_over <= 1'b1;
                one_frame_finish <= 1'b1;
            end else begin
                read_data_cnt <= read_data_cnt + 1'b1;
                bin_read_over <= 1'b0;
            end
        end else begin
            read_data_cnt <= read_data_cnt;
            one_frame_finish <= one_frame_finish;
            bin_read_over <= 1'b0;
        end
    end

    //read_data_cnt:视频文件帧计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_frame_cnt <= 16'd0;
            frame_read_over <= 1'b0;
        end else if (bin_read_over) begin 
            if ((read_frame_cnt == READ_FRAME_MAX-1'b1) | rd_addr_reset_state) begin
                read_frame_cnt <= 16'd0;
                frame_read_over <= 1'b1;
            end else if (rd_stop) begin
                read_frame_cnt <= read_frame_cnt;
                frame_read_over <= 1'b0;
            end else if (rd_retro) begin
                if (read_frame_cnt > 0) begin
                    read_frame_cnt <= read_frame_cnt - 1'b1;
                end else begin
                    read_frame_cnt <= 0;
                end
                frame_read_over <= 1'b0;
            end else begin
                read_frame_cnt <= read_frame_cnt + 1'b1;
                frame_read_over <= 1'b0;
            end
        end else begin
            read_frame_cnt <= read_frame_cnt;
            frame_read_over <= 1'b0;
        end
    end

endmodule