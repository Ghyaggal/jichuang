// Verilog netlist created by Tang Dynasty v5.6.59063
// Mon May 13 20:54:14 2024

`timescale 1ns / 1ps
module line_shift_fifo  // line_shift_fifo.v(14)
  (
  clk,
  di,
  re,
  rst,
  we,
  do,
  empty_flag,
  full_flag
  );

  input clk;  // line_shift_fifo.v(24)
  input [7:0] di;  // line_shift_fifo.v(23)
  input re;  // line_shift_fifo.v(25)
  input rst;  // line_shift_fifo.v(22)
  input we;  // line_shift_fifo.v(24)
  output [7:0] do;  // line_shift_fifo.v(27)
  output empty_flag;  // line_shift_fifo.v(28)
  output full_flag;  // line_shift_fifo.v(29)

  wire empty_flag_syn_2;  // line_shift_fifo.v(28)
  wire full_flag_syn_2;  // line_shift_fifo.v(29)

  EG_PHY_CONFIG #(
    .DONE_PERSISTN("ENABLE"),
    .INIT_PERSISTN("ENABLE"),
    .JTAG_PERSISTN("DISABLE"),
    .PROGRAMN_PERSISTN("DISABLE"))
    config_inst ();
  not empty_flag_syn_1 (empty_flag_syn_2, empty_flag);  // line_shift_fifo.v(28)
  EG_PHY_FIFO #(
    .AE(32'b00000000000000000000000000001100),
    .AEP1(32'b00000000000000000000000000001110),
    .AF(32'b00000000000000000001111111110100),
    .AFM1(32'b00000000000000000001111111110010),
    .ASYNC_RESET_RELEASE("SYNC"),
    .DATA_WIDTH_A("2"),
    .DATA_WIDTH_B("2"),
    .E(32'b00000000000000000000000000000000),
    .EP1(32'b00000000000000000000000000000010),
    .F(32'b00000000000000000010000000000000),
    .FM1(32'b00000000000000000001111111111110),
    .GSR("DISABLE"),
    .MODE("FIFO8K"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("ASYNC"))
    fifo_inst_syn_5 (
    .clkr(clk),
    .clkw(clk),
    .csr({2'b11,empty_flag_syn_2}),
    .csw({2'b11,full_flag_syn_2}),
    .dia({open_n47,open_n48,open_n49,di[1],open_n50,open_n51,di[0],open_n52,open_n53}),
    .orea(1'b0),
    .oreb(1'b0),
    .re(re),
    .rprst(rst),
    .rst(rst),
    .we(we),
    .dob({open_n74,open_n75,open_n76,open_n77,open_n78,open_n79,open_n80,do[1:0]}),
    .empty_flag(empty_flag),
    .full_flag(full_flag));  // line_shift_fifo.v(41)
  EG_PHY_FIFO #(
    .AE(32'b00000000000000000000000000001100),
    .AEP1(32'b00000000000000000000000000001110),
    .AF(32'b00000000000000000001111111110100),
    .AFM1(32'b00000000000000000001111111110010),
    .ASYNC_RESET_RELEASE("SYNC"),
    .DATA_WIDTH_A("2"),
    .DATA_WIDTH_B("2"),
    .E(32'b00000000000000000000000000000000),
    .EP1(32'b00000000000000000000000000000010),
    .F(32'b00000000000000000010000000000000),
    .FM1(32'b00000000000000000001111111111110),
    .GSR("DISABLE"),
    .MODE("FIFO8K"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("ASYNC"))
    fifo_inst_syn_6 (
    .clkr(clk),
    .clkw(clk),
    .csr({2'b11,empty_flag_syn_2}),
    .csw({2'b11,full_flag_syn_2}),
    .dia({open_n81,open_n82,open_n83,di[3],open_n84,open_n85,di[2],open_n86,open_n87}),
    .orea(1'b0),
    .oreb(1'b0),
    .re(re),
    .rprst(rst),
    .rst(rst),
    .we(we),
    .dob({open_n108,open_n109,open_n110,open_n111,open_n112,open_n113,open_n114,do[3:2]}));  // line_shift_fifo.v(41)
  EG_PHY_FIFO #(
    .AE(32'b00000000000000000000000000001100),
    .AEP1(32'b00000000000000000000000000001110),
    .AF(32'b00000000000000000001111111110100),
    .AFM1(32'b00000000000000000001111111110010),
    .ASYNC_RESET_RELEASE("SYNC"),
    .DATA_WIDTH_A("2"),
    .DATA_WIDTH_B("2"),
    .E(32'b00000000000000000000000000000000),
    .EP1(32'b00000000000000000000000000000010),
    .F(32'b00000000000000000010000000000000),
    .FM1(32'b00000000000000000001111111111110),
    .GSR("DISABLE"),
    .MODE("FIFO8K"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("ASYNC"))
    fifo_inst_syn_7 (
    .clkr(clk),
    .clkw(clk),
    .csr({2'b11,empty_flag_syn_2}),
    .csw({2'b11,full_flag_syn_2}),
    .dia({open_n117,open_n118,open_n119,di[5],open_n120,open_n121,di[4],open_n122,open_n123}),
    .orea(1'b0),
    .oreb(1'b0),
    .re(re),
    .rprst(rst),
    .rst(rst),
    .we(we),
    .dob({open_n144,open_n145,open_n146,open_n147,open_n148,open_n149,open_n150,do[5:4]}));  // line_shift_fifo.v(41)
  EG_PHY_FIFO #(
    .AE(32'b00000000000000000000000000001100),
    .AEP1(32'b00000000000000000000000000001110),
    .AF(32'b00000000000000000001111111110100),
    .AFM1(32'b00000000000000000001111111110010),
    .ASYNC_RESET_RELEASE("SYNC"),
    .DATA_WIDTH_A("2"),
    .DATA_WIDTH_B("2"),
    .E(32'b00000000000000000000000000000000),
    .EP1(32'b00000000000000000000000000000010),
    .F(32'b00000000000000000010000000000000),
    .FM1(32'b00000000000000000001111111111110),
    .GSR("DISABLE"),
    .MODE("FIFO8K"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .RESETMODE("ASYNC"))
    fifo_inst_syn_8 (
    .clkr(clk),
    .clkw(clk),
    .csr({2'b11,empty_flag_syn_2}),
    .csw({2'b11,full_flag_syn_2}),
    .dia({open_n153,open_n154,open_n155,di[7],open_n156,open_n157,di[6],open_n158,open_n159}),
    .orea(1'b0),
    .oreb(1'b0),
    .re(re),
    .rprst(rst),
    .rst(rst),
    .we(we),
    .dob({open_n180,open_n181,open_n182,open_n183,open_n184,open_n185,open_n186,do[7:6]}));  // line_shift_fifo.v(41)
  not full_flag_syn_1 (full_flag_syn_2, full_flag);  // line_shift_fifo.v(29)

endmodule 

