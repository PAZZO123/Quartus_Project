// 32-bit MIPS ALU in SystemVerilog
// Based on Fig. B.4.3 and Fig. B.5.15 from Patterson & Hennessy Appendix B
// ALU Operations:
//   000 = AND
//   001 = OR
//   010 = ADD
//   110 = SUB (a - b)
//   111 = SLT (set less than)
//   011 = NOR (not or)

module alu_32bit (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [2:0]  ALUcontrol,
    output logic [31:0] result,
    output logic        zero
);

    logic [31:0] b_mux;
    logic [31:0] sum;
    logic        overflow;

    // For subtraction, invert b and add 1 (2's complement)
    assign b_mux = ALUcontrol[2] ? (~b) : b;
    assign {overflow, sum} = a + b_mux + ALUcontrol[2];

    always_comb begin
        case (ALUcontrol)
            3'b000: result = a & b;          // AND
            3'b001: result = a | b;          // OR
            3'b010: result = sum;            // ADD
            3'b011: result = ~(a | b);       // NOR
            3'b110: result = sum;            // SUB
            3'b111: result = {31'b0, sum[31]}; // SLT (set on less than)
            default: result = 32'bx;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule

// Testbench for 32-bit MIPS ALU
module alu_32bit_tb;
    logic [31:0] a, b, result;
    logic [2:0]  ALUcontrol;
    logic        zero;

    // Instantiate the DUT
    alu_32bit uut (
        .a(a),
        .b(b),
        .ALUcontrol(ALUcontrol),
        .result(result),
        .zero(zero)
    );

    task run_test;
        input [31:0] in_a, in_b;
        input [2:0]  ctrl;
        input [63:0] op_name; // simplified
        begin
            a = in_a; b = in_b; ALUcontrol = ctrl;
            #10;
            $display("ALUctrl=%b  a=%0d  b=%0d  result=%0d  zero=%b",
                     ALUcontrol, a, b, result, zero);
        end
    endtask

    initial begin
        $display("=== 32-bit MIPS ALU Testbench ===");
        $display("ALUctrl  a         b         result    zero");

        // AND tests
        $display("--- AND Operation (000) ---");
        a = 32'hFFFFFFFF; b = 32'hAAAAAAAA; ALUcontrol = 3'b000; #10;
        $display("AND: %h & %h = %h, zero=%b", a, b, result, zero);

        a = 32'h0F0F0F0F; b = 32'hF0F0F0F0; ALUcontrol = 3'b000; #10;
        $display("AND: %h & %h = %h, zero=%b", a, b, result, zero);

        // OR tests
        $display("--- OR Operation (001) ---");
        a = 32'hAAAAAAAA; b = 32'h55555555; ALUcontrol = 3'b001; #10;
        $display("OR:  %h | %h = %h, zero=%b", a, b, result, zero);

        // ADD tests
        $display("--- ADD Operation (010) ---");
        a = 32'd10; b = 32'd20; ALUcontrol = 3'b010; #10;
        $display("ADD: %0d + %0d = %0d, zero=%b", a, b, result, zero);

        a = 32'd0; b = 32'd0; ALUcontrol = 3'b010; #10;
        $display("ADD: %0d + %0d = %0d, zero=%b", a, b, result, zero);

        // SUB tests
        $display("--- SUB Operation (110) ---");
        a = 32'd20; b = 32'd5; ALUcontrol = 3'b110; #10;
        $display("SUB: %0d - %0d = %0d, zero=%b", a, b, result, zero);

        a = 32'd10; b = 32'd10; ALUcontrol = 3'b110; #10;
        $display("SUB: %0d - %0d = %0d, zero=%b (zero flag test)", a, b, result, zero);

        // SLT tests
        $display("--- SLT Operation (111) ---");
        a = 32'd5; b = 32'd10; ALUcontrol = 3'b111; #10;
        $display("SLT: %0d < %0d = %0d (expected 1)", a, b, result);

        a = 32'd15; b = 32'd10; ALUcontrol = 3'b111; #10;
        $display("SLT: %0d < %0d = %0d (expected 0)", a, b, result);

        // NOR tests
        $display("--- NOR Operation (011) ---");
        a = 32'h00000000; b = 32'h00000000; ALUcontrol = 3'b011; #10;
        $display("NOR: ~(%h | %h) = %h, zero=%b", a, b, result, zero);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
