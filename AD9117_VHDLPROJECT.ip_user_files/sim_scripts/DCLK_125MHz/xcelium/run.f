-makelib xcelium_lib/xil_defaultlib -sv \
  "F:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "F:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz_clk_wiz.v" \
  "../../../../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

