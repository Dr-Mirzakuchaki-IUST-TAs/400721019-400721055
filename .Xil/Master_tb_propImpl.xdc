set_property SRC_FILE_INFO {cfile:f:/VIVADO/AD9117_VHDLPROJECT/AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz.xdc rfile:../AD9117_VHDLPROJECT.srcs/sources_1/ip/DCLK_125MHz/DCLK_125MHz.xdc id:1 order:EARLY scoped_inst:uut/your_instance_name/inst} [current_design]
current_instance uut/your_instance_name/inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports DCLK_125MHz_IN]] 0.08
