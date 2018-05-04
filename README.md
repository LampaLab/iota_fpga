# IOTA hardware accelerator
FPGA based hardware accelerator for IOTA Curl and POW operations

This project created for Innovate FPGA Contest:
[Design video](https://www.youtube.com/watch?v=JJRlwTJHBCg), 
[Design paper](http://www.innovatefpga.com/cgi-bin/innovate/teams.pl?Id=EM080)

Proof-of-Concept created for DE10-nano board, which based on Cyclone V 5CSEBA6U23I7 FPGA device

PoC parameters:
- Hardware resources: 11% of 5CSEBA6U23I7 FPGA 
- Operation frequency: 100 MHz
- Hashrate: 1 204 819 hash/sec 
- POW acceleration: x90 - x500 (software POW: 10-50 min, hardware accelerated POW: 2-20 sec)

We plan add simultaneous calculation of multiple hashes and increase hashrate up to 10 Mhash/sec for DE10-nano
