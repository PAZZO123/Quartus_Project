// Single-Cycle MIPS Processor in SystemVerilog
// Implements: R-type, LW, SW, BEQ, J instructions

// ============================================================
// Sub-module: 2-to-1 MUX (32-bit)
// ============================================================
module mux2to1_32bit (
    input  logic [31:0] d0, d1,
    input  logic        sel,
    output logic [31:0] y
);
    assign y = sel ? d1 : d0;
endmodule

// ============================================================
// Sub-module: Register File (32 x 32-bit)
// ============================================================
module regfile (
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  ra1, ra2, wa3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);
    logic [31:0] rf [31:0];

    // Write on rising edge
    always_ff @(posedge clk) begin
        if (we3)
            rf[wa3] <= wd3;
    end

    // Asynchronous reads; register 0 hardwired to 0
    assign rd1 = (ra1 != 5'b0) ? rf[ra1] : 32'b0;
    assign rd2 = (ra2 != 5'b0) ? rf[ra2] : 32'b0;
endmodule

// ============================================================
// Sub-module: Sign Extender (16-bit -> 32-bit)
// ============================================================
module sign_extend (
    input  logic [15:0] a,
    output logic [31:0] y
);
    assign y = {{16{a[15]}}, a};
endmodule

// ============================================================
// Sub-module: Instruction Memory (ROM)
// ============================================================
module imem (
    input  logic [5:0]  a,
    output logic [31:0] rd
);
    logic [31:0] ROM [63:0];

    initial begin
        // Sample MIPS program:
        // add  $t2, $t0, $t1    # R[10] = R[8] + R[9]
        // sub  $t5, $t3, $t4    # R[13] = R[11] - R[12]
        // and  $s0, $t0, $t1    # R[16] = R[8] & R[9]
        // or   $s1, $t0, $t1    # R[17] = R[8] | R[9]
        // slt  $s2, $t3, $t4    # R[18] = (R[11] < R[12]) ? 1 : 0
        // lw   $s3, 4($t0)      # R[19] = Mem[R[8]+4]
        // sw   $s0, 0($t0)      # Mem[R[8]+0] = R[16]
        // beq  $t0, $t0, +2     # branch if equal (should branch)
        // add  $zero,$zero,$zero # NOP (skipped if branch taken)
        ROM[0]  = 32'b000000_01000_01001_01010_00000_100000; // add  $t2,$t0,$t1
        ROM[1]  = 32'b000000_01011_01100_01101_00000_100010; // sub  $t5,$t3,$t4
        ROM[2]  = 32'b000000_01000_01001_10000_00000_100100; // and  $s0,$t0,$t1
        ROM[3]  = 32'b000000_01000_01001_10001_00000_100101; // or   $s1,$t0,$t1
        ROM[4]  = 32'b000000_01011_01100_10010_00000_101010; // slt  $s2,$t3,$t4
        ROM[5]  = 32'b100011_01000_10011_0000000000000100;   // lw   $s3,4($t0)
        ROM[6]  = 32'b101011_01000_10000_0000000000000000;   // sw   $s0,0($t0)
        ROM[7]  = 32'b000100_01000_01000_0000000000000010;   // beq  $t0,$t0,+2
        ROM[8]  = 32'b000000_00000_00000_00000_00000_100000; // NOP
        ROM[9]  = 32'b000000_00000_00000_00000_00000_100000; // NOP
        // Fill rest with NOPs
        for (int i = 10; i < 64; i++)
            ROM[i] = 32'b000000_00000_00000_00000_00000_100000;
    end

    assign rd = ROM[a];
endmodule

// ============================================================
// Sub-module: Data Memory (RAM)
// ============================================================
module dmem (
    input  logic        clk, we,
    input  logic [31:0] a, wd,
    output logic [31:0] rd
);
    logic [31:0] RAM [63:0];

    initial begin
        // Initialize some memory values for testing
        RAM[0] = 32'd10;
        RAM[1] = 32'd20;
        RAM[2] = 32'd30;
        RAM[3] = 32'd40;
        for (int i = 4; i < 64; i++)
            RAM[i] = 32'd0;
    end

    assign rd = RAM[a[31:2]]; // word-addressed

    always_ff @(posedge clk) begin
        if (we)
            RAM[a[31:2]] <= wd;
    end
endmodule

// ============================================================
// Sub-module: Main Control Unit
// ============================================================
module maindec (
    input  logic [5:0] op,
    output logic       memtoreg, memwrite,
    output logic       branch, alusrc,
    output logic       regdst, regwrite,
    output logic       jump,
    output logic [1:0] aluop
);
    logic [8:0] controls;
    assign {regwrite, regdst, alusrc, branch, memwrite,
            memtoreg, jump, aluop} = controls;

    always_comb begin
        case (op)
            6'b000000: controls = 9'b110000010; // R-type
            6'b100011: controls = 9'b101001000; // LW
            6'b101011: controls = 9'b001010000; // SW
            6'b000100: controls = 9'b000100001; // BEQ
            6'b001000: controls = 9'b101000000; // ADDI
            6'b000010: controls = 9'b000000100; // J
            default:   controls = 9'bxxxxxxxxx;
        endcase
    end
endmodule

// ============================================================
// Top-level: Single-Cycle MIPS Processor
// ============================================================
module mips_processor (
    input  logic        clk, reset,
    output logic [31:0] pc,
    output logic [31:0] instr,
    output logic [31:0] aluout,
    output logic [31:0] writedata,
    output logic [31:0] readdata
);

    // Internal signals
    logic        memtoreg, memwrite, branch, alusrc;
    logic        regdst, regwrite, jump, pcsrc, zero;
    logic [1:0]  aluop;
    logic [2:0]  alucontrol;
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
    logic [31:0] signimm, signimmsh;
    logic [31:0] srca, srcb;
    logic [31:0] result;
    logic [4:0]  writereg;

    // PC register
    always_ff @(posedge clk, posedge reset) begin
        if (reset) pc <= 32'b0;
        else       pc <= pcnext;
    end

    // Instruction memory
    imem imem_inst (.a(pc[7:2]), .rd(instr));

    // PC + 4
    assign pcplus4 = pc + 32'd4;

    // Main decoder
    maindec md (
        .op(instr[31:26]),
        .memtoreg(memtoreg), .memwrite(memwrite),
        .branch(branch), .alusrc(alusrc),
        .regdst(regdst), .regwrite(regwrite),
        .jump(jump), .aluop(aluop)
    );

    // ALU control
    alu_control ac (
        .ALUOp(aluop),
        .funct(instr[5:0]),
        .ALUcontrol(alucontrol)
    );

    // Register file
    regfile rf (
        .clk(clk), .we3(regwrite),
        .ra1(instr[25:21]), .ra2(instr[20:16]),
        .wa3(writereg), .wd3(result),
        .rd1(srca), .rd2(writedata)
    );

    // Write register mux (R-type uses rd field, I-type uses rt field)
    assign writereg = regdst ? instr[15:11] : instr[20:16];

    // Sign extend
    sign_extend se (.a(instr[15:0]), .y(signimm));

    // Shift left 2 for branch target
    assign signimmsh = {signimm[29:0], 2'b00};

    // ALU source mux
    mux2to1_32bit srcbmux (
        .d0(writedata),
        .d1(signimm),
        .sel(alusrc),
        .y(srcb)
    );

    // ALU
    alu_32bit alu_inst (
        .a(srca), .b(srcb),
        .ALUcontrol(alucontrol),
        .result(aluout), .zero(zero)
    );

    // Data memory
    dmem dmem_inst (
        .clk(clk), .we(memwrite),
        .a(aluout), .wd(writedata),
        .rd(readdata)
    );

    // Result mux (from memory or ALU)
    mux2to1_32bit resmux (
        .d0(aluout),
        .d1(readdata),
        .sel(memtoreg),
        .y(result)
    );

    // Branch/Jump target logic
    assign pcsrc   = branch & zero;
    assign pcbranch = pcplus4 + signimmsh;
    mux2to1_32bit pcbrmux (
        .d0(pcplus4),
        .d1(pcbranch),
        .sel(pcsrc),
        .y(pcnextbr)
    );
    mux2to1_32bit pcjmux (
        .d0(pcnextbr),
        .d1({pcplus4[31:28], instr[25:0], 2'b00}),
        .sel(jump),
        .y(pcnext)
    );

endmodule

// ============================================================
// Testbench for Single-Cycle MIPS Processor
// ============================================================
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

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $display("=== Single-Cycle MIPS Processor Testbench ===");
        $display("Time\tPC\t\tInstruction\tALUout\t\tWriteData");

        reset = 1; #10;
        reset = 0;

        // Run for 20 clock cycles
        repeat (20) begin
            @(posedge clk);
            #1; // small delay to let outputs settle
            $display("%0t\t%h\t%h\t%h\t%h",
                     $time, pc, instr, aluout, writedata);
        end

        $display("=== Simulation Complete ===");
        $finish;
    end

endmodule
