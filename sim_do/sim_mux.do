# 4-to-1 MUX 32-bit Simulation DO Script
quietly set PROJ "C:/Users/USER/Documents/MIPS_Project"

vlib work
vlog -sv -quiet "$PROJ/mux4to1_32bit.sv" "$PROJ/mux4to1_32bit_tb.sv"
vsim -t 1ns mux4to1_32bit_tb

delete wave *
add wave -divider "=== SELECT ==="
add wave -color Cyan        -radix binary    sim:/mux4to1_32bit_tb/sel
add wave -divider "=== DATA INPUTS ==="
add wave -color Gold        -radix hex       sim:/mux4to1_32bit_tb/d0
add wave -color Gold        -radix hex       sim:/mux4to1_32bit_tb/d1
add wave -color Gold        -radix hex       sim:/mux4to1_32bit_tb/d2
add wave -color Gold        -radix hex       sim:/mux4to1_32bit_tb/d3
add wave -divider "=== OUTPUT ==="
add wave -color SpringGreen -radix hex       sim:/mux4to1_32bit_tb/y

onbreak {
    wave zoom full
    update
    after 2000
    set fh [open "sim_done.txt" w]
    puts $fh "done"
    close $fh
    after 20000
    quit -f
}

run -all
