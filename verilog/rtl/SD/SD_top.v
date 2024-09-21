module SD_top (
    input clk_normal,
    input clk_shift,
    input rst_n,

	input [1:0]SD_D,
    output SD_CLK,
    input miso,
    output cs_n,
    output mosi,
    output init_end,

    input rd_addr_reset,
    input rd_stop,
    input rd_retro,
    input  [31:0] rd_addr_setting,
    input  rd_en,
    output rd_busy,
    output rd_data_en,
    output [15:0] rd_data,
    output bin_read_over,
    output frame_read_over,
    output [15:0] read_data_cnt,
    output [7:0] read_frame_cnt,
    output one_frame_finish
);

    assign SD_CLK = clk_shift;

    wire cs_n_i;
    wire mosi_i;

    sd_init sd_init_inst(
        .clk        (clk_normal),
        .clk_shift  (clk_shift),
        .rst_n      (rst_n),
        .miso       (miso),
        .cs_n       (cs_n_i),
        .mosi       (mosi_i),
        .init_end   (init_end)
    );

    wire cs_n_r;
    wire mosi_r;
    wire read_end;
    wire [31:0] rd_addr;

    sd_read sd_read_inst(
        .clk        (clk_normal),
        .clk_shift  (clk_shift),
        .rst_n      (rst_n),
        .miso       (miso),
        .rd_en      (init_end & rd_en),
        .rd_addr    (rd_addr),
        .rd_busy    (rd_busy),
        .rd_data_en (rd_data_en),
        .rd_data    (rd_data),
        .cs_n       (cs_n_r),
        .mosi       (mosi_r),
        .read_end   (read_end)
    );

    sd_rd_ctrl sd_rd_ctrl_inst(
        .clk                (clk_normal),
        .rst_n              (rst_n),
        .rd_addr_reset      (rd_addr_reset),
        .rd_stop            (rd_stop),
        .rd_retro           (rd_retro),
        .rd_addr_setting    (rd_addr_setting),
        .read_end           (read_end),
        .rd_addr            (rd_addr),
        .bin_read_over      (bin_read_over),
        .frame_read_over    (frame_read_over),
        .read_data_cnt      (read_data_cnt),
        .read_frame_cnt     (read_frame_cnt),
        .one_frame_finish   (one_frame_finish)
    );

    assign cs_n = (init_end) ? cs_n_r : cs_n_i;
    assign mosi = (init_end) ? mosi_r : mosi_i;

endmodule