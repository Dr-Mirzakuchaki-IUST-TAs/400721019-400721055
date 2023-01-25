onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib DCLK_125MHz_opt

do {wave.do}

view wave
view structure
view signals

do {DCLK_125MHz.udo}

run -all

quit -force
