vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm

vlog -work xil_defaultlib -64 -incr -sv "+incdir+../../../ipstatic" \
"F:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -64 -93 \
"F:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr "+incdir+../../../ipstatic" \
"../../../../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz_clk_wiz.v" \
"../../../../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz.v" \

vlog -work xil_defaultlib \
"glbl.v"

