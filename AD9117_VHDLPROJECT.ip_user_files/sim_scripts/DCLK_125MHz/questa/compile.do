vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm

vlog -work xil_defaultlib -64 -sv "+incdir+../../../ipstatic" \
"F:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"F:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../ipstatic" \
"../../../../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz_clk_wiz.v" \
"../../../../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz.v" \

vlog -work xil_defaultlib \
"glbl.v"

