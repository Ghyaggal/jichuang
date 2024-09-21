module AHBlite_LED(
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
	  output wire    [7:0] LED,
    output wire    [3:0] signal_LED
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

reg	[7:0]	WaterLight_LED; 	//模式改变
reg [3:0] state_LED;
wire write_en;
assign write_en = HSEL & HTRANS[1] & HWRITE & HREADY;

reg wr_en_reg;


always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) wr_en_reg <= 1'b0;
  else if(write_en) wr_en_reg <= 1'b1;
  else wr_en_reg <= 1'b0;
end

reg [2:0] addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr_reg <= 2'b0;
  else if(HSEL & HREADY & HTRANS[1]) addr_reg <= HADDR[3:2];
end

always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
		WaterLight_LED <= 8'd0;
    	state_LED <= 4'b1000;
    end else if(wr_en_reg && HREADY) begin
      if (addr_reg == 2'd0) begin
        WaterLight_LED <= HWDATA[7:0];
      end else if (addr_reg == 2'd1) begin
        state_LED <= HWDATA[3:0];
      end
    end
        
end

assign LED = WaterLight_LED;
assign signal_LED = state_LED;

assign HRDATA = (addr_reg == 2'd0) ? {24'b0, WaterLight_LED} : {28'b0, state_LED};


endmodule


