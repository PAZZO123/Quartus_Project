// 4-to-1 Multiplexer with 32-bit inputs (SystemVerilog)
// Based on Fig. B.4.2 from Patterson & Hennessy Appendix B
module mux4to1_32bit (
    input  logic [31:0] d0, d1, d2, d3,
    input  logic [1:0]  sel,
    output logic [31:0] y
);

    always_comb begin
        case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d3;
            default: y = 32'bx;
        endcase
    end

endmodule

// Testbench for 4-to-1 32-bit MUX
module mux4to1_32bit_tb;
    logic [31:0] d0, d1, d2, d3;
    logic [1:0]  sel;
    logic [31:0] y;

    // Instantiate the DUT
    mux4to1_32bit uut (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3),
        .sel(sel),
        .y(y)
    );

    initial begin
        $display("=== 4-to-1 MUX 32-bit Testbench ===");
        $display("sel\td0\t\td1\t\td2\t\td3\t\ty (output)");

        d0 = 32'hAAAAAAAA;
        d1 = 32'hBBBBBBBB;
        d2 = 32'hCCCCCCCC;
        d3 = 32'hDDDDDDDD;

        // Select input 0
        sel = 2'b00; #10;
        $display("%b\t%h\t%h\t%h\t%h\t%h", sel, d0, d1, d2, d3, y);

        // Select input 1
        sel = 2'b01; #10;
        $display("%b\t%h\t%h\t%h\t%h\t%h", sel, d0, d1, d2, d3, y);

        // Select input 2
        sel = 2'b10; #10;
        $display("%b\t%h\t%h\t%h\t%h\t%h", sel, d0, d1, d2, d3, y);

        // Select input 3
        sel = 2'b11; #10;
        $display("%b\t%h\t%h\t%h\t%h\t%h", sel, d0, d1, d2, d3, y);

        // Test with different values
        d0 = 32'd100; d1 = 32'd200; d2 = 32'd300; d3 = 32'd400;

        sel = 2'b00; #10;
        $display("%b\t%0d\t\t%0d\t\t%0d\t\t%0d\t\t%0d", sel, d0, d1, d2, d3, y);

        sel = 2'b01; #10;
        $display("%b\t%0d\t\t%0d\t\t%0d\t\t%0d\t\t%0d", sel, d0, d1, d2, d3, y);

        sel = 2'b10; #10;
        $display("%b\t%0d\t\t%0d\t\t%0d\t\t%0d\t\t%0d", sel, d0, d1, d2, d3, y);

        sel = 2'b11; #10;
        $display("%b\t%0d\t\t%0d\t\t%0d\t\t%0d\t\t%0d", sel, d0, d1, d2, d3, y);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
