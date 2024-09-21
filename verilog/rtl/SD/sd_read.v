module sd_read (
    input clk,
    input clk_shift,
    input rst_n,
    input miso,
    input rd_en,
    input [31:0] rd_addr,

    output rd_busy,
    output reg rd_data_en,
    output reg [15:0] rd_data,
    output reg cs_n,
    output reg mosi,
    output reg read_end
);
    
    parameter IDLE = 3'b000 , //初始状态
    SEND_CMD17 = 3'b001 , //读命令CMD17发送状态
    CMD17_ACK = 3'b011 , //CMD17响应状态
    RD_DATA = 3'b010 , //读数据状态
    RD_END = 3'b110 ; //读结束状态
    parameter DATA_NUM = 12'd256 ; //待读取数据字节数

    wire [47:0] cmd_rd ; //数据读指令

    reg [2:0] state ; //状态机状态
    reg [7:0] cnt_cmd_bit ; //指令比特计数器
    reg ack_en ; //响应使能信号
    reg [7:0] ack_data ; //响应数据
    reg [7:0] cnt_ack_bit ; //响应数据字节计数
    reg [23:0] cnt_data_num; //读出数据个数计数
    reg [3:0] cnt_data_bit; //读数据比特计数器
    reg [2:0] cnt_end ; //结束状态时钟计数
    reg miso_dly ; //主输入从输出信号打一拍
    reg [15:0] rd_data_reg ; //读出数据寄存
    reg [15:0] byte_head ; //读数据字节头
    reg byte_head_en; //读数据字节头使能


    //rd_busy:读操作忙信号
    assign rd_busy = (state != IDLE) ? 1'b1 : 1'b0;

    //cmd_rd:数据读指令
    assign cmd_rd = {8'h51, rd_addr, 8'hff};

    //miso_dly:主输入从输出信号打一拍
    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            miso_dly <= 1'b0;
        end else begin
            miso_dly <= miso;
        end
    end

    //ack_en:响应使能信号
    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            ack_en <= 1'b0;
        end else if (cnt_ack_bit == 8'd15) begin
            ack_en <= 1'b0;
        end else if ((state == CMD17_ACK) && (miso == 1'b0)
                && (miso_dly == 1'b1) && (cnt_ack_bit == 8'd0)) begin
            ack_en <= 1'b1;
        end else begin
            ack_en <= ack_en;            
        end
    end

    //ack_data:响应数据
    //cnt_ack_bit:响应数据字节计数
    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            ack_data <= 8'b0;
            cnt_ack_bit <= 8'd0;
        end else if (ack_en == 1'b1) begin
            cnt_ack_bit <= cnt_ack_bit + 1'b1;
            if (cnt_ack_bit < 8'd8) begin
                ack_data <= {ack_data[6:0], miso_dly};
            end else begin
                ack_data <= ack_data;
            end
        end else begin
            cnt_ack_bit <= 8'd0;
        end
    end


    //state:状态机状态跳转
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (rd_en) begin
                        state <= SEND_CMD17;
                    end else begin
                        state <= state;
                    end
                end 

                SEND_CMD17: begin
                    if (cnt_cmd_bit == 8'd47) begin
                        state <= CMD17_ACK;
                    end else begin
                        state <= state;
                    end
                end

                CMD17_ACK: begin
                    if (cnt_ack_bit == 8'd15) begin
                        if (ack_data == 8'h00) begin
                            state <= RD_DATA;
                        end else begin
                            state <= SEND_CMD17;
                        end
                    end else begin
                        state <= state;
                    end
                end

                RD_DATA: begin
                    if ((cnt_data_num == (DATA_NUM + 1'b1))
                        && (cnt_data_bit == 4'd15)) begin
                        state <= RD_END;        
                    end else begin
                        state <= state;        
                    end
                end

                RD_END: begin
                    if (cnt_end == 3'd7) begin
                        state <= IDLE;
                    end else begin
                        state <= state;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    //cs_n:输出片选信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs_n <= 1'b1;
        end else if (cnt_end == 3'd7) begin
            cs_n <= 1'b1;
        end else if (rd_en == 1'b1) begin
            cs_n <= 1'b0;
        end else begin
            cs_n <= cs_n;
        end
    end

    //cnt_cmd_bit:指令比特计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_cmd_bit <= 8'd0;
        end else if (state == SEND_CMD17) begin
            cnt_cmd_bit <= cnt_cmd_bit + 1'b1;
        end else begin
            cnt_cmd_bit <= 8'd0;
        end
    end

    //mosi:主输出从输入信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mosi <= 1'b1;
        end else if (state == SEND_CMD17) begin
            mosi <= cmd_rd[8'd47 - cnt_cmd_bit];
        end else begin
            mosi <= 1'b1;
        end
    end

    //byte_head:读数据字节头
    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            byte_head <= 16'b0;
        end else if (byte_head_en == 1'b0) begin
            byte_head <= 16'b0;
        end else if (byte_head_en == 1'b1) begin
            byte_head <= {byte_head[14:0], miso};
        end else begin
            byte_head <= byte_head;
        end
    end

    //byte_head_en:读数据字节头使能
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_head_en <= 1'b0;
        end else if (byte_head == 16'hfffe) begin
            byte_head_en <= 1'b0;
        end else if ((state == RD_DATA) && (cnt_data_num == 24'd0)
            && (cnt_data_bit == 4'd0)) begin
            byte_head_en <= 1'b1;
        end else begin
            byte_head_en <= byte_head_en;        
        end
    end

    //cnt_data_bit:读数据比特计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_data_bit <= 4'd0;
        end else if ((state == RD_DATA) && (cnt_data_num >= 24'd1)) begin
            cnt_data_bit <= cnt_data_bit + 1'b1;
        end else begin
            cnt_data_bit <= 4'd0;
        end
    end

    //cnt_data_num:读出数据个数计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_data_num <= 24'd0;
        end else if (state == RD_DATA) begin
            if ((cnt_data_bit == 4'd15) || (byte_head == 16'hfffe)) begin
                cnt_data_num <= cnt_data_num + 24'd1;
            end else begin
                cnt_data_num <= cnt_data_num;
            end
        end else begin
            cnt_data_num <= 24'd0;
        end
    end

    //rd_data_reg:读出数据寄存
    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            rd_data_reg <= 16'd0;
        end else if ((state == RD_DATA) && (cnt_data_num >= 12'd1)
            && (cnt_data_num <= DATA_NUM)) begin
            rd_data_reg <= {rd_data_reg[14:0], miso};
        end else begin
            rd_data_reg <= 16'd0;        
        end
    end

    //rd_data_en:读数据标志信号
    //rd_data:读数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data_en <= 1'b0;
            rd_data <= 16'd0;
        end else if (state == RD_DATA) begin
            if ((cnt_data_bit == 4'd15) && (cnt_data_num <= DATA_NUM)) begin
                rd_data_en <= 1'b1;
                rd_data <= rd_data_reg;
            end else begin
                rd_data_en <= 1'b0;
                rd_data <= rd_data;
            end
        end else begin
            rd_data_en <= 1'b0;
            rd_data <= 16'd0;
        end
    end


    //cnt_end:结束状态时钟计数
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_end <= 3'd0;
        end else if (state == RD_END) begin
            cnt_end <= cnt_end + 1'b1;
        end else begin
            cnt_end <= 3'd0;
        end
    end

    //read_end:结束标志信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_end <= 1'b0;
        end else if ((cnt_data_num == (DATA_NUM + 1'b1))
                        && (cnt_data_bit == 4'd15)) begin
            read_end <= 1'b1;
        end else begin
            read_end <= 1'b0;
        end
    end
endmodule