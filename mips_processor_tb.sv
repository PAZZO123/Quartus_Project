// Testbench for Single-Cycle MIPS Processor
// Tests: ADD, SUB, AND, OR, SLT, LW, SW, BEQ
// Register initialisation: $t0=0, $t1=5, $t3=10, $t4=4
`timescale 1ns/1ps

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

    // 10ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Pre-load key registers before simulation starts
    initial begin
        force dut.rf.rf[8]  = 32'h00000000;   // $t0 = 0
        force dut.rf.rf[9]  = 32'h00000005;   // $t1 = 5
        force dut.rf.rf[10] = 32'h00000000;   // $t2 = 0
        force dut.rf.rf[11] = 32'h0000000A;   // $t3 = 10
        force dut.rf.rf[12] = 32'h00000004;   // $t4 = 4
        #1;
        release dut.rf.rf[8];
        release dut.rf.rf[9];
        release dut.rf.rf[10];
        release dut.rf.rf[11];
        release dut.rf.rf[12];
    end

    // Monitor signals
    initial begin
        $display("=== MIPS Single-Cycle Processor Testbench ===");
        $display("  Time  |    PC    | Instruction |   ALUout   | WriteData");
        $display("--------+----------+-------------+------------+----------");

        reset = 1;
        @(posedge clk); @(posedge clk);
        reset = 0;

        // Run 10 cycles (covers all imem instructions)
        repeat(10) begin
            @(posedge clk);
            #1;
            $display(" %5t  | %08h | %08h    | %08h   | %08h",
                     $time, pc, instr, aluout, writedata);
        end

        $display("--------+----------+-------------+------------+----------");
        $display("=== Simulation Complete: %0t ns ===", $time);
        $finish;
    end

    // Timeout guard
    initial begin
        #500; $display("TIMEOUT"); $finish;
    end

endmodule
