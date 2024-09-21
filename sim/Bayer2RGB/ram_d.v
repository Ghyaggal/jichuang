module ram_dual(
	input rst_n,
	input clk_r,
	input clk_w,
	input [7:0]addr_r,
	input [7:0]addr_w,
	input [7:0]data_w,
	input rd_en,
	input wr_en,//_r表示读，_w表示写，_en使能
	output reg[7:0]data_rd //为读取数据
);

	reg [7:0] ram[127:0];
	
	//  Port read
	always@(posedge clk_r or negedge rst_n)
		begin
			if(!rst_n)
				data_rd <= 1'b0;
			else if (rd_en)
					data_rd <= ram[addr_r];
				else 
					data_rd <= 8'b00000000;
				
		end
	
	// Port write
	always@(posedge clk_w or negedge rst_n)
		begin
			if (!rst_n)
				ram[addr_w] <= ram[addr_w];
			else if (wr_en)
					ram[addr_w] <= data_w;
				else 
					ram[addr_w] <= ram[addr_w];
			
		end
		
endmodule
	

