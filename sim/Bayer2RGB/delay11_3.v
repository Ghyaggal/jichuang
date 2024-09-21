module delay11_3 (
    input clk,
    input [2:0] data_in,
    output reg [2:0] data_out
);
    reg [2:0] data_r [20:0];
    always @(posedge clk) begin
        data_r[0] <= data_in;
        data_r[1] <= data_r[0];
        data_r[2] <= data_r[1];
        data_r[3] <= data_r[2];
        data_r[4] <= data_r[3];
        data_r[5] <= data_r[4];
        data_r[6] <= data_r[5];
        data_r[7] <= data_r[6];
        data_r[8] <= data_r[7];
        data_r[9] <= data_r[8];
        data_r[10] <= data_r[9];
        data_r[11] <= data_r[10];
        data_r[12] <= data_r[11];
        data_r[13] <= data_r[12];
        data_r[14] <= data_r[13];
        data_r[15] <= data_r[14];
        data_r[16] <= data_r[15];
        data_r[17] <= data_r[16];
        data_r[18] <= data_r[17];
        data_r[19] <= data_r[18];
        data_r[20] <= data_r[19];   
        data_out  <= data_r[20];
    end

endmodule