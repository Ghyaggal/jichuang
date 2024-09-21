module AHBlite_PINTO (
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
    output wire          PINTO_en
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

reg en_state;
always @(posedge HCLK or negedge HRESETn)
begin
  if(!HRESETn) begin
    en_state <=1'b0;
  end else if(wr_en_reg && HREADY) begin
    en_state <= HWDATA[0];
  end
end

assign PINTO_en = en_state;
assign HRDATA = {31'b0, en_state};

endmodule