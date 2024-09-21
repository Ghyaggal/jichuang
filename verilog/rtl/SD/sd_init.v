module sd_init (
    input clk,
    input clk_shift,
    input rst_n,

    input miso,
    output reg cs_n,
    output reg mosi,
    output reg init_end
);

    parameter CMD0 = {8'h40,8'h00,8'h00,8'h00,8'h00,8'h95}, //复位指令
        CMD8 = {8'h48,8'h00,8'h00,8'h01,8'haa,8'h87}, //查询电压指令
        CMD55 = {8'h77,8'h00,8'h00,8'h00,8'h00,8'hff},//应用指令告知指令
        ACMD41= {8'h69,8'h40,8'h00,8'h00,8'h00,8'hff}; //应用指令
    
    parameter CNT_WAIT_MAX = 32'd1000; //上电后同步过程等待时钟计数最大值
    
    parameter IDLE = 4'b0000, //初始状态
        SEND_CMD0 = 4'b0001, //CMD0发送状态
        CMD0_ACK = 4'b0011, //CMD0响应状态
        SEND_CMD8 = 4'b0010, //CMD8发送状态
        CMD8_ACK = 4'b0110, //CMD8响应状态
        SEND_CMD55 = 4'b0111, //CMD55发送状态
        CMD55_ACK = 4'b0101, //CMD55响应状态
        SEND_ACMD41 = 4'b0100, //ACMD41发送状态
        ACMD41_ACK = 4'b1100, //ACMD41响应状态
        INIT_END = 4'b1101; //初始化完成状态

    reg [31:0] cnt_wait ; //上电同步时钟计数器
    reg [3:0] state ; //状态机状态
    reg [7:0] cnt_cmd_bit ; //指令比特计数器
    reg miso_dly ; //主输入从输出信号打一拍
    reg ack_en ; //响应使能信号
    reg [39:0] ack_data ; //响应数据
    reg [7:0] cnt_ack_bit ; //响应数据字节计数


    //cnt_wait:上电同步时钟计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_wait <= 32'd0;
        end else if (cnt_wait >= CNT_WAIT_MAX) begin
            cnt_wait <= CNT_WAIT_MAX;
        end else begin
            cnt_wait <= cnt_wait + 1'b1;
        end
    end

    //state:状态机状态跳转
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (cnt_wait == CNT_WAIT_MAX) begin
                        state <= SEND_CMD0;
                    end else begin
                        state <= state;
                    end
                end 

                SEND_CMD0: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        state <= CMD0_ACK;
                    end else begin
                        state <= state;
                    end
                end

                CMD0_ACK: begin
                    if (cnt_ack_bit == 8'd48) begin
                        if (ack_data[39:32] == 8'h01) begin
                            state <= SEND_CMD8;
                        end else begin
                            state <= SEND_CMD0;
                        end
                    end else begin
                        state <= state;
                    end
                end

                SEND_CMD8: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        state <= CMD8_ACK;
                    end else begin
                        state <= state;
                    end
                end

                CMD8_ACK: begin
                    if (cnt_ack_bit == 8'd48) begin
                        if (ack_data[11:8] == 4'b0001) begin
                            state <= SEND_CMD55;
                        end else begin
                            state <= SEND_CMD8;
                        end
                    end else begin
                        state <= state;
                    end
                end

                SEND_CMD55: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        state <= CMD55_ACK;
                    end else begin
                        state <= state;
                    end
                end

                CMD55_ACK: begin
                    if (cnt_ack_bit == 8'd48) begin
                        if (ack_data[39:32] == 8'h01) begin
                            state <= SEND_ACMD41;
                        end else begin
                            state <= SEND_CMD55;
                        end
                    end else begin
                        state <= state;
                    end
                end

                SEND_ACMD41: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        state <= ACMD41_ACK;
                    end else begin
                        state <= state;
                    end
                end

                ACMD41_ACK: begin
                    if (cnt_ack_bit == 8'd48) begin
                        if (ack_data[39:32] == 8'h00) begin
                            state <= INIT_END;
                        end else begin
                            state <= SEND_CMD55;
                        end
                    end else begin
                        state <= state;
                    end
                end

                INIT_END: begin
                    state <= state;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    //cs_n,mosi,init_end,cnt_cmd_bit
    //片选信号,主输出从输入信号,初始化结束信号,指令比特计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs_n <= 1'b1;
            mosi <= 1'b1;
            init_end <= 1'b0;
            cnt_cmd_bit <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    cs_n <= 1'b1;
                    mosi <= 1'b1;
                    init_end <= 1'b0;
                    cnt_cmd_bit <= 8'd0;
                end 

                SEND_CMD0: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        cnt_cmd_bit <= 8'd0;
                    end else begin
                        cs_n <= 1'b0;
                        mosi <= CMD0[8'd47 - cnt_cmd_bit];
                        init_end <= 1'b0;
                        cnt_cmd_bit <= cnt_cmd_bit + 1'b1;
                    end
                end

                CMD0_ACK: begin
                    if (cnt_ack_bit == 8'd47) begin
                        cs_n <= 1'b1;
                    end else begin
                        cs_n <= 1'b0;
                    end
                end

                SEND_CMD8: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        cnt_cmd_bit <= 8'd0;
                    end else begin
                        cs_n <= 1'b0;
                        mosi <= CMD8[8'd47 - cnt_cmd_bit];
                        init_end <= 1'b0;
                        cnt_cmd_bit <= cnt_cmd_bit + 1'b1;
                    end
                end

                CMD8_ACK: begin
                    if (cnt_ack_bit == 8'd47) begin
                        cs_n <= 1'b1;
                    end else begin
                        cs_n <= 1'b0;
                    end
                end

                SEND_CMD55: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        cnt_cmd_bit <= 8'd0;
                    end else begin
                        cs_n <= 1'b0;
                        mosi <= CMD55[8'd47 - cnt_cmd_bit];
                        init_end <= 1'b0;
                        cnt_cmd_bit <= cnt_cmd_bit + 1'b1;
                    end
                end


                CMD55_ACK: begin
                    if (cnt_ack_bit == 8'd47) begin
                        cs_n <= 1'b1;
                    end else begin
                        cs_n <= 1'b0;
                    end
                end

                SEND_ACMD41: begin
                    if (cnt_cmd_bit == 8'd48) begin
                        cnt_cmd_bit <= 8'd0;
                    end else begin
                        cs_n <= 1'b0;
                        mosi <= ACMD41[8'd47 - cnt_cmd_bit];
                        init_end <= 1'b0;
                        cnt_cmd_bit <= cnt_cmd_bit + 1'b1;
                    end
                end

                ACMD41_ACK: begin
                    if (cnt_ack_bit == 8'd47) begin
                        cs_n <= 1'b1;
                    end else begin
                        cs_n <= 1'b0;
                    end
                end

                INIT_END: begin
                    cs_n <= 1'b1;
                    mosi <= 1'b1;
                    init_end <= 1'b1;
                end

                default: begin
                    cs_n <= 1'b1;
                    mosi <= 1'b1;
                end
            endcase
        end
    end

    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            miso_dly <= 1'b0;
        end else begin
            miso_dly <= miso;
        end
    end

    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            ack_en <= 1'b0;
        end else if (cnt_ack_bit == 8'd47) begin
            ack_en <= 1'b0;
        end else if ((miso == 1'b0)&&(miso_dly==1'b1)&&(cnt_ack_bit==8'd0)) begin
            ack_en <= 1'b1;
        end else begin
            ack_en <= ack_en;
        end
    end

    always @(posedge clk_shift or negedge rst_n) begin
        if (!rst_n) begin
            ack_data <= 8'd0;
            cnt_ack_bit <= 8'd0;
        end else if (ack_en == 1'b1) begin
            cnt_ack_bit <= cnt_ack_bit + 1'b1;
            if (cnt_ack_bit < 8'd40) begin
                ack_data <= {ack_data[38:0], miso_dly};
            end else begin
                ack_data <= ack_data;
            end
        end else begin
            cnt_ack_bit <= 8'd0;
        end
    end

endmodule