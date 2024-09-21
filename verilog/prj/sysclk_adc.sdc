create_clock -name clk -period 40 -waveform {0 20} [get_nets { clk }]
create_clock -name System_clk -period 20 -waveform {0 10} [get_ports { System_clk }]
create_generated_clock  -name pclk -source [get_ports {System_clk}] -master_clock System_clk -multiply_by 2 [get_nets {pixel_clk}]
create_generated_clock  -name sclk5 -source [get_ports {System_clk}] -master_clock System_clk -multiply_by 10 [get_nets {pixel_clk_5x}]