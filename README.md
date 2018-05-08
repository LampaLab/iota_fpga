# IOTA hardware accelerator
FPGA based hardware accelerator for IOTA Curl and POW operations written in Verilog/System Verilog

This project created for Innovate FPGA Contest:
[Design video](https://www.youtube.com/watch?v=JJRlwTJHBCg), 
[Design paper](http://www.innovatefpga.com/cgi-bin/innovate/teams.pl?Id=EM080)

Performance & Resources:
- Parameterized design (the number of POW comput. units can be set using parameter CALC_UNIT_NUMBER)
- Hardware resources: 1 125 ALMs, 2 177 flip-flops per POW comput. unit
- Hashrate: 1 204 819 hash/sec per POW comput. unit at 100 MHz
- Fmax: 120-150 MHz for Cyclone V depending on number of POW comput. units

Proof-of-Concept launched on DE10-nano board (Cyclone V 5CSEBA6U23I7 FPGA device) 

PoC parameters:
- 11 POW comput. units
- Operation frequency: 100 MHz 
- Hashrate: 13 253 012 hash/sec
- Resources: 12 377 ALMs, 23 945 flip-flops (30% of 5CSEBA6U23I7 FPGA)
- POW acceleration: x1000 (for MWM=15 software POW on DE10-nano: 10-50 min, hardware accel. POW: 0.2-4 sec, 0.6 sec in average)

For DE10-nano it is possible to increase the number of POW comput. units up to 20 and obtain 25 Mhash/sec on 100 MHz, but we do not have enough RAM to synthesize such large system.

[Download](https://github.com/LampaLab/iota_fpga/releases/tag/v0.1) Linux sd-card image for IOTA hardware acceleration on DE10-nano board with [latest](https://github.com/LampaLab/iota_fpga/releases/tag/v0.2) rbf file
