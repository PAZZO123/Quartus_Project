// MIPS ALU Control Unit in SystemVerilog
// Based on Fig. B.5.16 from Patterson & Hennessy Appendix B
// Inputs:
//   ALUOp[1:0] - from main control unit
//   funct[5:0] - function field from R-type instruction
// Output:
//   ALUcontrol[2:0] - operation for the ALU

module alu_control (
    input  logic [1:0] ALUOp,
    input  logic [5:0] funct,
    output logic [2:0] ALUcontrol
);

    always_comb begin
        case (ALUOp)
            2'b00: ALUcontrol = 3'b010; // LW/SW: ADD
            2'b01: ALUcontrol = 3'b110; // BEQ: SUB
            2'b10: begin                // R-type: use funct field
                case (funct)
                    6'b100000: ALUcontrol = 3'b010; // ADD
                    6'b100010: ALUcontrol = 3'b110; // SUB
                    6'b100100: ALUcontrol = 3'b000; // AND
                    6'b100101: ALUcontrol = 3'b001; // OR
                    6'b101010: ALUcontrol = 3'b111; // SLT
                    default:   ALUcontrol = 3'bxxx;
                endcase
            end
            default: ALUcontrol = 3'bxxx;
        endcase
    end

endmodule
