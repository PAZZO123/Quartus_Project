# ALU 32-bit Simulation DO Script
quietly set PROJ "C:/Users/USER/Documents/MIPS_Project"

vlib work
vlog -sv -quiet "$PROJ/alu_32bit.sv" "$PROJ/alu_control.sv" "$PROJ/alu_32bit_tb.sv"
vsim -t 1ns alu_32bit_tb

delete wave *
add wave -divider "=== INPUTS ==="
add wave -color Gold        -radix hex       sim:/alu_32bit_tb/a
add wave -color Gold        -radix hex       sim:/alu_32bit_tb/b
add wave -color Cyan        -radix binary    sim:/alu_32bit_tb/ALUcontrol
add wave -divider "=== OUTPUTS ==="
add wave -color SpringGreen -radix hex       sim:/alu_32bit_tb/result
add wave -color Orange      -radix binary    sim:/alu_32bit_tb/zero

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
