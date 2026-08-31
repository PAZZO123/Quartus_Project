# ============================================================
# Single-Cycle MIPS Processor — ModelSim Simulation Script
# Shows registers as plain decimal numbers so every
# arithmetic result (addi, add, sub, andi, lw, sw, beq)
# is immediately readable in the wave window.
# ============================================================
quietly set PROJ "C:/Users/USER/Documents/MIPS_Project"

vlib work
vlog -sv -quiet \
    "$PROJ/alu_32bit.sv" \
    "$PROJ/alu_control.sv" \
    "$PROJ/mips_processor.sv" \
    "$PROJ/mips_processor_tb.sv"

vsim -t 1ns mips_processor_tb

delete wave *

# ---- Clock & Reset ----------------------------------------
add wave -divider "=== CLOCK & RESET ==="
add wave -color White       -radix binary    sim:/mips_processor_tb/clk
add wave -color Red         -radix binary    sim:/mips_processor_tb/reset

# ---- Program Counter --------------------------------------
add wave -divider "=== PROGRAM COUNTER ==="
add wave -color Cyan        -radix hex       sim:/mips_processor_tb/pc

# ---- Current Instruction ----------------------------------
add wave -divider "=== INSTRUCTION ==="
add wave -color Yellow      -radix hex       sim:/mips_processor_tb/instr

# ---- Control Signals --------------------------------------
add wave -divider "=== CONTROL SIGNALS ==="
add wave -color Orange      -radix binary    sim:/mips_processor_tb/dut/regwrite
add wave -color Orange      -radix binary    sim:/mips_processor_tb/dut/memwrite
add wave -color Orange      -radix binary    sim:/mips_processor_tb/dut/memtoreg
add wave -color Orange      -radix binary    sim:/mips_processor_tb/dut/branch
add wave -color Orange      -radix binary    sim:/mips_processor_tb/dut/alusrc
add wave -color Orange      -radix binary    sim:/mips_processor_tb/dut/regdst
add wave -color Magenta     -radix binary    sim:/mips_processor_tb/dut/pcsrc
add wave -color Magenta     -radix binary    sim:/mips_processor_tb/dut/zero
add wave -color Magenta     -radix binary    sim:/mips_processor_tb/dut/alucontrol

# ---- ALU / Memory Datapath --------------------------------
add wave -divider "=== DATAPATH (hex) ==="
add wave -color SpringGreen -radix hex       sim:/mips_processor_tb/aluout
add wave -color SpringGreen -radix hex       sim:/mips_processor_tb/writedata
add wave -color SpringGreen -radix hex       sim:/mips_processor_tb/readdata

# ---- Register File (decimal — see the actual numbers!) ----
# Expected sequence:
#   $t0  rf[8]  : 0 → 5  (addi $t0,$zero,5)
#   $t1  rf[9]  : 0 → 10 (addi $t1,$zero,10)
#   $t2  rf[10] : 0 → 15 (add  $t2 = 5+10)
#   $t3  rf[11] : 0 → 5  (sub  $t3 = 10-5)
#   $t4  rf[12] : 0 → 1  (andi $t4 = 5&3)
#   $s0  rf[16] : 0 → 15 (lw   $s0 = Mem[0])
add wave -divider "=== REGISTER FILE (decimal) ==="
add wave -color Gold        -radix unsigned  {sim:/mips_processor_tb/dut/rf/rf[8]}
add wave -color Gold        -radix unsigned  {sim:/mips_processor_tb/dut/rf/rf[9]}
add wave -color Gold        -radix unsigned  {sim:/mips_processor_tb/dut/rf/rf[10]}
add wave -color Gold        -radix unsigned  {sim:/mips_processor_tb/dut/rf/rf[11]}
add wave -color Gold        -radix unsigned  {sim:/mips_processor_tb/dut/rf/rf[12]}
add wave -color Gold        -radix unsigned  {sim:/mips_processor_tb/dut/rf/rf[16]}

# ---- On $finish: zoom, snapshot, quit ---------------------
onbreak {
    # Zoom to show the full 320 ns run.
    # The 22 NOP cycles after the 8-instruction program make each
    # register's final value persist on a ~200 ns wide bar so
    # ModelSim renders the decimal number (5 / 10 / 15 / 1) on the bar.
    wave zoom range 0 330
    # Place cursor at 136 ns (end of BEQ, all registers settled)
    # so the Msgs column shows final values: 5, 10, 15, 5, 1, 15
    wave cursor set 136
    update
    after 3000
    set fh [open "sim_done.txt" w]
    puts $fh "done"
    close $fh
    after 20000
    quit -f
}

run -all
