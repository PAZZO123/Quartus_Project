// 32-bit Full Adder using SystemVerilog
module full_adder_32bit (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout
);

    assign {cout, sum} = a + b + cin;

endmodule

// Testbench for 32-bit Full Adder
module full_adder_32bit_tb;
    logic [31:0] a, b, sum;
    logic cin, cout;

    // Instantiate the DUT
    full_adder_32bit uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $display("=== 32-bit Full Adder Testbench ===");
        $display("Time\t\ta\t\tb\t\tcin\tsum\t\tcout");

        // Test 1: 0 + 0 + 0 = 0
        a = 32'd0; b = 32'd0; cin = 0;
        #10;
        $display("%0t\t%0d\t\t%0d\t\t%0d\t%0d\t\t%0d", $time, a, b, cin, sum, cout);

        // Test 2: Simple addition
        a = 32'd5; b = 32'd3; cin = 0;
        #10;
        $display("%0t\t%0d\t\t%0d\t\t%0d\t%0d\t\t%0d", $time, a, b, cin, sum, cout);

        // Test 3: Addition with carry-in
        a = 32'd10; b = 32'd7; cin = 1;
        #10;
        $display("%0t\t%0d\t\t%0d\t\t%0d\t%0d\t\t%0d", $time, a, b, cin, sum, cout);

        // Test 4: Max value test (overflow)
        a = 32'hFFFFFFFF; b = 32'd1; cin = 0;
        #10;
        $display("%0t\t%h\t%0d\t\t%0d\t%0d\t\t%0d", $time, a, b, cin, sum, cout);

        // Test 5: Large values
        a = 32'h7FFFFFFF; b = 32'h7FFFFFFF; cin = 0;
        #10;
        $display("%0t\t%h\t%h\t%0d\t%h\t%0d", $time, a, b, cin, sum, cout);

        // Test 6: Carry propagation
        a = 32'hAAAAAAAA; b = 32'h55555555; cin = 1;
        #10;
        $display("%0t\t%h\t%h\t%0d\t%h\t%0d", $time, a, b, cin, sum, cout);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
