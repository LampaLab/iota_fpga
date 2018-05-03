create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

create_clock -period 200MHz  [get_ports clock_bridge_0_out_clk_clk]

derive_pll_clocks

derive_clock_uncertainty
