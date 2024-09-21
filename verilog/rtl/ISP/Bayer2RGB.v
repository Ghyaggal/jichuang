module Bayer2RGB
(
    input clk,
    input rst_n,
    input Bayer2RGB_en,
    input per_img_vsync,
    input per_img_href,
    input per_img_de,
    input [7:0] per_img_gray,

    output reg post_img_vsync,
    output reg post_img_href,
    output reg post_img_de,
    output reg [7:0] post_img_red,
    output reg [7:0] post_img_green,
    output reg [7:0] post_img_blue
    );

    wire          matrix_img_vsync;
    wire          matrix_img_href;
    wire          matrix_img_de;
    wire [7:0]    matrix_p11;
    wire [7:0]    matrix_p12;
    wire [7:0]    matrix_p13;
    wire [7:0]    matrix_p21;
    wire [7:0]    matrix_p22;
    wire [7:0]    matrix_p23;
    wire [7:0]    matrix_p31;
    wire [7:0]    matrix_p32;
    wire [7:0]    matrix_p33;

    vip_matrix_generate_3x3_8bit Matrix_Generate_3x3_8Bit_inst
    (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .per_frame_vsync            (per_img_vsync),
        .per_frame_href             (per_img_href),
        .per_frame_clken            (per_img_de),
        .per_img_y                  (per_img_gray),
        .matrix_frame_vsync         (matrix_img_vsync),
        .matrix_frame_href          (matrix_img_href),
        .matrix_frame_clken         (matrix_img_de),
        .matrix_p11                 (matrix_p11),
        .matrix_p12                 (matrix_p12),
        .matrix_p13                 (matrix_p13),
        .matrix_p21                 (matrix_p21),
        .matrix_p22                 (matrix_p22),
        .matrix_p23                 (matrix_p23),
        .matrix_p31                 (matrix_p31),
        .matrix_p32                 (matrix_p32),
        .matrix_p33                 (matrix_p33)
        );


    //-------------------------------------------------------------------
    
    reg             [1:0]           matrix_img_vsync_r1;
    reg             [1:0]           matrix_img_href_r1;
    reg             [1:0]           matrix_img_de_r1;
    reg             [7:0]           matrix_p22_r1;
    reg [11:0]  hcnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcnt <= 11'd0;
        end else begin
            if (matrix_img_de) begin
                hcnt <= hcnt + 1'b1;
            end else begin
                hcnt <= 11'd0;
            end
        end
    end


    reg         matrix_img_de_dly;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_img_de_dly <= 1'b0;
        end else begin
            matrix_img_de_dly <= matrix_img_de;
        end
    end

    wire matrix_img_de_neg  = matrix_img_de_dly & ~matrix_img_de;

    reg [11:0]  vcnt;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vcnt <= 12'd0;
        end else begin
            if (matrix_img_vsync == 1'b0) begin
                vcnt <= 12'd0;
            end else if (matrix_img_de_neg) begin
                vcnt <= vcnt + 1'b1;
            end else begin
                vcnt <= vcnt;
            end
        end
    end

    wire [1:0] hvcnt_num_r;
    assign hvcnt_num_r = {hcnt[0], vcnt[0]};

    //Hg Vg
    reg [7:0] Data_Hg, Data_Vg;
    always @(posedge clk) begin
        if (matrix_p21 > matrix_p23) Data_Hg <= matrix_p21 - matrix_p23;
        else Data_Hg <= matrix_p23 - matrix_p21;
    end

    always @(posedge clk) begin
        if (matrix_p12 > matrix_p32) Data_Vg <= matrix_p12 - matrix_p32;
        else Data_Vg <= matrix_p32 - matrix_p12;
    end

    //Drb1 Drb2
    reg [7:0] Data_Drb1, Data_Drb2;
    always @(posedge clk) begin
        if (matrix_p11 > matrix_p33) Data_Drb1 <= matrix_p11 - matrix_p33;
        else Data_Drb1 <= matrix_p33 - matrix_p11;
    end

    always @(posedge clk) begin
        if (matrix_p13 > matrix_p31) Data_Drb2 <= matrix_p13 - matrix_p31;
        else Data_Drb2 <= matrix_p31 - matrix_p13;
    end

    reg [7:0]    matrix_p11_r;
    reg [7:0]    matrix_p12_r;
    reg [7:0]    matrix_p13_r;
    reg [7:0]    matrix_p21_r;
    reg [7:0]    matrix_p22_r;
    reg [7:0]    matrix_p23_r;
    reg [7:0]    matrix_p31_r;
    reg [7:0]    matrix_p32_r;
    reg [7:0]    matrix_p33_r;

    always @(posedge clk) begin
        matrix_p11_r <= matrix_p11;
        matrix_p12_r <= matrix_p12;
        matrix_p13_r <= matrix_p13;
        matrix_p21_r <= matrix_p21;
        matrix_p22_r <= matrix_p22;
        matrix_p23_r <= matrix_p23;
        matrix_p31_r <= matrix_p31;
        matrix_p32_r <= matrix_p32;
        matrix_p33_r <= matrix_p33;
    end
    //-------------------------------------------------------------------
    localparam OddLINE_OddPOINT = 2'b00;
    localparam OddLINE_Even_POINT = 2'b01;
    localparam EvenLINE_OddPOINT = 2'b10;
    localparam EvenLINE_EvenPOINT = 2'b11;

    reg [9:0] post_img_red_r;
    reg [9:0] post_img_green_r;
    reg [9:0] post_img_blue_r;

    always @(posedge clk) begin
        case (hvcnt_num_r)
             EvenLINE_EvenPOINT: begin   //Center Green
                 post_img_red_r <= (matrix_p12_r + matrix_p32_r)>>1;
                 post_img_green_r <= matrix_p22_r;
                 post_img_blue_r <= (matrix_p21_r + matrix_p23_r)>>1;
             end
            
             OddLINE_Even_POINT: begin     //Center Blue
                 if (Data_Hg < Data_Vg) begin
                     post_img_green_r <= (matrix_p21_r + matrix_p23_r)>>1;
                 end else if (Data_Hg > Data_Vg) begin
                     post_img_green_r <= (matrix_p12_r + matrix_p32_r)>>1;
                 end else begin
                     post_img_green_r <= (matrix_p12_r + matrix_p32_r + matrix_p21_r + matrix_p23_r)>>2;
                 end
                 if (Data_Drb1 < Data_Drb2) begin
                     post_img_red_r <= (matrix_p11_r + matrix_p33_r)>>1;
                 end else if (Data_Drb1 > Data_Drb2) begin
                     post_img_red_r <= (matrix_p13_r + matrix_p31_r)>>1;
                 end else begin
                     post_img_red_r <= (matrix_p11_r + matrix_p13_r + matrix_p31_r + matrix_p33_r)>>2;
                 end
                 post_img_blue_r <= matrix_p22_r;
             end        

             EvenLINE_OddPOINT: begin   //Center Red
                 post_img_red_r <= matrix_p22_r;
                 if (Data_Hg < Data_Vg) begin
                     post_img_green_r <= (matrix_p21_r + matrix_p23_r)>>1;
                 end else if (Data_Hg > Data_Vg) begin
                     post_img_green_r <= (matrix_p12_r + matrix_p32_r)>>1;
                 end else begin
                     post_img_green_r <= (matrix_p12_r + matrix_p32_r + matrix_p21_r + matrix_p23_r)>>2;
                 end
                 if (Data_Drb1 < Data_Drb2) begin
                     post_img_blue_r <= (matrix_p11_r + matrix_p33_r)>>1;
                 end else if (Data_Drb1 > Data_Drb2) begin
                     post_img_blue_r <= (matrix_p13_r + matrix_p31_r)>>1;
                 end else begin
                     post_img_blue_r <= (matrix_p11_r + matrix_p13_r + matrix_p31_r + matrix_p33_r)>>2;
                 end
             end

             OddLINE_OddPOINT: begin    //Center Green
                 post_img_red_r <= (matrix_p21_r + matrix_p23_r)>>1;
                 post_img_green_r <= matrix_p22_r;
                 post_img_blue_r <= (matrix_p12_r + matrix_p32_r)>>1;
             end
        endcase
    end

    //----------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_red <= 8'd0;
            post_img_green <= 8'd0;
            post_img_blue <= 8'd0;
        end else if (Bayer2RGB_en) begin
            post_img_red <= post_img_red_r[7:0];
            post_img_green <= post_img_green_r[7:0];
            post_img_blue <= post_img_blue_r[7:0];
        end else begin
            post_img_red <= matrix_p22_r1;
            post_img_green <= matrix_p22_r1;
            post_img_blue <= matrix_p22_r1;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            matrix_img_vsync_r1 <= 2'b0;
            matrix_img_href_r1  <= 2'b0;
            matrix_img_de_r1    <= 2'b0;
            matrix_p22_r1       <= 8'd0;
        end
        else
        begin
            matrix_img_vsync_r1 <= {matrix_img_vsync_r1[0],matrix_img_vsync};
            matrix_img_href_r1  <= {matrix_img_href_r1[0],matrix_img_href};
            matrix_img_de_r1    <= {matrix_img_de_r1[0], matrix_img_de};
            matrix_p22_r1       <= matrix_p22_r;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            post_img_vsync <= 1'b0;
            post_img_href  <= 1'b0;
            post_img_de    <= 1'b0;
        end
        else
        begin
            post_img_vsync <= matrix_img_vsync_r1[1];
            post_img_href  <= matrix_img_href_r1[1];
            post_img_de    <= matrix_img_de_r1[1];
        end
    end

endmodule