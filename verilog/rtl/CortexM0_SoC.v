module CortexM0_SoC (
        input  wire  System_clk,
        input  wire  RSTn,
        inout  wire  SWDIO,  
        input  wire  SWCLK,

        output wire [7:0] LED,        //LED

        input wire [7:0] key,           //拨动按键

        output wire [3:0]  Row,       //矩阵键盘
	input wire [3:0]  Col,
        output wire [3:0] seg_sel,
        output wire [7:0] seg_led,
        
        output wire [3:0] signal_LED,  //指示灯

        input wire [1:0] SD_D,        //SD接口
        output wire SD_CLK,
        input wire miso,
        output wire cs_n,
        output wire mosi,

        output wire TXD_1,      //串口1
        input wire RXD_1,

        output wire HDMI_CLK_P, //HDMI接口
        output wire HDMI_D2_P,
        output wire HDMI_D1_P,
        output wire HDMI_D0_P

);


//------------------------------------------------------------------------------
// signal_LED
//------------------------------------------------------------------------------
wire SD_init_end;
wire sdram_init_done;
wire ADDR_state;

//------------------------------------------------------------------------------
// PLL
//------------------------------------------------------------------------------
wire	Lock;		//输出锁定
wire	clk;		//25 MHz
wire    SD_clk_shift;   //25MHZ 90
PLL PLL_inst(
  .refclk       (System_clk),
  .reset        (1'b0),
  .stdby        (1'b0),
  .extlock      (Lock),
  .clk0_out     (),
  .clk1_out     (clk),
  .clk2_out     (SD_clk_shift)  
);

wire clk_sdr_ctrl;
wire clk_sdram;

SDRAM_PLL SDRAM_PLL_inst(
        .reset(1'b0),
        .refclk(System_clk),
        .clk0_out(clk_sdr_ctrl),
        .clk1_out(clk_sdram)
);

wire pixel_clk;
wire pixel_clk_5x;

PIXEL_PLL PIXEL_PLL_inst(
        .refclk     (System_clk),
        .reset      (1'b0),
        .clk0_out   (),
        .clk1_out   (pixel_clk),
        .clk2_out   (pixel_clk_5x)
);


//------------------------------------------------------------------------------
// DEBUG IOBUF 
//------------------------------------------------------------------------------

wire SWDO;
wire SWDOEN;
wire SWDI;

assign SWDI = SWDIO;
assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;

//------------------------------------------------------------------------------
// Interrupt
//------------------------------------------------------------------------------
wire timer_interrupt;
wire [7:0] key_interrupt;
wire UART1_interrupt;

Keyboard kb
(
   .HCLK(clk),
   .HRESETn(RSTn),
   .col(key),
   .key_interrupt(key_interrupt)
);

wire [31:0] IRQ;

assign IRQ = {22'b0, key_interrupt, timer_interrupt, UART1_interrupt};


wire RXEV;
assign RXEV = 1'b0;

//------------------------------------------------------------------------------
// AHB
//------------------------------------------------------------------------------

wire [31:0] HADDR;
wire [ 2:0] HBURST;
wire        HMASTLOCK;
wire [ 3:0] HPROT;
wire [ 2:0] HSIZE;
wire [ 1:0] HTRANS;
wire [31:0] HWDATA;
wire        HWRITE;
wire [31:0] HRDATA;
wire        HRESP;
wire        HMASTER;
wire        HREADY;

//------------------------------------------------------------------------------
// RESET AND DEBUG
//------------------------------------------------------------------------------

wire SYSRESETREQ;
reg cpuresetn;

always @(posedge clk or negedge RSTn)begin
        if (~RSTn) cpuresetn <= 1'b0;
        else if (SYSRESETREQ) cpuresetn <= 1'b0;
        else if (Lock==1'b0)  cpuresetn <= 1'b0;
        else cpuresetn <= 1'b1;
end

wire CDBGPWRUPREQ;
reg CDBGPWRUPACK;

always @(posedge clk or negedge RSTn)begin
        if (~RSTn) CDBGPWRUPACK <= 1'b0;
        else CDBGPWRUPACK <= CDBGPWRUPREQ;
end


//------------------------------------------------------------------------------
// Instantiate Cortex-M0 processor logic level
//------------------------------------------------------------------------------

cortexm0ds_logic u_logic (

        // System inputs
        .FCLK           (clk),           //FREE running clock 
        .SCLK           (clk),           //system clock
        .HCLK           (clk),           //AHB clock
        .DCLK           (clk),           //Debug clock
        .PORESETn       (RSTn),          //Power on reset
        .HRESETn        (cpuresetn),     //AHB and System reset
        .DBGRESETn      (RSTn),          //Debug Reset
        .RSTBYPASS      (1'b0),          //Reset bypass
        .SE             (1'b0),          // dummy scan enable port for synthesis

        // Power management inputs
        .SLEEPHOLDREQn  (1'b1),          // Sleep extension request from PMU
        .WICENREQ       (1'b0),          // WIC enable request from PMU
        .CDBGPWRUPACK   (CDBGPWRUPACK),  // Debug Power Up ACK from PMU

        // Power management outputs
        .CDBGPWRUPREQ   (CDBGPWRUPREQ),
        .SYSRESETREQ    (SYSRESETREQ),

        // System bus
        .HADDR          (HADDR[31:0]),
        .HTRANS         (HTRANS[1:0]),
        .HSIZE          (HSIZE[2:0]),
        .HBURST         (HBURST[2:0]),
        .HPROT          (HPROT[3:0]),
        .HMASTER        (HMASTER),
        .HMASTLOCK      (HMASTLOCK),
        .HWRITE         (HWRITE),
        .HWDATA         (HWDATA[31:0]),
        .HRDATA         (HRDATA[31:0]),
        .HREADY         (HREADY),
        .HRESP          (HRESP),

        // Interrupts
        .IRQ            (IRQ),          //Interrupt
        .NMI            (1'b0),         //Watch dog interrupt
        .IRQLATENCY     (8'h0),
        .ECOREVNUM      (28'h0),

        // Systick
        .STCLKEN        (1'b1),
        .STCALIB        (26'h0),

        // Debug - JTAG or Serial wire
        // Inputs
        .nTRST          (1'b1),
        .SWDITMS        (SWDI),
        .SWCLKTCK       (SWCLK),
        .TDI            (1'b0),
        // Outputs
        .SWDO           (SWDO),
        .SWDOEN         (SWDOEN),

        .DBGRESTART     (1'b0),

        // Event communication
        .RXEV           (RXEV),         // Generate event when a DMA operation completed.
        .EDBGRQ         (1'b0)          // multi-core synchronous halt request
);

//------------------------------------------------------------------------------
// AHBlite Interconncet
//------------------------------------------------------------------------------

wire            HSEL_P0;
wire    [31:0]  HADDR_P0;
wire    [2:0]   HBURST_P0;
wire            HMASTLOCK_P0;
wire    [3:0]   HPROT_P0;
wire    [2:0]   HSIZE_P0;
wire    [1:0]   HTRANS_P0;
wire    [31:0]  HWDATA_P0;
wire            HWRITE_P0;
wire            HREADY_P0;
wire            HREADYOUT_P0;
wire    [31:0]  HRDATA_P0;
wire            HRESP_P0;

wire            HSEL_P1;
wire    [31:0]  HADDR_P1;
wire    [2:0]   HBURST_P1;
wire            HMASTLOCK_P1;
wire    [3:0]   HPROT_P1;
wire    [2:0]   HSIZE_P1;
wire    [1:0]   HTRANS_P1;
wire    [31:0]  HWDATA_P1;
wire            HWRITE_P1;
wire            HREADY_P1;
wire            HREADYOUT_P1;
wire    [31:0]  HRDATA_P1;
wire            HRESP_P1;

wire            HSEL_P2;
wire    [31:0]  HADDR_P2;
wire    [2:0]   HBURST_P2;
wire            HMASTLOCK_P2;
wire    [3:0]   HPROT_P2;
wire    [2:0]   HSIZE_P2;
wire    [1:0]   HTRANS_P2;
wire    [31:0]  HWDATA_P2;
wire            HWRITE_P2;
wire            HREADY_P2;
wire            HREADYOUT_P2;
wire    [31:0]  HRDATA_P2;
wire            HRESP_P2;

wire            HSEL_P3;
wire    [31:0]  HADDR_P3;
wire    [2:0]   HBURST_P3;
wire            HMASTLOCK_P3;
wire    [3:0]   HPROT_P3;
wire    [2:0]   HSIZE_P3;
wire    [1:0]   HTRANS_P3;
wire    [31:0]  HWDATA_P3;
wire            HWRITE_P3;
wire            HREADY_P3;
wire            HREADYOUT_P3;
wire    [31:0]  HRDATA_P3;
wire            HRESP_P3;

wire            HSEL_P4;
wire    [31:0]  HADDR_P4;
wire    [2:0]   HBURST_P4;
wire            HMASTLOCK_P4;
wire    [3:0]   HPROT_P4;
wire    [2:0]   HSIZE_P4;
wire    [1:0]   HTRANS_P4;
wire    [31:0]  HWDATA_P4;
wire            HWRITE_P4;
wire            HREADY_P4;
wire            HREADYOUT_P4;
wire    [31:0]  HRDATA_P4;
wire            HRESP_P4;

wire            HSEL_P5;
wire    [31:0]  HADDR_P5;
wire    [2:0]   HBURST_P5;
wire            HMASTLOCK_P5;
wire    [3:0]   HPROT_P5;
wire    [2:0]   HSIZE_P5;
wire    [1:0]   HTRANS_P5;
wire    [31:0]  HWDATA_P5;
wire            HWRITE_P5;
wire            HREADY_P5;
wire            HREADYOUT_P5;
wire    [31:0]  HRDATA_P5;
wire            HRESP_P5;

wire            HSEL_P6;
wire    [31:0]  HADDR_P6;
wire    [2:0]   HBURST_P6;
wire            HMASTLOCK_P6;
wire    [3:0]   HPROT_P6;
wire    [2:0]   HSIZE_P6;
wire    [1:0]   HTRANS_P6;
wire    [31:0]  HWDATA_P6;
wire            HWRITE_P6;
wire            HREADY_P6;
wire            HREADYOUT_P6;
wire    [31:0]  HRDATA_P6;
wire            HRESP_P6;

wire            HSEL_P7;
wire    [31:0]  HADDR_P7;
wire    [2:0]   HBURST_P7;
wire            HMASTLOCK_P7;
wire    [3:0]   HPROT_P7;
wire    [2:0]   HSIZE_P7;
wire    [1:0]   HTRANS_P7;
wire    [31:0]  HWDATA_P7;
wire            HWRITE_P7;
wire            HREADY_P7;
wire            HREADYOUT_P7;
wire    [31:0]  HRDATA_P7;
wire            HRESP_P7;

wire            HSEL_P8;
wire    [31:0]  HADDR_P8;
wire    [2:0]   HBURST_P8;
wire            HMASTLOCK_P8;
wire    [3:0]   HPROT_P8;
wire    [2:0]   HSIZE_P8;
wire    [1:0]   HTRANS_P8;
wire    [31:0]  HWDATA_P8;
wire            HWRITE_P8;
wire            HREADY_P8;
wire            HREADYOUT_P8;
wire    [31:0]  HRDATA_P8;
wire            HRESP_P8;

wire            HSEL_P9;
wire    [31:0]  HADDR_P9;
wire    [2:0]   HBURST_P9;
wire            HMASTLOCK_P9;
wire    [3:0]   HPROT_P9;
wire    [2:0]   HSIZE_P9;
wire    [1:0]   HTRANS_P9;
wire    [31:0]  HWDATA_P9;
wire            HWRITE_P9;
wire            HREADY_P9;
wire            HREADYOUT_P9;
wire    [31:0]  HRDATA_P9;
wire            HRESP_P9;

wire            HSEL_P10;
wire    [31:0]  HADDR_P10;
wire    [2:0]   HBURST_P10;
wire            HMASTLOCK_P10;
wire    [3:0]   HPROT_P10;
wire    [2:0]   HSIZE_P10;
wire    [1:0]   HTRANS_P10;
wire    [31:0]  HWDATA_P10;
wire            HWRITE_P10;
wire            HREADY_P10;
wire            HREADYOUT_P10;
wire    [31:0]  HRDATA_P10;
wire            HRESP_P10;

wire            HSEL_P11;
wire    [31:0]  HADDR_P11;
wire    [2:0]   HBURST_P11;
wire            HMASTLOCK_P11;
wire    [3:0]   HPROT_P11;
wire    [2:0]   HSIZE_P11;
wire    [1:0]   HTRANS_P11;
wire    [31:0]  HWDATA_P11;
wire            HWRITE_P11;
wire            HREADY_P11;
wire            HREADYOUT_P11;
wire    [31:0]  HRDATA_P11;
wire            HRESP_P11;


AHBlite_Interconnect Interconncet(
        .HCLK           (clk),
        .HRESETn        (cpuresetn),

        // CORE SIDE
        .HADDR          (HADDR),
        .HTRANS         (HTRANS),
        .HSIZE          (HSIZE),
        .HBURST         (HBURST),
        .HPROT          (HPROT),
        .HMASTLOCK      (HMASTLOCK),
        .HWRITE         (HWRITE),
        .HWDATA         (HWDATA),
        .HRDATA         (HRDATA),
        .HREADY         (HREADY),
        .HRESP          (HRESP),

        // P0
        .HSEL_P0        (HSEL_P0),
        .HADDR_P0       (HADDR_P0),
        .HBURST_P0      (HBURST_P0),
        .HMASTLOCK_P0   (HMASTLOCK_P0),
        .HPROT_P0       (HPROT_P0),
        .HSIZE_P0       (HSIZE_P0),
        .HTRANS_P0      (HTRANS_P0),
        .HWDATA_P0      (HWDATA_P0),
        .HWRITE_P0      (HWRITE_P0),
        .HREADY_P0      (HREADY_P0),
        .HREADYOUT_P0   (HREADYOUT_P0),
        .HRDATA_P0      (HRDATA_P0),
        .HRESP_P0       (HRESP_P0),

        // P1
        .HSEL_P1        (HSEL_P1),
        .HADDR_P1       (HADDR_P1),
        .HBURST_P1      (HBURST_P1),
        .HMASTLOCK_P1   (HMASTLOCK_P1),
        .HPROT_P1       (HPROT_P1),
        .HSIZE_P1       (HSIZE_P1),
        .HTRANS_P1      (HTRANS_P1),
        .HWDATA_P1      (HWDATA_P1),
        .HWRITE_P1      (HWRITE_P1),
        .HREADY_P1      (HREADY_P1),
        .HREADYOUT_P1   (HREADYOUT_P1),
        .HRDATA_P1      (HRDATA_P1),
        .HRESP_P1       (HRESP_P1),

        // P2
        .HSEL_P2        (HSEL_P2),
        .HADDR_P2       (HADDR_P2),
        .HBURST_P2      (HBURST_P2),
        .HMASTLOCK_P2   (HMASTLOCK_P2),
        .HPROT_P2       (HPROT_P2),
        .HSIZE_P2       (HSIZE_P2),
        .HTRANS_P2      (HTRANS_P2),
        .HWDATA_P2      (HWDATA_P2),
        .HWRITE_P2      (HWRITE_P2),
        .HREADY_P2      (HREADY_P2),
        .HREADYOUT_P2   (HREADYOUT_P2),
        .HRDATA_P2      (HRDATA_P2),
        .HRESP_P2       (HRESP_P2),

        // P3
        .HSEL_P3        (HSEL_P3),
        .HADDR_P3       (HADDR_P3),
        .HBURST_P3      (HBURST_P3),
        .HMASTLOCK_P3   (HMASTLOCK_P3),
        .HPROT_P3       (HPROT_P3),
        .HSIZE_P3       (HSIZE_P3),
        .HTRANS_P3      (HTRANS_P3),
        .HWDATA_P3      (HWDATA_P3),
        .HWRITE_P3      (HWRITE_P3),
        .HREADY_P3      (HREADY_P3),
        .HREADYOUT_P3   (HREADYOUT_P3),
        .HRDATA_P3      (HRDATA_P3),
        .HRESP_P3       (HRESP_P3),
		
        // P4
        .HSEL_P4        (HSEL_P4),
        .HADDR_P4       (HADDR_P4),
        .HBURST_P4      (HBURST_P4),
        .HMASTLOCK_P4   (HMASTLOCK_P4),
        .HPROT_P4       (HPROT_P4),
        .HSIZE_P4       (HSIZE_P4),
        .HTRANS_P4      (HTRANS_P4),
        .HWDATA_P4      (HWDATA_P4),
        .HWRITE_P4      (HWRITE_P4),
        .HREADY_P4      (HREADY_P4),
        .HREADYOUT_P4   (HREADYOUT_P4),
        .HRDATA_P4      (HRDATA_P4),
        .HRESP_P4       (HRESP_P4),
		
        // P5
        .HSEL_P5        (HSEL_P5),
        .HADDR_P5       (HADDR_P5),
        .HBURST_P5      (HBURST_P5),
        .HMASTLOCK_P5   (HMASTLOCK_P5),
        .HPROT_P5       (HPROT_P5),
        .HSIZE_P5       (HSIZE_P5),
        .HTRANS_P5      (HTRANS_P5),
        .HWDATA_P5      (HWDATA_P5),
        .HWRITE_P5      (HWRITE_P5),
        .HREADY_P5      (HREADY_P5),
        .HREADYOUT_P5   (HREADYOUT_P5),
        .HRDATA_P5      (HRDATA_P5),
        .HRESP_P5       (HRESP_P5),
			
        // P6
        .HSEL_P6        (HSEL_P6),
        .HADDR_P6       (HADDR_P6),
        .HBURST_P6      (HBURST_P6),
        .HMASTLOCK_P6   (HMASTLOCK_P6),
        .HPROT_P6       (HPROT_P6),
        .HSIZE_P6       (HSIZE_P6),
        .HTRANS_P6      (HTRANS_P6),
        .HWDATA_P6      (HWDATA_P6),
        .HWRITE_P6      (HWRITE_P6),
        .HREADY_P6      (HREADY_P6),
        .HREADYOUT_P6   (HREADYOUT_P6),
        .HRDATA_P6      (HRDATA_P6),
        .HRESP_P6       (HRESP_P6),
				
        // P7
        .HSEL_P7        (HSEL_P7),
        .HADDR_P7       (HADDR_P7),
        .HBURST_P7      (HBURST_P7),
        .HMASTLOCK_P7   (HMASTLOCK_P7),
        .HPROT_P7       (HPROT_P7),
        .HSIZE_P7       (HSIZE_P7),
        .HTRANS_P7      (HTRANS_P7),
        .HWDATA_P7      (HWDATA_P7),
        .HWRITE_P7      (HWRITE_P7),
        .HREADY_P7      (HREADY_P7),
        .HREADYOUT_P7   (HREADYOUT_P7),
        .HRDATA_P7      (HRDATA_P7),
        .HRESP_P7       (HRESP_P7),
				
        // P8
        .HSEL_P8        (HSEL_P8),
        .HADDR_P8       (HADDR_P8),
        .HBURST_P8      (HBURST_P8),
        .HMASTLOCK_P8   (HMASTLOCK_P8),
        .HPROT_P8       (HPROT_P8),
        .HSIZE_P8       (HSIZE_P8),
        .HTRANS_P8      (HTRANS_P8),
        .HWDATA_P8      (HWDATA_P8),
        .HWRITE_P8      (HWRITE_P8),
        .HREADY_P8      (HREADY_P8),
        .HREADYOUT_P8   (HREADYOUT_P8),
        .HRDATA_P8      (HRDATA_P8),
        .HRESP_P8       (HRESP_P8),
					
        // P9
        .HSEL_P9        (HSEL_P9),
        .HADDR_P9       (HADDR_P9),
        .HBURST_P9      (HBURST_P9),
        .HMASTLOCK_P9   (HMASTLOCK_P9),
        .HPROT_P9       (HPROT_P9),
        .HSIZE_P9       (HSIZE_P9),
        .HTRANS_P9      (HTRANS_P9),
        .HWDATA_P9      (HWDATA_P9),
        .HWRITE_P9      (HWRITE_P9),
        .HREADY_P9      (HREADY_P9),
        .HREADYOUT_P9   (HREADYOUT_P9),
        .HRDATA_P9      (HRDATA_P9),
        .HRESP_P9       (HRESP_P9),
					
        // P10
        .HSEL_P10        (HSEL_P10),
        .HADDR_P10       (HADDR_P10),
        .HBURST_P10      (HBURST_P10),
        .HMASTLOCK_P10   (HMASTLOCK_P10),
        .HPROT_P10       (HPROT_P10),
        .HSIZE_P10       (HSIZE_P10),
        .HTRANS_P10      (HTRANS_P10),
        .HWDATA_P10      (HWDATA_P10),
        .HWRITE_P10      (HWRITE_P10),
        .HREADY_P10      (HREADY_P10),
        .HREADYOUT_P10   (HREADYOUT_P10),
        .HRDATA_P10      (HRDATA_P10),
        .HRESP_P10       (HRESP_P10),
					
        // P11
        .HSEL_P11        (HSEL_P11),
        .HADDR_P11       (HADDR_P11),
        .HBURST_P11      (HBURST_P11),
        .HMASTLOCK_P11   (HMASTLOCK_P11),
        .HPROT_P11       (HPROT_P11),
        .HSIZE_P11       (HSIZE_P11),
        .HTRANS_P11      (HTRANS_P11),
        .HWDATA_P11      (HWDATA_P11),
        .HWRITE_P11      (HWRITE_P11),
        .HREADY_P11	     (HREADY_P11),
        .HREADYOUT_P11   (HREADYOUT_P11),
        .HRDATA_P11      (HRDATA_P11),
        .HRESP_P11       (HRESP_P11)
);

//------------------------------------------------------------------------------
// AHB RAMCODE
//------------------------------------------------------------------------------

wire [31:0] RAMCODE_RDATA,RAMCODE_WDATA;
wire [13:0] RAMCODE_WADDR;
wire [13:0] RAMCODE_RADDR;
wire [3:0]  RAMCODE_WRITE;

AHBlite_Block_RAM RAMCODE_Interface(
        /* Connect to Interconnect Port 0 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P0),
        .HADDR          (HADDR_P0),
        .HPROT          (HPROT_P0),
        .HSIZE          (HSIZE_P0),
        .HTRANS         (HTRANS_P0),
        .HWDATA         (HWDATA_P0),
        .HWRITE         (HWRITE_P0),
        .HRDATA         (HRDATA_P0),
        .HREADY         (HREADY_P0),
        .HREADYOUT      (HREADYOUT_P0),
        .HRESP          (HRESP_P0),
        .BRAM_WRADDR    (RAMCODE_WADDR),
        .BRAM_RDADDR    (RAMCODE_RADDR),
        .BRAM_RDATA     (RAMCODE_RDATA),
        .BRAM_WDATA     (RAMCODE_WDATA),
        .BRAM_WRITE     (RAMCODE_WRITE)
        /**********************************/
);

//------------------------------------------------------------------------------
// AHB RAMDATA
//------------------------------------------------------------------------------

wire [31:0] RAMDATA_RDATA;
wire [31:0] RAMDATA_WDATA;
wire [13:0] RAMDATA_WADDR;
wire [13:0] RAMDATA_RADDR;
wire [3:0]  RAMDATA_WRITE;

AHBlite_Block_RAM RAMDATA_Interface(
        /* Connect to Interconnect Port 1 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P1),
        .HADDR          (HADDR_P1),
        .HPROT          (HPROT_P1),
        .HSIZE          (HSIZE_P1),
        .HTRANS         (HTRANS_P1),
        .HWDATA         (HWDATA_P1),
        .HWRITE         (HWRITE_P1),
        .HRDATA         (HRDATA_P1),
        .HREADY         (HREADY_P1),
        .HREADYOUT      (HREADYOUT_P1),
        .HRESP          (HRESP_P1),
        .BRAM_WRADDR    (RAMDATA_WADDR),
        .BRAM_RDADDR    (RAMDATA_RADDR),
        .BRAM_WDATA     (RAMDATA_WDATA),
        .BRAM_RDATA     (RAMDATA_RDATA),
        .BRAM_WRITE     (RAMDATA_WRITE)
        /**********************************/
);


//------------------------------------------------------------------------------
// AHB LED
//------------------------------------------------------------------------------

AHBlite_LED LED_Interface(
        /* Connect to Interconnect Port 2 */
        .HCLK                   (clk),
        .HRESETn                (cpuresetn),
        .HSEL                   (HSEL_P2),
        .HADDR                  (HADDR_P2),
        .HPROT                  (HPROT_P2),
        .HSIZE                  (HSIZE_P2),
        .HTRANS                 (HTRANS_P2),
        .HWDATA                 (HWDATA_P2),
        .HWRITE                 (HWRITE_P2),
        .HRDATA                 (HRDATA_P2),
        .HREADY                 (HREADY_P2),
        .HREADYOUT              (HREADYOUT_P2),
        .HRESP                  (HRESP_P2),
        .LED			(LED),
        .signal_LED             (signal_LED)
        /**********************************/ 
);

//------------------------------------------------------------------------------
// AHB TIMER
//------------------------------------------------------------------------------

AHBlite_Timer Timer_Interface(
        /* Connect to Interconnect Port 3 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P3),
        .HADDR          (HADDR_P3),
        .HPROT          (HPROT_P3),
        .HSIZE          (HSIZE_P3),
        .HTRANS         (HTRANS_P3),
        .HWDATA         (HWDATA_P3),
        .HWRITE         (HWRITE_P3),
        .HRDATA         (HRDATA_P3),
        .HREADY         (HREADY_P3),
        .HREADYOUT      (HREADYOUT_P3),
        .HRESP          (HRESP_P3),
        .timer_irq	(timer_interrupt)
		
);

//------------------------------------------------------------------------------
// AHB Matrix_Key
//------------------------------------------------------------------------------

AHBlite_Matrix_Key Matrix_Key_Interface(
        /* Connect to Interconnect Port 4 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P4),
        .HADDR          (HADDR_P4),
        .HPROT          (HPROT_P4),
        .HSIZE          (HSIZE_P4),
        .HTRANS         (HTRANS_P4),
        .HWDATA         (HWDATA_P4),
        .HWRITE         (HWRITE_P4),
        .HRDATA         (HRDATA_P4),
        .HREADY         (HREADY_P4),
        .HREADYOUT      (HREADYOUT_P4),
        .HRESP          (HRESP_P4),
        .Row			(Row),
	.Col			(Col)
        /**********************************/ 
);

//------------------------------------------------------------------------------
// AHB SEG
//------------------------------------------------------------------------------

AHBlite_SEG SEG_Interface(
        /* Connect to Interconnect Port 5 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P5),
        .HADDR          (HADDR_P5),
        .HPROT          (HPROT_P5),
        .HSIZE          (HSIZE_P5),
        .HTRANS         (HTRANS_P5),
        .HWDATA         (HWDATA_P5),
        .HWRITE         (HWRITE_P5),
        .HRDATA         (HRDATA_P5),
        .HREADY         (HREADY_P5),
        .HREADYOUT      (HREADYOUT_P5),
        .HRESP          (HRESP_P5),
        .seg_sel	(seg_sel),
	.seg_led	(seg_led)
		
);

//------------------------------------------------------------------------------
// AHB SD
//------------------------------------------------------------------------------

wire rd_data_en;
wire [15:0] rd_data;

AHBlite_SD AHBlite_SD_Interface(
        /* Connect to Interconnect Port 6 */
        .HCLK                   (clk),    
        .HRESETn                (cpuresetn), 
        .HSEL                   (HSEL_P6),    
        .HADDR                  (HADDR_P6),   
        .HTRANS                 (HTRANS_P6),  
        .HSIZE                  (HSIZE_P6),   
        .HPROT                  (HPROT_P6),   
        .HWRITE                 (HWRITE_P6),  
        .HWDATA                 (HWDATA_P6),   
        .HREADY                 (HREADY_P6), 
        .HREADYOUT              (HREADYOUT_P6), 
        .HRDATA                 (HRDATA_P6),  
        .HRESP                  (HRESP_P6),
        .SD_clk_shift           (SD_clk_shift),
        .SD_D                   (SD_D),
        .SD_CLK                 (SD_CLK),
        .miso                   (miso),
        .cs_n                   (cs_n),
        .mosi                   (mosi),
        .ADDR_state             (ADDR_state),
        .rd_data_en             (rd_data_en),
        .rd_data                (rd_data),
        .init_end               (SD_init_end)
);

//------------------------------------------------------------------------------
// AHB UART
//------------------------------------------------------------------------------

wire state_1;
wire [7:0] UART1_RX_data;
wire [7:0] UART1_TX_data;
wire tx1_en;


AHBlite_UART UART_Interface(
        /* Connect to Interconnect Port 7 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P7),
        .HADDR          (HADDR_P7),
        .HPROT          (HPROT_P7),
        .HSIZE          (HSIZE_P7),
        .HTRANS         (HTRANS_P7),
        .HWDATA         (HWDATA_P7),
        .HWRITE         (HWRITE_P7),
        .HRDATA         (HRDATA_P7),
        .HREADY         (HREADY_P7),
        .HREADYOUT      (HREADYOUT_P7),
        .HRESP          (HRESP_P7),
        .UART_RX        (UART1_RX_data),
        .state          (state_1),
        .tx_en          (tx1_en),
        .UART_TX        (UART1_TX_data)
);


//------------------------------------------------------------------------------
// AHB PINTO
//------------------------------------------------------------------------------

wire PINTO_en;

AHBlite_PINTO PINTO_Interface(
        /* Connect to Interconnect Port 8 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P8),
        .HADDR          (HADDR_P8),
        .HPROT          (HPROT_P8),
        .HSIZE          (HSIZE_P8),
        .HTRANS         (HTRANS_P8),
        .HWDATA         (HWDATA_P8),
        .HWRITE         (HWRITE_P8),
        .HRDATA         (HRDATA_P8),
        .HREADY         (HREADY_P8),
        .HREADYOUT      (HREADYOUT_P8),
        .HRESP          (HRESP_P8),
        .PINTO_en       (PINTO_en)
);


//------------------------------------------------------------------------------
// AHB Bayer2RGB
//------------------------------------------------------------------------------

wire Bayer2RGB_en;

AHBlite_Bayer2RGB Bayer2RGB_Interface(
        /* Connect to Interconnect Port 9 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P9),
        .HADDR          (HADDR_P9),
        .HPROT          (HPROT_P9),
        .HSIZE          (HSIZE_P9),
        .HTRANS         (HTRANS_P9),
        .HWDATA         (HWDATA_P9),
        .HWRITE         (HWRITE_P9),
        .HRDATA         (HRDATA_P9),
        .HREADY         (HREADY_P9),
        .HREADYOUT      (HREADYOUT_P9),
        .HRESP          (HRESP_P9),
        .Bayer2RGB_en   (Bayer2RGB_en)
);

//------------------------------------------------------------------------------
// AHB MedFilter
//------------------------------------------------------------------------------

wire MedFilter_en;

AHBlite_MedFilter MedFilter_Interface(
        /* Connect to Interconnect Port 10 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P10),
        .HADDR          (HADDR_P10),
        .HPROT          (HPROT_P10),
        .HSIZE          (HSIZE_P10),
        .HTRANS         (HTRANS_P10),
        .HWDATA         (HWDATA_P10),
        .HWRITE         (HWRITE_P10),
        .HRDATA         (HRDATA_P10),
        .HREADY         (HREADY_P10),
        .HREADYOUT      (HREADYOUT_P10),
        .HRESP          (HRESP_P10),
        .MedFilter_en   (MedFilter_en)
);


//------------------------------------------------------------------------------
// AHB Gamma
//------------------------------------------------------------------------------

wire Gamma_en;

AHBlite_Gamma Gamma_Interface(
        /* Connect to Interconnect Port 11 */
        .HCLK           (clk),
        .HRESETn        (cpuresetn),
        .HSEL           (HSEL_P11),
        .HADDR          (HADDR_P11),
        .HPROT          (HPROT_P11),
        .HSIZE          (HSIZE_P11),
        .HTRANS         (HTRANS_P11),
        .HWDATA         (HWDATA_P11),
        .HWRITE         (HWRITE_P11),
        .HRDATA         (HRDATA_P11),
        .HREADY         (HREADY_P11),
        .HREADYOUT      (HREADYOUT_P11),
        .HRESP          (HRESP_P11),
        .Gamma_en       (Gamma_en)
);


//------------------------------------------------------------------------------
// RAM
//------------------------------------------------------------------------------

Block_RAM RAM_CODE(
        .clka           (clk),
        .addra          (RAMCODE_WADDR),
        .addrb          (RAMCODE_RADDR),
        .dina           (RAMCODE_WDATA),
        .doutb          (RAMCODE_RDATA),
        .wea            (RAMCODE_WRITE)
);

Block_RAM RAM_DATA(
        .clka           (clk),
        .addra          (RAMDATA_WADDR),
        .addrb          (RAMDATA_RADDR),
        .dina           (RAMDATA_WDATA),
        .doutb          (RAMDATA_RDATA),
        .wea            (RAMDATA_WRITE)
);

//------------------------------------------------------------------------------
// SDRAM
//------------------------------------------------------------------------------
wire tft_begin;
//对tft_begin进行同步
reg [1:0]tft_begin_r;	
always@(posedge pixel_clk)
        tft_begin_r <= {tft_begin_r[0],tft_begin};

wire data_req;
wire [7:0] pixel_data;

sdram_rw_top sdram_rw_top_inst(
        .clk_sdr_ctrl    (clk_sdr_ctrl),
        .clk_sdram       (clk_sdram),
        .rst_n           (RSTn),		
        .wr_clk          (clk),                   //写端口FIFO: 写时钟
        .wr_en           (rd_data_en),                    //写端口FIFO: 写使能
        .wr_data         (rd_data[15:8]),                  //写端口FIFO: 写数据
        .wr_len          (256),                   //写SDRAM时的数据突发长度
        .wr_load         (~RSTn),                  //写端口复位: 复位写地址,清空写FIFO
        .rd_clk          (pixel_clk),                   //读端口FIFO: 读时钟
        .rd_en           (data_req),                    //读端口FIFO: 读使能
        .rd_data         (pixel_data),                  //读端口FIFO: 读数据
        .rd_len          (256),                   //从SDRAM中读数据时的突发长度
        .rd_load         (tft_begin_r[1]),                  //读端口复位: 复位读地址,清空读FIFO
        .sdram_read_valid(1'b1),
        .sdram_init_done (sdram_init_done)          //SDRAM 初始化完成标志
);

//------------------------------------------------------------------------------
// video_driver
//------------------------------------------------------------------------------

wire          video_hs;
wire          video_vs;
wire          video_de;
wire  [7:0]   video_data;

wire system_init_end;
assign system_init_end = SD_init_end & sdram_init_done;



video_driver    video_driver_inst(
        .pixel_clk	(pixel_clk),
        .sys_rst_n	(system_init_end),
        .video_hs	(video_hs),    //行同步信号
        .video_vs	(video_vs),    //场同步信号
        .video_de       (video_de),
        .video_data	(video_data),   
        .data_req 	(data_req),
        .pixel_data	(pixel_data),   //像素点数据
        .TFT_begin      (tft_begin)
);



//------------------------------------------------------------------------------
// UART
//------------------------------------------------------------------------------

wire clk_uart1;
wire bps_en1;
wire bps_en1_rx,bps_en1_tx;

assign bps_en1 = bps_en1_rx | bps_en1_tx;


clkuart_pwm clkuart1_pwm(
        .clk(clk),
        .RSTn(cpuresetn),
        .clk_uart(clk_uart1),
        .bps_en(bps_en1)
);

UART_RX UART1_RX(
        .clk(clk),
        .clk_uart(clk_uart1),
        .RSTn(cpuresetn),
        .RXD(RXD_1),
        .data(UART1_RX_data),
        .interrupt(UART1_interrupt),
        .bps_en(bps_en1_rx)
);

UART_TX UART1_TX(
        .clk(clk),
        .clk_uart(clk_uart1),
        .RSTn(cpuresetn),
        .data(UART1_TX_data),
        .tx_en(tx1_en),
        .TXD(TXD_1),
        .state(state_1),
        .bps_en(bps_en1_tx)
);


//------------------------------------------------------------------------------
// PINTO
//------------------------------------------------------------------------------

wire       PINTO_img_vsync;
wire       PINTO_img_href;
wire       PINTO_img_de;
wire [7:0] PINTO_img_gray;

PINTO PINTO_inst(
    .clk                (pixel_clk),
    .rst_n              (cpuresetn),
    .PINTO_en           (PINTO_en),
    .per_img_vsync      (video_vs),
    .per_img_href       (video_hs),
    .per_img_de         (video_de),
    .per_img_gray       (video_data),
    .post_img_vsync     (PINTO_img_vsync),
    .post_img_href      (PINTO_img_href),
    .post_img_de        (PINTO_img_de),
    .post_img_gray      (PINTO_img_gray)
);

//------------------------------------------------------------------------------
// Bayer2RGB
//------------------------------------------------------------------------------

wire       Bayer2RGB_img_vsync;
wire       Bayer2RGB_img_href;
wire       Bayer2RGB_img_de;
wire [7:0] Bayer2RGB_img_red;
wire [7:0] Bayer2RGB_img_green;
wire [7:0] Bayer2RGB_img_blue;

Bayer2RGB Bayer2RGB_inst
(
    .clk                (pixel_clk),
    .rst_n              (cpuresetn),
    .Bayer2RGB_en       (Bayer2RGB_en),
    .per_img_vsync      (PINTO_img_vsync),
    .per_img_href       (PINTO_img_href),
    .per_img_de         (PINTO_img_de),
    .per_img_gray       (PINTO_img_gray),
    .post_img_vsync     (Bayer2RGB_img_vsync),
    .post_img_href      (Bayer2RGB_img_href),
    .post_img_de        (Bayer2RGB_img_de),
    .post_img_red       (Bayer2RGB_img_red),
    .post_img_green     (Bayer2RGB_img_green),
    .post_img_blue      (Bayer2RGB_img_blue)
);


//------------------------------------------------------------------------------
// MedFilter
//------------------------------------------------------------------------------

wire       MedFilter_img_vsync;
wire       MedFilter_img_href;
wire       MedFilter_img_de;
wire [7:0] MedFilter_img_red;
wire [7:0] MedFilter_img_green;
wire [7:0] MedFilter_img_blue;

med_filter_proc med_filter_proc__red_inst(
    .clk                (pixel_clk),
    .rst_n              (cpuresetn),
    .MedFilter_en       (MedFilter_en),
    .per_img_vsync      (Bayer2RGB_img_vsync),
    .per_img_href       (Bayer2RGB_img_href),
    .per_img_de         (Bayer2RGB_img_de),
    .per_img_gray       (Bayer2RGB_img_red),
    .post_img_vsync     (MedFilter_img_vsync),
    .post_img_href      (MedFilter_img_href),
    .post_img_de        (MedFilter_img_de),
    .post_img_gray      (MedFilter_img_red)
);


med_filter_proc med_filter_proc_green_inst(
    .clk                (pixel_clk),
    .rst_n              (cpuresetn),
    .MedFilter_en       (MedFilter_en),
    .per_img_vsync      (Bayer2RGB_img_vsync),
    .per_img_href       (Bayer2RGB_img_href),
    .per_img_de         (Bayer2RGB_img_de),
    .per_img_gray       (Bayer2RGB_img_green),
    .post_img_vsync     (),
    .post_img_href      (),
    .post_img_de        (),
    .post_img_gray      (MedFilter_img_green)
);


med_filter_proc med_filter_proc_inst(
    .clk                (pixel_clk),
    .rst_n              (cpuresetn),
    .MedFilter_en       (MedFilter_en),
    .per_img_vsync      (Bayer2RGB_img_vsync),
    .per_img_href       (Bayer2RGB_img_href),
    .per_img_de         (Bayer2RGB_img_de),
    .per_img_gray       (Bayer2RGB_img_blue),
    .post_img_vsync     (),
    .post_img_href      (),
    .post_img_de        (),
    .post_img_gray      (MedFilter_img_blue)
);


//------------------------------------------------------------------------------
// Gamma
//------------------------------------------------------------------------------
wire [7:0] Gamma_img_red;

Curve_Gamma_2P2 Curve_Gamma_2P2_inst_red
(
   .Pre_Data    (MedFilter_img_red),
   .Gamma_en    (Gamma_en),
   .Gamma_Data  (Gamma_img_red)
);


wire [7:0] Gamma_img_green;

Curve_Gamma_2P2 Curve_Gamma_2P2_inst_green
(
   .Pre_Data    (MedFilter_img_green),
   .Gamma_en    (Gamma_en),
   .Gamma_Data  (Gamma_img_green)
);


wire [7:0] Gamma_img_blue;

Curve_Gamma_2P2 Curve_Gamma_2P2_inst_blue
(
   .Pre_Data    (MedFilter_img_blue),
   .Gamma_en    (Gamma_en),
   .Gamma_Data  (Gamma_img_blue)
);



//------------------------------------------------------------------------------
// HDMI
//------------------------------------------------------------------------------

wire HDMI_HS;
wire HDMI_VS;
wire HDMI_DE;

video_1936x1088_to_1920x1080 video_1936x1088_to_1920x1080_inst(
    .pixel_clk  (pixel_clk),
    .rst_n      (cpuresetn),
    .i_hs       (MedFilter_img_href),
    .i_vs       (MedFilter_img_vsync),
    .i_de       (MedFilter_img_de),
    .o_hs       (HDMI_HS),
    .o_vs       (HDMI_VS),
    .o_de       (HDMI_DE)
);


    hdmi_tx #(.FAMILY("EG4"))	//EF2、EF3、EG4、AL3、PH1

    u3_hdmi_tx
        (
            .PXLCLK_I(pixel_clk),
            .PXLCLK_5X_I(pixel_clk_5x),

            .RST_N (~cpuresetn),
            
            //VGA
            .VGA_HS (HDMI_HS ),
            .VGA_VS (HDMI_VS ),
            .VGA_DE (HDMI_DE ),
            .VGA_RGB({Gamma_img_red, Gamma_img_green, Gamma_img_blue}),

            //HDMI
            .HDMI_CLK_P(HDMI_CLK_P),
            .HDMI_D2_P (HDMI_D2_P ),
            .HDMI_D1_P (HDMI_D1_P ),
            .HDMI_D0_P (HDMI_D0_P )	
            
        );


endmodule
