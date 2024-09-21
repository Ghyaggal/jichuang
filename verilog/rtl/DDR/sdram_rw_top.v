module sdram_rw_top (
    input   clk_sdr_ctrl,
    input   clk_sdram,
    input   rst_n,

    //用户写端口			
	input         wr_clk,                   //写端口FIFO: 写时钟
	input         wr_en,                    //写端口FIFO: 写使能
	input  [7:0] wr_data,                  //写端口FIFO: 写数据
	input  [ 8:0] wr_len,                   //写SDRAM时的数据突发长度
	input         wr_load,                  //写端口复位: 复位写地址,清空写FIFO

    //用户读端口
	input         rd_clk,                   //读端口FIFO: 读时钟
	input         rd_en,                    //读端口FIFO: 读使能
	output [7:0] rd_data,                  //读端口FIFO: 读数据
	input  [ 8:0] rd_len,                   //从SDRAM中读数据时的突发长度
	input         rd_load,                  //读端口复位: 复位读地址,清空读FIFO
    input         sdram_read_valid,
    output        sdram_init_done          //SDRAM 初始化完成标志

);
    
    //SDRAM 芯片接口
    wire        sdram_cke;                //SDRAM 时钟有效
    wire        sdram_cs_n;               //SDRAM 片选
    wire        sdram_ras_n;              //SDRAM 行有效
    wire        sdram_cas_n;              //SDRAM 列有效
    wire        sdram_we_n;               //SDRAM 写有效
    wire [ 1:0] sdram_ba;                 //SDRAM Bank地址
    wire [10:0] sdram_addr;               //SDRAM 行/列地址
    wire [31:0] sdram_data;               //SDRAM 数据
    wire [ 1:0] sdram_dqm;                //SDRAM 数据掩码    

    //SDRAM 控制器顶层模块,封装成FIFO接口
    //SDRAM 控制器地址组成: {bank_addr[1:0],row_addr[10:0],col_addr[7:0]}
    sdram_top u_sdram_top(
        .ref_clk			(clk_sdr_ctrl),			//sdram	控制器参考时钟
        .rst_n				(rst_n),		//系统复位
        
        //用户写端口
        .wr_clk 			(wr_clk),		    //写端口FIFO: 写时钟
        .wr_en				(wr_en),			//写端口FIFO: 写使能
        .wr_data		    (wr_data),		    //写端口FIFO: 写数据
        .wr_len			    (wr_len),			//写SDRAM时的数据突发长度
        .wr_load			(wr_load),		//写端口复位: 复位写地址,清空写FIFO
    
        //用户读端口
        .rd_clk 			(rd_clk),			//读端口FIFO: 读时钟
        .rd_en				(rd_en),			//读端口FIFO: 读使能
        .rd_data	    	(rd_data),		    //读端口FIFO: 读数据
        .rd_len 			(rd_len),			//从SDRAM中读数据时的突发长度
        .rd_load			(rd_load),		//读端口复位: 复位读地址,清空读FIFO
        
        //用户控制端口  
        .sdram_read_valid	(sdram_read_valid),             //SDRAM 读使能
        .sdram_init_done	(sdram_init_done),	//SDRAM 初始化完成标志
    
        //SDRAM 芯片接口
    //	.sdram_clk			(sdram_clk),        //SDRAM 芯片时钟
        .sdram_cke			(sdram_cke),        //SDRAM 时钟有效
        .sdram_cs_n			(sdram_cs_n),       //SDRAM 片选
        .sdram_ras_n		(sdram_ras_n),      //SDRAM 行有效
        .sdram_cas_n		(sdram_cas_n),      //SDRAM 列有效
        .sdram_we_n			(sdram_we_n),       //SDRAM 写有效
        .sdram_ba			(sdram_ba),         //SDRAM Bank地址
        .sdram_addr			(sdram_addr),       //SDRAM 行/列地址
        .sdram_data			(sdram_data),       //SDRAM 数据
        .sdram_dqm			(sdram_dqm)         //SDRAM 数据掩码
        );



    SDRAM SDRAM_inst
    (
        .clk(clk_sdram),        //SDRAM 芯片时钟
        .ras_n(sdram_ras_n),    //SDRAM 行有效
        .cas_n(sdram_cas_n),    //SDRAM 列有效
        .we_n(sdram_we_n),      //SDRAM 写有效
        .addr(sdram_addr),      //SDRAM 行/列地址
        .ba(sdram_ba),      	//SDRAM Bank地址
        .dq(sdram_data),		//SDRAM 数据
        .cs_n(sdram_cs_n),  	//SDRAM 片选
        .dm0(1'b0),
        .dm1(1'b0),
        .dm2(1'b0),
        .dm3(1'b0),
        .cke(sdram_cke)  //SDRAM 时钟有效
    );
endmodule