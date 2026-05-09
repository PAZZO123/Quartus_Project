// Testbench for 32-bit Full Adder
`timescale 1ns/1ps

module full_adder_32bit_tb;
    logic [31:0] a, b;
    logic        cin;
    logic [31:0] sum;
    logic        cout;

    full_adder_32bit dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    task check;
        input [31:0] exp_sum;
        input        exp_cout;
        input [63:0] t;
        begin
            #10;
            $display("Test %0d: a=0x%08X b=0x%08X cin=%0b | sum=0x%08X cout=%0b | %s",
                t, a, b, cin, sum, cout,
                (sum===exp_sum && cout===exp_cout) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=== Full Adder 32-bit Testbench ===");
        $display("------------------------------------");

        // Test 1: 0 + 0 + 0 = 0
        a=0; b=0; cin=0; check(0, 0, 1);

        // Test 2: 1 + 1 + 0 = 2
        a=1; b=1; cin=0; check(2, 0, 2);

        // Test 3: carry in
        a=1; b=1; cin=1; check(3, 0, 3);

        // Test 4: overflow — max + 1
        a=32'hFFFFFFFF; b=1; cin=0; check(0, 1, 4);

        // Test 5: max + max + 1
        a=32'hFFFFFFFF; b=32'hFFFFFFFF; cin=1; check(32'hFFFFFFFF, 1, 5);

        // Test 6: typical add 5 + 10
        a=5; b=10; cin=0; check(15, 0, 6);

        // Test 7: large values
        a=32'h12345678; b=32'h87654321; cin=0; check(32'h99999999, 0, 7);

        // Test 8: carry propagation
        a=32'h7FFFFFFF; b=32'h7FFFFFFF; cin=0; check(32'hFFFFFFFE, 0, 8);

        // Test 9: cout with mid-range values
        a=32'h80000000; b=32'h80000000; cin=0; check(32'h00000000, 1, 9);

        // Test 10: subtract-like (a + ~b + 1 = a - b via 2's complement)
        a=32'd20; b=32'd20; cin=0; check(40, 0, 10);

        $display("------------------------------------");
        $display("=== Simulation Complete ===");
        $finish;
    end
endmodule
