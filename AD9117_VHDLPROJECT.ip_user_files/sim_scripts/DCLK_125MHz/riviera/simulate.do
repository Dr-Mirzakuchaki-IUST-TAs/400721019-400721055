onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+DCLK_125MHz -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.DCLK_125MHz xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {DCLK_125MHz.udo}

run -all

endsim

quit -force
