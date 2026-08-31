`timescale 1ns/1ps
// =============================================================
// Testbench: Single-Cycle MIPS Processor
// Program executed (see imem ROM):
//   Cycle 1 : addi $t0,$zero,5      R[8]  = 5
//   Cycle 2 : addi $t1,$zero,10     R[9]  = 10
//   Cycle 3 : add  $t2,$t0,$t1      R[10] = 5+10 = 15
//   Cycle 4 : sub  $t3,$t1,$t0      R[11] = 10-5 = 5
//   Cycle 5 : andi $t4,$t0,3        R[12] = 5&3  = 1
//   Cycle 6 : sw   $t2,0($zero)     Mem[0]= 15
//   Cycle 7 : lw   $s0,0($zero)     R[16] = 15
//   Cycle 8 : beq  $t0,$t0,+1       branch taken -> PC+12
//   Cycles 9-30: NOP (hold final values visible on wave bars)
// =============================================================
module mips_processor_tb;

    logic        clk, reset;
    logic [31:0] pc, instr, aluout, writedata, readdata;

    // Instantiate DUT
    mips_processor dut (
        .clk(clk), .reset(reset),
        .pc(pc), .instr(instr),
        .aluout(aluout), .writedata(writedata),
        .readdata(readdata)
    );

    // 10 ns clock (50 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus + console log
    initial begin
        $display("=== Single-Cycle MIPS Processor Testbench ===");
        $display("Cycle |    PC    | Instruction |  ALUout  | WriteData| ReadData | $t0| $t1| $t2| $t3| $t4|$s0");
        $display("------+----------+-------------+----------+----------+----------+----+----+----+----+----+---");

        reset = 1;
        @(posedge clk);
        @(posedge clk);
        reset = 0;

        // Run 30 cycles: 8 active instructions + 22 NOP hold cycles
        // The extra cycles make each final register value visible as a
        // wide bar with the decimal number printed on it in ModelSim.
        repeat (30) begin
            @(posedge clk);
            #1;
            $display("  %3d | %08h | %08h  | %08h | %08h | %08h | %2d | %2d | %2d | %2d | %2d | %2d",
                     ($time / 10) - 1,
                     pc, instr, aluout, writedata, readdata,
                     dut.rf.rf[8],  dut.rf.rf[9],  dut.rf.rf[10],
                     dut.rf.rf[11], dut.rf.rf[12], dut.rf.rf[16]);
        end

        $display("------+----------+-------------+----------+----------+----------+----+----+----+----+----+---");
        $display("Expected: $t0=5  $t1=10  $t2=15  $t3=5  $t4=1  $s0=15");
        $display("=== Simulation Complete at %0t ns ===", $time);
        $finish;
    end

    // Safety timeout
    initial begin
        #1500;
        $display("TIMEOUT — simulation did not finish normally");
        $finish;
    end

endmodule
