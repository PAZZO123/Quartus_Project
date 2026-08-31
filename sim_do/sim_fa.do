# Full Adder 32-bit Simulation DO Script
quietly set PROJ "C:/Users/USER/Documents/MIPS_Project"

vlib work
vlog -sv -quiet "$PROJ/full_adder_32bit.sv" "$PROJ/full_adder_32bit_tb.sv"
vsim -t 1ns full_adder_32bit_tb

delete wave *
add wave -divider "=== INPUTS ==="
add wave -color Gold        -radix unsigned  sim:/full_adder_32bit_tb/a
add wave -color Gold        -radix unsigned  sim:/full_adder_32bit_tb/b
add wave -color Cyan        -radix binary    sim:/full_adder_32bit_tb/cin
add wave -divider "=== OUTPUTS ==="
add wave -color SpringGreen -radix unsigned  sim:/full_adder_32bit_tb/sum
add wave -color Orange      -radix binary    sim:/full_adder_32bit_tb/cout

# When $finish triggers a breakpoint, this callback runs our capture sequence
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
