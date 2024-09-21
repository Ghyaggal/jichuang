module med_filter_proc (
    clk,
    rst_n,
    MedFilter_en,
    per_img_vsync,
    per_img_href,
    per_img_de,
    per_img_gray,
    post_img_vsync,
    post_img_href,
    post_img_de,
    post_img_gray
    );
    
    input               clk;
    input               rst_n;
    input               MedFilter_en;
    input               per_img_vsync;
    input               per_img_href;
    input               per_img_de;
    input [7:0]         per_img_gray;
    output reg          post_img_vsync;
    output reg          post_img_href;
    output reg          post_img_de;
    output reg [7:0]    post_img_gray;


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



    reg [7:0] data_max1, data_max2, data_max3;
    reg [7:0] data_mid1, data_mid2, data_mid3;
    reg [7:0] data_min1, data_min2, data_min3;

    //-----------------------------------------------
    reg [7:0] matrix_p22_r1;
    always @(posedge clk) begin
        matrix_p22_r1 <= matrix_p22;
    end

    always @(posedge clk)
    begin
        if((matrix_p11 <= matrix_p12)&&(matrix_p11 <= matrix_p13))
            data_min1 <= matrix_p11;
        else if((matrix_p12 <= matrix_p11)&&(matrix_p12 <= matrix_p13))
            data_min1 <= matrix_p12;
        else
            data_min1 <= matrix_p13;
    end

    always @(posedge clk)
    begin
        if((matrix_p11 <= matrix_p12)&&(matrix_p11 >= matrix_p13)||(matrix_p11 >= matrix_p12)&&(matrix_p11 <= matrix_p13))
            data_mid1 <= matrix_p11;
        else if((matrix_p12 <= matrix_p11)&&(matrix_p12 >= matrix_p13)||(matrix_p12 >= matrix_p11)&&(matrix_p12 <= matrix_p13))
            data_mid1 <= matrix_p12;
        else
            data_mid1 <= matrix_p13;
    end

    always @(posedge clk)
    begin
        if((matrix_p11 >= matrix_p12)&&(matrix_p11 >= matrix_p13))
            data_max1 <= matrix_p11;
        else if((matrix_p12 >= matrix_p11)&&(matrix_p12 >= matrix_p13))
            data_max1 <= matrix_p12;
        else
            data_max1 <= matrix_p13;
    end


    always @(posedge clk)
    begin
        if((matrix_p21 <= matrix_p22)&&(matrix_p21 <= matrix_p23))
            data_min2 <= matrix_p21;
        else if((matrix_p22 <= matrix_p21)&&(matrix_p22 <= matrix_p23))
            data_min2 <= matrix_p22;
        else
            data_min2 <= matrix_p23;
    end

    always @(posedge clk)
    begin
        if((matrix_p21 <= matrix_p22)&&(matrix_p21 >= matrix_p23)||(matrix_p21 >= matrix_p22)&&(matrix_p21 <= matrix_p23))
            data_mid2 <= matrix_p21;
        else if((matrix_p22 <= matrix_p21)&&(matrix_p22 >= matrix_p23)||(matrix_p22 >= matrix_p21)&&(matrix_p22 <= matrix_p23))
            data_mid2 <= matrix_p22;
        else
            data_mid2 <= matrix_p23;
    end

    always @(posedge clk)
    begin
        if((matrix_p21 >= matrix_p22)&&(matrix_p21 >= matrix_p23))
            data_max2 <= matrix_p21;
        else if((matrix_p22 >= matrix_p21)&&(matrix_p22 >= matrix_p23))
            data_max2 <= matrix_p22;
        else
            data_max2 <= matrix_p23;
    end

    always @(posedge clk)
    begin
        if((matrix_p31 <= matrix_p32)&&(matrix_p31 <= matrix_p33))
            data_min3 <= matrix_p31;
        else if((matrix_p32 <= matrix_p31)&&(matrix_p32 <= matrix_p33))
            data_min3 <= matrix_p32;
        else
            data_min3 <= matrix_p33;
    end

    always @(posedge clk)
    begin
        if((matrix_p31 <= matrix_p32)&&(matrix_p31 >= matrix_p33)||(matrix_p31 >= matrix_p32)&&(matrix_p31 <= matrix_p33))
            data_mid3 <= matrix_p31;
        else if((matrix_p32 <= matrix_p31)&&(matrix_p32 >= matrix_p33)||(matrix_p32 >= matrix_p31)&&(matrix_p32 <= matrix_p33))
            data_mid3 <= matrix_p32;
        else
            data_mid3 <= matrix_p33;
    end

    always @(posedge clk)
    begin
        if((matrix_p31 >= matrix_p32)&&(matrix_p31 >= matrix_p33))
            data_max3 <= matrix_p31;
        else if((matrix_p32 >= matrix_p31)&&(matrix_p32 >= matrix_p33))
            data_max3 <= matrix_p32;
        else
            data_max3 <= matrix_p33;
    end

    //-----------------------------------------------
    reg [7:0] matrix_p22_r2;
    always @(posedge clk) begin
        matrix_p22_r2 <= matrix_p22_r1;
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
    //-----------------------------------------------
    reg [7:0] matrix_p22_r3;
    always @(posedge clk) begin
        matrix_p22_r3 <= matrix_p22_r2;
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
    //-----------------------------------------------
    reg [2:0] img_de;
    reg [2:0] img_href, img_vsync;
    always @(posedge clk) begin
        img_href  <= {img_href[1:0], matrix_img_href};
        img_vsync <= {img_vsync[1:0], matrix_img_vsync};
        img_de <= {img_de[1:0], matrix_img_de};
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_gray <= 8'd0;
        end else if (MedFilter_en) begin
            post_img_gray <= pixel_Data;
        end else begin
            post_img_gray <= matrix_p22_r3;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_img_vsync <= 1'b0;
            post_img_href  <= 1'b0;
            post_img_de    <= 1'b0;
        end else begin
            post_img_vsync <= img_vsync[2];
            post_img_href  <= img_href[2];
            post_img_de    <= img_de[2];
        end
    end

endmodule