module AHBlite_SEG(
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
    output wire [3:0] seg_sel,
    output wire [7:0] seg_led
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
 
//总线数据缓存 
reg [15:0]	DATA;
always @(posedge HCLK or negedge HRESETn)
begin
  if(!HRESETn)
    DATA <= 16'h0000;
  else if(wr_en_reg && HREADY) begin
    DATA <= HWDATA[15:0];
  end
end

assign HRDATA = {16'b0, DATA};

smg smg_inst(                        //数码管
    .clk		(HCLK),
    .rst_n		(HRESETn),
    .smg_data	(DATA),
    .seg_sel	(seg_sel),
    .seg_led	(seg_led)
);

endmodule