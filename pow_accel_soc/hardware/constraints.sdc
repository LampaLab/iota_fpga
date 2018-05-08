create_clock -period "50.0 MHz" [get_ports FPGA_CLK1_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK2_50]
create_clock -period "50.0 MHz" [get_ports FPGA_CLK3_50]

create_clock -period 200MHz [get_pins -compatibility_mode u0|hps_0|fpga_interfaces|clocks_resets|h2f_user0_clk]

derive_pll_clocks

derive_clock_uncertainty
