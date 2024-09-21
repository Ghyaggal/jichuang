module AHBlite_Decoder
#(
    /*RAMCODE enable parameter*/
    parameter Port0_en = 1,
    /************************/

    /*RAMDATA enable parameter*/
    parameter Port1_en = 1,
    /************************/

    /*LED enable parameter*/
    parameter Port2_en = 1,
    /************************/

    /*TIMER enable parameter*/
    parameter Port3_en = 1,
    /************************/

    /*Matrix_Key enable parameter*/
    parameter Port4_en = 1,
    /************************/

	/*SEG enable parameter*/
    parameter Port5_en = 1,
    /************************/
	
	/*SD enable parameter*/
    parameter Port6_en = 1,
    /************************/	
	
	/*UART1 enable parameter*/
    parameter Port7_en = 1,
    /************************/
	
	/*PINTO enable parameter*/
    parameter Port8_en = 1,
    /************************/
	
	/*Bayer2RGB enable parameter*/
    parameter Port9_en = 1,
    /************************/
	
	/*MedFilter enable parameter*/
    parameter Port10_en = 1,
    /************************/
	
	/*Gamma enable parameter*/
    parameter Port11_en = 1
    /************************/
	  
)(
    input [31:0] HADDR,

    /*RAMCODE OUTPUT SELECTION SIGNAL*/
    output wire P0_HSEL,

    /*RAMDATA OUTPUT SELECTION SIGNAL*/
    output wire P1_HSEL,

    /*LED OUTPUT SELECTION SIGNAL*/
    output wire P2_HSEL,

    /*TIMER OUTPUT SELECTION SIGNAL*/
    output wire P3_HSEL,      

    /*Matrix_Key OUTPUT SELECTION SIGNAL*/
    output wire P4_HSEL,

    /*SEG OUTPUT SELECTION SIGNAL*/
    output wire P5_HSEL,	
	
    /*TIMER OUTPUT SELECTION SIGNAL*/
    output wire P6_HSEL,
	
    /*UART1 OUTPUT SELECTION SIGNAL*/
    output wire P7_HSEL,
	
    /*PINTO OUTPUT SELECTION SIGNAL*/
    output wire P8_HSEL,
	
    /*Bayer2RGB OUTPUT SELECTION SIGNAL*/
    output wire P9_HSEL,
	
    /*MedFilter OUTPUT SELECTION SIGNAL*/
    output wire P10_HSEL,
	
    /*Gamma OUTPUT SELECTION SIGNAL*/
    output wire P11_HSEL
);

//RAMCODE-----------------------------------

//0x00000000-0x0000ffff
/*Insert RAMCODE decoder code there*/
assign P0_HSEL = (HADDR[31:16]==16'h0000)? Port0_en : 1'b0;
/***********************************/

//RAMDATA-----------------------------
//0X20000000-0X2000FFFF
/*Insert RAMDATA decoder code there*/
assign P1_HSEL = (HADDR[31:16]==16'h2000)? Port1_en : 1'b0;
/***********************************/

//PERIPHRAL-----------------------------

//0X40000000 LED
//0X40000004 signal_LED
/*Insert LED decoder code there*/
assign P2_HSEL = (HADDR[31:16]==16'h4000)? Port2_en : 1'b0;
/***********************************/

//0X40010000 LOAD
//0X40010004 ENABLE
//0X40010008 VALUE
/*Insert TIMER decoder code there*/
assign P3_HSEL = (HADDR[31:16] == 16'h4001) ? Port3_en : 1'b0;
/***********************************/

//0x40020000 Row
//0x40020004 Col
/*Insert Matrix_Key decoder code there*/
assign P4_HSEL = (HADDR[31:16] == 16'h4002) ? Port4_en : 1'b0;
/***********************************/


//0x40030000 Data
/*Insert SEG decoder code there*/
assign P5_HSEL = (HADDR[31:16] == 16'h4003) ? Port5_en : 1'b0;
/***********************************/


//0x40040000 ADDR_DATA
//0x40040004 stop
//0x40040008 remake
/*Insert SD decoder code there*/
assign P6_HSEL = (HADDR[31:16] == 16'h4004) ? Port6_en : 1'b0;
/***********************************/


//0X40050000 UART RX DATA
//0X40050004 UART TX STATE
//0X40050008 UART TX DATA
/*Insert UART1 decoder code there*/
assign P7_HSEL = (HADDR[31:16] == 16'h4005) ? Port7_en : 1'b0;
/***********************************/


//0X40060000 PINTO_en
/*Insert PINTO decoder code there*/
assign P8_HSEL = (HADDR[31:16] == 16'h4006) ? Port8_en : 1'b0;
/***********************************/

//0X40070000 Bayer2RGB_en
/*Insert Bayer2RGB decoder code there*/
assign P9_HSEL = (HADDR[31:16] == 16'h4007) ? Port9_en : 1'b0;
/***********************************/

//0X40080000 MedFilter_en
/*Insert MedFilter decoder code there*/
assign P10_HSEL = (HADDR[31:16] == 16'h4008) ? Port10_en : 1'b0;
/***********************************/


//0X40090000 Gamma_en
/*Insert Gamma decoder code there*/
assign P11_HSEL = (HADDR[31:16] == 16'h4009) ? Port11_en : 1'b0;
/***********************************/

endmodule