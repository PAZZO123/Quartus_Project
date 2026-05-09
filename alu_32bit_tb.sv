// Testbench for 32-bit ALU
// Tests all 6 operations: AND, OR, ADD, SUB, SLT, pass-through

`timescale 1ns/1ps

module alu_32bit_tb;

    // DUT ports
    logic [31:0] a, b;
    logic [2:0]  ALUcontrol;
    logic [31:0] result;
    logic        zero;

    // Instantiate DUT
    alu_32bit dut (
        .a(a), .b(b), .ALUcontrol(ALUcontrol),
        .result(result), .zero(zero)
    );

    // Display helper task
    task check;
        input [31:0] expected_result;
        input        expected_zero;
        input [63:0] test_num;
        begin
            #10;
            $display("Test %0d: a=%0d b=%0d ctrl=%03b | result=%0d zero=%0b | %s",
                test_num, $signed(a), $signed(b), ALUcontrol,
                $signed(result), zero,
                (result===expected_result && zero===expected_zero) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=== ALU 32-bit Testbench ===");
        $display("ctrl=000:AND  001:OR  010:ADD  110:SUB  111:SLT");
        $display("----------------------------------------");

        // Test 1: AND
        a=32'hFF00FF00; b=32'h0F0F0F0F; ALUcontrol=3'b000;
        check(32'h0F000F00, 0, 1);

        // Test 2: OR
        a=32'hFF00FF00; b=32'h0F0F0F0F; ALUcontrol=3'b001;
        check(32'hFF0FFF0F, 0, 2);

        // Test 3: ADD — 5 + 3 = 8
        a=32'd5; b=32'd3; ALUcontrol=3'b010;
        check(32'd8, 0, 3);

        // Test 4: ADD — produces zero result
        a=32'd0; b=32'd0; ALUcontrol=3'b010;
        check(32'd0, 1, 4);

        // Test 5: SUB — 10 - 4 = 6
        a=32'd10; b=32'd4; ALUcontrol=3'b110;
        check(32'd6, 0, 5);

        // Test 6: SUB — result is zero (a == b)
        a=32'd7; b=32'd7; ALUcontrol=3'b110;
        check(32'd0, 1, 6);

        // Test 7: SUB — negative result (2 - 5 = -3)
        a=32'd2; b=32'd5; ALUcontrol=3'b110;
        check(32'hFFFFFFFD, 0, 7);

        // Test 8: SLT — 3 < 5 → result = 1
        a=32'd3; b=32'd5; ALUcontrol=3'b111;
        check(32'd1, 0, 8);

        // Test 9: SLT — 5 < 3 → result = 0
        a=32'd5; b=32'd3; ALUcontrol=3'b111;
        check(32'd0, 1, 9);

        // Test 10: SLT — negative < positive → result = 1
        a=-32'd1; b=32'd0; ALUcontrol=3'b111;
        check(32'd1, 0, 10);

        $display("----------------------------------------");
        $display("=== Simulation Complete ===");
        $finish;
    end

endmodule
