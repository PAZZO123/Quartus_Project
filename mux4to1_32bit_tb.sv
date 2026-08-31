// Testbench for 4-to-1 32-bit Multiplexer
`timescale 1ns/1ps

module mux4to1_32bit_tb;
    logic [31:0] d0, d1, d2, d3;
    logic [1:0]  sel;
    logic [31:0] y;

    mux4to1_32bit dut (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3),
        .sel(sel), .y(y)
    );

    task check;
        input [31:0] exp_y;
        input [63:0] t;
        begin
            #10;
            $display("Test %0d: sel=%02b | d0=%0d d1=%0d d2=%0d d3=%0d | y=%0d | %s",
                t, sel, d0, d1, d2, d3, y,
                (y === exp_y) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $display("=== 4-to-1 MUX 32-bit Testbench ===");
        $display("------------------------------------");
        d0 = 32'd10; d1 = 32'd20; d2 = 32'd30; d3 = 32'd40;

        sel = 2'b00; check(32'd10, 1);  // select d0
        sel = 2'b01; check(32'd20, 2);  // select d1
        sel = 2'b10; check(32'd30, 3);  // select d2
        sel = 2'b11; check(32'd40, 4);  // select d3

        d0 = 32'hAAAAAAAA; d1 = 32'hBBBBBBBB;
        d2 = 32'hCCCCCCCC; d3 = 32'hDDDDDDDD;

        sel = 2'b00; check(32'hAAAAAAAA, 5);
        sel = 2'b01; check(32'hBBBBBBBB, 6);
        sel = 2'b10; check(32'hCCCCCCCC, 7);
        sel = 2'b11; check(32'hDDDDDDDD, 8);

        $display("------------------------------------");
        $display("=== Simulation Complete ===");
        $finish;
    end
endmodule
