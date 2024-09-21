module PINTO (
    input clk,
    input rst_n,
    input PINTO_en,
    input per_img_vsync,
    input per_img_href,
    input per_img_de,
    input [7:0] per_img_gray,

    output reg post_img_vsync,
    output reg post_img_href,
    output reg post_img_de,
    output reg [7:0] post_img_gray
);

    parameter TH = 150; //坏点阈值

    wire        matrix_img_vsync;
    wire        matrix_img_href;
    wire        matrix_img_de;
    wire [7:0]  matrix_p11;
    wire [7:0]  matrix_p12; 
    wire [7:0]  matrix_p13;
    wire [7:0]  matrix_p14;
    wire [7:0]  matrix_p15;
    wire [7:0]  matrix_p21; 
    wire [7:0]  matrix_p22; 
    wire [7:0]  matrix_p23;
    wire [7:0]  matrix_p24;
    wire [7:0]  matrix_p25;    
    wire [7:0]  matrix_p31; 
    wire [7:0]  matrix_p32; 
    wire [7:0]  matrix_p33;
    wire [7:0]  matrix_p34;
    wire [7:0]  matrix_p35;
    wire [7:0]  matrix_p41; 
    wire [7:0]  matrix_p42; 
    wire [7:0]  matrix_p43;
    wire [7:0]  matrix_p44;
    wire [7:0]  matrix_p45;   
    wire [7:0]  matrix_p51; 
    wire [7:0]  matrix_p52; 
    wire [7:0]  matrix_p53;
    wire [7:0]  matrix_p54;
    wire [7:0]  matrix_p55; 

    vip_matrix_generate_5x5_8bit vip_matrix_generate_5x5_8bit
    (   .clk                    (clk),  
        .rst_n                  (rst_n), 
        .per_frame_vsync        (per_img_vsync),
        .per_frame_href         (per_img_href),
        .per_frame_clken        (per_img_de),
        .per_img_y              (per_img_gray), 
        .matrix_frame_vsync     (matrix_img_vsync),
        .matrix_frame_href      (matrix_img_href),
        .matrix_frame_clken     (matrix_img_de),
        .matrix_p11             (matrix_p11),
        .matrix_p12             (matrix_p12), 
        .matrix_p13             (matrix_p13),
        .matrix_p14             (matrix_p14),
        .matrix_p15             (matrix_p15),
        .matrix_p21             (matrix_p21), 
        .matrix_p22             (matrix_p22), 
        .matrix_p23             (matrix_p23),
        .matrix_p24             (matrix_p24),
        .matrix_p25             (matrix_p25),    
        .matrix_p31             (matrix_p31), 
        .matrix_p32             (matrix_p32), 
        .matrix_p33             (matrix_p33),
        .matrix_p34             (matrix_p34),
        .matrix_p35             (matrix_p35),
        .matrix_p41             (matrix_p41), 
        .matrix_p42             (matrix_p42), 
        .matrix_p43             (matrix_p43),
        .matrix_p44             (matrix_p44),
        .matrix_p45             (matrix_p45),   
        .matrix_p51             (matrix_p51), 
        .matrix_p52             (matrix_p52), 
        .matrix_p53             (matrix_p53),
        .matrix_p54             (matrix_p54),
        .matrix_p55             (matrix_p55)               
    );

//--------------------------------------------------------------------
    reg             [1:0]           matrix_img_de_r1;

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

    reg [7:0]  matrix_p11_r;
    reg [7:0]  matrix_p12_r; 
    reg [7:0]  matrix_p13_r;
    reg [7:0]  matrix_p14_r;
    reg [7:0]  matrix_p15_r;
    reg [7:0]  matrix_p21_r; 
    reg [7:0]  matrix_p22_r; 
    reg [7:0]  matrix_p23_r;
    reg [7:0]  matrix_p24_r;
    reg [7:0]  matrix_p25_r;    
    reg [7:0]  matrix_p31_r; 
    reg [7:0]  matrix_p32_r; 
    reg [7:0]  matrix_p33_r;
    reg [7:0]  matrix_p34_r;
    reg [7:0]  matrix_p35_r;
    reg [7:0]  matrix_p41_r; 
    reg [7:0]  matrix_p42_r; 
    reg [7:0]  matrix_p43_r;
    reg [7:0]  matrix_p44_r;
    reg [7:0]  matrix_p45_r;   
    reg [7:0]  matrix_p51_r; 
    reg [7:0]  matrix_p52_r; 
    reg [7:0]  matrix_p53_r;
    reg [7:0]  matrix_p54_r;
    reg [7:0]  matrix_p55_r; 

    always @(posedge clk) begin
        matrix_p11_r = matrix_p11;
        matrix_p12_r = matrix_p12;
        matrix_p13_r = matrix_p13;
        matrix_p14_r = matrix_p14;
        matrix_p15_r = matrix_p15;
        matrix_p21_r = matrix_p21;
        matrix_p22_r = matrix_p22;
        matrix_p23_r = matrix_p23;
        matrix_p24_r = matrix_p24;
        matrix_p25_r = matrix_p25;
        matrix_p31_r = matrix_p31;
        matrix_p32_r = matrix_p32;
        matrix_p33_r = matrix_p33;
        matrix_p34_r = matrix_p34;
        matrix_p35_r = matrix_p35;
        matrix_p41_r = matrix_p41;
        matrix_p42_r = matrix_p42;
        matrix_p43_r = matrix_p43;
        matrix_p44_r = matrix_p44;
        matrix_p45_r = matrix_p45;
        matrix_p51_r = matrix_p51;
        matrix_p52_r = matrix_p52;
        matrix_p53_r = matrix_p53;
        matrix_p54_r = matrix_p54;
        matrix_p55_r = matrix_p55;
    end

//-------------------------------------------------------------------
    localparam OddLINE_OddPOINT = 2'b00;
    localparam OddLINE_Even_POINT = 2'b01;
    localparam EvenLINE_OddPOINT = 2'b10;
    localparam EvenLINE_EvenPOINT = 2'b11;
    
    reg  Pc_state_max;
    reg  Pc_state_min;

    reg signed [8:0] pixel_diff_1;
    reg signed [8:0] pixel_diff_2;
    reg signed [8:0] pixel_diff_3;
    reg signed [8:0] pixel_diff_4;
    reg signed [8:0] pixel_diff_5;
    reg signed [8:0] pixel_diff_6;
    reg signed [8:0] pixel_diff_7;
    reg signed [8:0] pixel_diff_8;

    wire pixel_green_state;

    assign pixel_green_state = ((hvcnt_num_r==EvenLINE_OddPOINT)||(hvcnt_num_r==OddLINE_Even_POINT)) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (pixel_green_state) begin
            pixel_diff_1 <= $signed(matrix_p33_r - matrix_p13_r);
            pixel_diff_2 <= $signed(matrix_p33_r - matrix_p22_r);
            pixel_diff_3 <= $signed(matrix_p33_r - matrix_p24_r);
            pixel_diff_4 <= $signed(matrix_p33_r - matrix_p31_r);
            pixel_diff_5 <= $signed(matrix_p33_r - matrix_p35_r);
            pixel_diff_6 <= $signed(matrix_p33_r - matrix_p42_r);
            pixel_diff_7 <= $signed(matrix_p33_r - matrix_p44_r);
            pixel_diff_8 <= $signed(matrix_p33_r - matrix_p53_r);    
        end else begin
            pixel_diff_1 <= $signed(matrix_p33_r - matrix_p11_r);
            pixel_diff_2 <= $signed(matrix_p33_r - matrix_p13_r);
            pixel_diff_3 <= $signed(matrix_p33_r - matrix_p15_r);
            pixel_diff_4 <= $signed(matrix_p33_r - matrix_p31_r);
            pixel_diff_5 <= $signed(matrix_p33_r - matrix_p35_r);
            pixel_diff_6 <= $signed(matrix_p33_r - matrix_p51_r);
            pixel_diff_7 <= $signed(matrix_p33_r - matrix_p53_r);
            pixel_diff_8 <= $signed(matrix_p33_r - matrix_p55_r); 
        end
    end

    wire [7:0] pixel_data_1;
    wire [7:0] pixel_data_2;
    wire [7:0] pixel_data_3;
    wire [7:0] pixel_data_4;

    assign pixel_data_1 = (pixel_green_state) ? matrix_p22_r : matrix_p11_r;
    assign pixel_data_2 = (pixel_green_state) ? matrix_p24_r : matrix_p15_r;
    assign pixel_data_3 = (pixel_green_state) ? matrix_p42_r : matrix_p51_r;
    assign pixel_data_4 = (pixel_green_state) ? matrix_p44_r : matrix_p15_r;

    reg [7:0] data_max1, data_max2, data_max3;
    reg [7:0] data_mid1, data_mid2, data_mid3;
    reg [7:0] data_min1, data_min2, data_min3;

    //第一行
    always @(posedge clk)
    begin
        if((pixel_data_1 <= pixel_data_2)&&(pixel_data_1 <= matrix_p13_r))
            data_min1 <= pixel_data_1;
        else if((pixel_data_2 <= pixel_data_1)&&(pixel_data_2 <= matrix_p13_r))
            data_min1 <= pixel_data_2;
        else
            data_min1 <= matrix_p13_r;
    end

    always @(posedge clk)
    begin
        if((pixel_data_1 <= pixel_data_2)&&(pixel_data_1 >= matrix_p13_r)||(pixel_data_1 >= pixel_data_2)&&(pixel_data_1 <= matrix_p13_r))
            data_mid1 <= pixel_data_1;
        else if((pixel_data_2 <= pixel_data_1)&&(pixel_data_2 >= matrix_p13_r)||(pixel_data_2 >= pixel_data_1)&&(pixel_data_2 <= matrix_p13_r))
            data_mid1 <= pixel_data_2;
        else
            data_mid1 <= matrix_p13_r;
    end

    always @(posedge clk)
    begin
        if((pixel_data_1 >= pixel_data_2)&&(pixel_data_1 >= matrix_p13_r))
            data_max1 <= pixel_data_1;
        else if((pixel_data_2 >= pixel_data_1)&&(pixel_data_2 >= matrix_p13_r))
            data_max1 <= pixel_data_2;
        else
            data_max1 <= matrix_p13_r;
    end
    //第三行
    always @(posedge clk)
    begin
        if((matrix_p21_r <= matrix_p22_r)&&(matrix_p21_r <= matrix_p23_r))
            data_min2 <= matrix_p21_r;
        else if((matrix_p22_r <= matrix_p21_r)&&(matrix_p22_r <= matrix_p23_r))
            data_min2 <= matrix_p22_r;
        else
            data_min2 <= matrix_p23_r;
    end

    always @(posedge clk)
    begin
        if((matrix_p21_r <= matrix_p22_r)&&(matrix_p21_r >= matrix_p23_r)||(matrix_p21_r >= matrix_p22_r)&&(matrix_p21_r <= matrix_p23_r))
            data_mid2 <= matrix_p21_r;
        else if((matrix_p22_r <= matrix_p21_r)&&(matrix_p22_r >= matrix_p23_r)||(matrix_p22_r >= matrix_p21_r)&&(matrix_p22_r <= matrix_p23_r))
            data_mid2 <= matrix_p22_r;
        else
            data_mid2 <= matrix_p23_r;
    end

    always @(posedge clk)
    begin
        if((matrix_p21_r >= matrix_p22_r)&&(matrix_p21_r >= matrix_p23_r))
            data_max2 <= matrix_p21_r;
        else if((matrix_p22_r >= matrix_p21_r)&&(matrix_p22_r >= matrix_p23_r))
            data_max2 <= matrix_p22_r;
        else
            data_max2 <= matrix_p23_r;
    end
    //第五行
    always @(posedge clk)
    begin
        if((pixel_data_3 <= pixel_data_4)&&(pixel_data_3 <= matrix_p53_r))
            data_min3 <= pixel_data_3;
        else if((pixel_data_4 <= pixel_data_3)&&(pixel_data_4 <= matrix_p53_r))
            data_min3 <= pixel_data_4;
        else
            data_min3 <= matrix_p53_r;
    end

    always @(posedge clk)
    begin
        if((pixel_data_3 <= pixel_data_4)&&(pixel_data_3 >= matrix_p53_r)||(pixel_data_3 >= pixel_data_4)&&(pixel_data_3 <= matrix_p53_r))
            data_mid3 <= pixel_data_3;
        else if((pixel_data_4 <= pixel_data_3)&&(pixel_data_4 >= matrix_p53_r)||(pixel_data_4 >= pixel_data_3)&&(pixel_data_4 <= matrix_p53_r))
            data_mid3 <= pixel_data_4;
        else
            data_mid3 <= matrix_p53_r;
    end

    always @(posedge clk)
    begin
        if((pixel_data_3 >= pixel_data_4)&&(pixel_data_3 >= matrix_p53_r))
            data_max3 <= pixel_data_3;
        else if((pixel_data_4 >= pixel_data_3)&&(pixel_data_4 >= matrix_p53_r))
            data_max3 <= pixel_data_4;
        else
            data_max3 <= matrix_p53_r;
    end
//-------------------------------------------------------------------
    reg pixel_Gb_state;

    always @(posedge clk) begin
        if (pixel_diff_1[8]&pixel_diff_2[8]&pixel_diff_3[8]&pixel_diff_4[8]&pixel_diff_5[8]&pixel_diff_6[8]&pixel_diff_7[8]&pixel_diff_8[8]) begin
            pixel_Gb_state <= 1'b1;
        end else if (~pixel_diff_1[8]&~pixel_diff_2[8]&~pixel_diff_3[8]&~pixel_diff_4[8]&~pixel_diff_5[8]&~pixel_diff_6[8]&~pixel_diff_7[8]&~pixel_diff_8[8]) begin
            pixel_Gb_state <= 1'b1;
        end else begin
            pixel_Gb_state <= 1'b0;
        end
    end

    reg pixel_diff_state;
    always @(posedge clk) begin
        if ((pixel_diff_1[7:0]>TH)&&(pixel_diff_2[7:0]>TH)&&(pixel_diff_3[7:0]>TH)&&(pixel_diff_4[7:0]>TH)&&
            (pixel_diff_5[7:0]>TH)&&(pixel_diff_6[7:0]>TH)&&(pixel_diff_7[7:0]>TH)&&(pixel_diff_8[7:0]>TH)) begin
            pixel_diff_state <= 1'b1;        
        end else begin
            pixel_diff_state <= 1'b0;      
        end
    end


    reg [7:0] max_min, mid_mid, min_max;
    always @(posedge clk)
    begin
        if((data_min1 >= data_min2)&&(data_min1 >= data_min3))
            max_min <= data_min1;
        else if((data_min2 >= data_min1)&&(data_min2 >= data_min3))
            max_min <= data_min2;
        else
            max_min <= data_min3;
    end

    always @(posedge clk)
    begin
        if((data_mid1 >= data_mid2)&&(data_mid1 <= data_mid3)||(data_mid1 <= data_mid2)&&(data_mid1 >= data_mid3))
            mid_mid <= data_mid1;
        else if((data_mid2 >= data_mid1)&&(data_mid2 <= data_mid3)||(data_mid2 <= data_mid1)&&(data_mid2 >= data_mid3))
            mid_mid <= data_mid2;
        else
            mid_mid <= data_mid3;
    end

    always @(posedge clk)
    begin
        if((data_max1 <= data_max2)&&(data_max1 <= data_max3))
            min_max <= data_max1;
        else if((data_max2 <= data_max1)&&(data_max2 <= data_max3))
            min_max <= data_max2;
        else
            min_max <= data_max3;
    end

//-------------------------------------------------------------------
    reg judge_pixel;
    always @(posedge clk) begin
        judge_pixel <= pixel_diff_state & pixel_diff_state;
    end

    reg [7:0] pixel_Data;
    always @(posedge clk)
    begin
        if((max_min >= mid_mid)&&(max_min <= min_max)||(max_min <= mid_mid)&&(max_min >= min_max))
            pixel_Data <= max_min;
        else if((mid_mid >= max_min)&&(mid_mid <= min_max)||(mid_mid <= max_min)&&(mid_mid >= min_max))
            pixel_Data <= mid_mid;
        else
            pixel_Data <= min_max;
    end
//-------------------------------------------------------------------
    reg [3:0] img_de;
    reg [3:0] img_href, img_vsync;
    always @(posedge clk) begin
        img_href  <= {img_href[2:0], matrix_img_href};
        img_vsync <= {img_vsync[2:0], matrix_img_vsync};
        img_de <= {img_de[2:0], matrix_img_de};
    end

    reg [7:0] matrix_p33_reg [2:0];
    always @(posedge clk) begin
        matrix_p33_reg[0] <= matrix_p33_r;
        matrix_p33_reg[1] <= matrix_p33_reg[0];
        matrix_p33_reg[2] <= matrix_p33_reg[1];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_gray <= 8'd0;
        end else if (PINTO_en) begin 
            if (judge_pixel) begin
                post_img_gray <= pixel_Data;
            end else begin
                post_img_gray <= matrix_p33_reg[2];
            end
        end else begin
            post_img_gray <= matrix_p33_reg[2];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync <= 1'b0;
            post_img_href  <= 1'b0;
            post_img_de    <= 1'b0;
        end else begin
            post_img_vsync <= img_vsync[3];
            post_img_href  <= img_href[3];
            post_img_de    <= img_de[3];
        end
    end

endmodule