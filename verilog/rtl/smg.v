module smg (                        //数码管
    input clk,
    input rst_n,
    input [15:0] smg_data,
    output reg [3:0] seg_sel,
    output reg [7:0] seg_led
);
    
    parameter DIVCLK_CNTMAX_1ms = 24999;
    reg [15:0] cnt_1ms = 0;
    reg divclk_reg = 0;

    always @(posedge clk) begin
        if (cnt_1ms == DIVCLK_CNTMAX_1ms) begin
            cnt_1ms <= 16'd0;
            divclk_reg <= ~divclk_reg;
        end else begin
            cnt_1ms <= cnt_1ms + 1'b1;
        end
    end
    
    reg [1:0] cnt;

    always @(posedge cnt_1ms or negedge rst_n) begin
        if (!rst_n) begin
        	cnt <= 2'b00;
        end else if (cnt == 2'b11) begin
            cnt <= 2'b00;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    reg [3:0] data_out;

    always @(*) begin
        case (cnt)
            2'b00: data_out <= smg_data[3:0];
            2'b01: data_out <= smg_data[7:4];
            2'b10: data_out <= smg_data[11:8];
            2'b11: data_out <= smg_data[15:12];
            default: data_out <= 0;
        endcase
    end

    always @(*) begin
        case (cnt)
            2'b00 : seg_sel = 4'b1110;
            2'b01 : seg_sel = 4'b1101;            
            2'b10 : seg_sel = 4'b1011;
            2'b11 : seg_sel = 4'b0111;
            default: seg_sel = 4'b1111;
        endcase
    end

    always @(*) begin
        case (data_out)
            4'h0 : seg_led = 8'h3f;
            4'h1 : seg_led = 8'h06;
            4'h2 : seg_led = 8'h5b;
            4'h3 : seg_led = 8'h4f;
            4'h4 : seg_led = 8'h66;
            4'h5 : seg_led = 8'h6d;
            4'h6 : seg_led = 8'h7d;
            4'h7 : seg_led = 8'h07;
            4'h8 : seg_led = 8'h7f;
            4'h9 : seg_led = 8'h6f;
            4'ha : seg_led = 8'h77;
            4'hb : seg_led = 8'h7c;
            4'hc : seg_led = 8'h39;
            4'hd : seg_led = 8'h5e;
            4'he : seg_led = 8'h79;
            4'hf : seg_led = 8'h71;
            default: seg_led = 8'h3f;
        endcase
    end

endmodule