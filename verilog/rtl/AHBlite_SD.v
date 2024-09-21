module AHBlite_SD (
    input  wire          HCLK,    
    input  wire          HRESETn, 
    input  wire          HSEL,    
    input  wire   [31:0] HADDR,   
    input  wire    [1:0] HTRANS,  
    input  wire    [2:0] HSIZE,   
    input  wire    [3:0] HPROT,   
    input  wire          HWRITE,  
    input  wire   [31:0] HWDATA,   
    input  wire          HREADY, 
    output wire          HREADYOUT, 
    output wire   [31:0] HRDATA,  
    output wire          HRESP,
    input  wire          SD_clk_shift,

	  input  wire   [1:0]  SD_D,
    output wire          SD_CLK,
    input  wire          miso,
    output wire          cs_n,
    output wire          mosi,

    output wire          ADDR_state,

    output wire          rd_data_en,
    output wire   [15:0] rd_data,
    output wire          init_end
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire write_en;
assign write_en = HSEL & HTRANS[1] & HWRITE & HREADY;

reg wr_en_reg;
always @ (posedge HCLK or negedge HRESETn) begin
    if (~HRESETn) wr_en_reg <= 1'b0;
    else if (write_en) wr_en_reg <= 1'b1;
    else wr_en_reg <= 1'b0;
end

reg [2:0] addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr_reg <= 2'b0;
  else if(HSEL & HREADY & HTRANS[1]) addr_reg <= HADDR[4:2];
end

//总线数据缓存 
reg [31:0]	ADDR_DATA;
reg     stop;
reg     remake;
reg     rd_retro;
always @(posedge HCLK or negedge HRESETn)
begin
  if(!HRESETn) begin
    ADDR_DATA <= 32'd34880;
    stop <= 1'b0;
    remake <= 1'b0;
    rd_retro <= 1'b0;
  end else if(wr_en_reg && HREADY) begin
    if(addr_reg == 3'd0) begin
        ADDR_DATA <= HWDATA;
    end else if(addr_reg == 3'd1) begin
        stop <= HWDATA[0];
    end else if(addr_reg == 3'd2) begin
        remake <= HWDATA[0];
    end else if (addr_reg == 3'd3) begin
        rd_retro <= HWDATA[0];
    end
  end
end

assign ADDR_state = (ADDR_DATA == 32'd34880) ? 1'b1 : 1'b0;


wire  bin_read_over;
wire [7:0] read_frame_cnt;

SD_top SD_top_inst(
    .clk_normal         (HCLK),
    .clk_shift          (SD_clk_shift),
    .rst_n              (HRESETn),
	  .SD_D               (SD_D),
    .SD_CLK             (SD_CLK),
    .miso               (miso),
    .cs_n               (cs_n),
    .mosi               (mosi),
    .init_end           (init_end),
    .rd_addr_reset      (remake),
    .rd_stop            (stop),
    .rd_retro           (rd_retro),
    .rd_addr_setting    (ADDR_DATA),
    .rd_en              (1'b1),
    .rd_busy            (),
    .rd_data_en         (rd_data_en),
    .rd_data            (rd_data),
    .bin_read_over      (bin_read_over),
    .frame_read_over    (),
    .read_data_cnt      (),
    .read_frame_cnt     (read_frame_cnt),
    .one_frame_finish   ()
);

assign HRDATA = (addr_reg == 3'd0) ? ADDR_DATA : 
  (addr_reg == 3'd1) ? {31'b0, stop} :
  (addr_reg == 3'd2) ? {31'b0, remake} :
  (addr_reg == 3'd3) ? {31'b0, rd_retro} : {24'b0, read_frame_cnt}; 

endmodule