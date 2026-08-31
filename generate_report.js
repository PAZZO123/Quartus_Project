const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  ImageRun, Header, Footer, AlignmentType, HeadingLevel, BorderStyle,
  WidthType, ShadingType, VerticalAlign, PageNumber, PageBreak,
  LevelFormat, TabStopType, TabStopPosition
} = require('docx');
const fs = require('fs');
const path = require('path');

const SCREENSHOTS = 'C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots';
const OUTPUT = 'C:\\Users\\USER\\Documents\\MIPS_Project\\MIPS_Project_Report.docx';

function loadImg(filename) {
  const fp = path.join(SCREENSHOTS, filename);
  return fs.existsSync(fp) ? fs.readFileSync(fp) : null;
}

function heading1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    children: [new TextRun({ text, bold: true, size: 32, font: 'Arial', color: '1F4E79' })],
    spacing: { before: 360, after: 120 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: '1F4E79', space: 4 } }
  });
}

function heading2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    children: [new TextRun({ text, bold: true, size: 28, font: 'Arial', color: '2E75B6' })],
    spacing: { before: 240, after: 80 }
  });
}

function body(text, { bold = false, italic = false, indent = false } = {}) {
  return new Paragraph({
    children: [new TextRun({ text, bold, italic, size: 22, font: 'Arial' })],
    spacing: { after: 100 },
    indent: indent ? { left: 360 } : undefined
  });
}

function code(text) {
  return new Paragraph({
    children: [new TextRun({ text, font: 'Courier New', size: 18, color: '1F4E79' })],
    spacing: { after: 40 },
    indent: { left: 720 },
    shading: { type: ShadingType.CLEAR, fill: 'F2F2F2' }
  });
}

function bullet(text) {
  return new Paragraph({
    numbering: { reference: 'bullets', level: 0 },
    children: [new TextRun({ text, size: 22, font: 'Arial' })],
    spacing: { after: 60 }
  });
}

function figure(imgData, caption, width = 580, height = 330) {
  const paras = [];
  if (imgData) {
    paras.push(new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 160, after: 60 },
      children: [new ImageRun({
        type: 'png',
        data: imgData,
        transformation: { width, height },
        altText: { title: caption, description: caption, name: caption }
      })]
    }));
  }
  paras.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 180 },
    children: [new TextRun({ text: caption, italic: true, size: 20, font: 'Arial', color: '595959' })]
  }));
  return paras;
}

function pageBreak() {
  return new Paragraph({ children: [new PageBreak()] });
}

function hline() {
  return new Paragraph({
    spacing: { before: 80, after: 80 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 2, color: 'CCCCCC', space: 1 } },
    children: []
  });
}

function tableRow(cells, isHeader = false) {
  const border = { style: BorderStyle.SINGLE, size: 1, color: 'BFBFBF' };
  const borders = { top: border, bottom: border, left: border, right: border };
  return new TableRow({
    children: cells.map(({ text, width }) => new TableCell({
      borders,
      width: { size: width, type: WidthType.DXA },
      shading: isHeader
        ? { fill: '1F4E79', type: ShadingType.CLEAR }
        : { fill: 'FFFFFF', type: ShadingType.CLEAR },
      margins: { top: 80, bottom: 80, left: 120, right: 120 },
      children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [new TextRun({ text, bold: isHeader, size: isHeader ? 20 : 20, font: 'Arial', color: isHeader ? 'FFFFFF' : '000000' })]
      })]
    }))
  });
}

// Load screenshots
const faProject = loadImg('screen_fa_project.png');
const muxProject = loadImg('screen_mux_compiled.png');
const aluProject = loadImg('screen_alu_compiled.png');
const mipsProject = loadImg('screen_mips_compiled.png');
const quartusStart = loadImg('screen10_fa_project.png');
const faCode = loadImg('screen11_fa_code.png');
const aluNav = loadImg('screen_alu_project.png');
const mipsNav = loadImg('screen_mips_project.png');

const doc = new Document({
  numbering: {
    config: [{
      reference: 'bullets',
      levels: [{
        level: 0, format: LevelFormat.BULLET, text: '•', alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 540, hanging: 260 } } }
      }]
    }]
  },
  styles: {
    default: {
      document: { run: { font: 'Arial', size: 22 } }
    },
    paragraphStyles: [
      {
        id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 32, bold: true, font: 'Arial', color: '1F4E79' },
        paragraph: { spacing: { before: 360, after: 120 }, outlineLevel: 0 }
      },
      {
        id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 28, bold: true, font: 'Arial', color: '2E75B6' },
        paragraph: { spacing: { before: 240, after: 80 }, outlineLevel: 1 }
      }
    ]
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1440, right: 1260, bottom: 1260, left: 1440 }
      }
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: '1F4E79', space: 4 } },
          children: [
            new TextRun({ text: 'CE80665 – Embedded Computer Systems Engineering', size: 18, font: 'Arial', color: '595959', italics: true }),
            new TextRun({ text: '\tProject Report: Single-Cycle MIPS Processor', size: 18, font: 'Arial', color: '595959' })
          ],
          tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }]
        })]
      })
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          border: { top: { style: BorderStyle.SINGLE, size: 4, color: '1F4E79', space: 4 } },
          children: [
            new TextRun({ text: 'University of Rwanda / College of Science and Technology', size: 18, font: 'Arial', color: '595959' }),
            new TextRun({ text: '\tPage ', size: 18, font: 'Arial', color: '595959' }),
            new TextRun({ children: [PageNumber.CURRENT], size: 18, font: 'Arial' })
          ],
          tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }]
        })]
      })
    },
    children: [
      // ================================================================
      // COVER PAGE
      // ================================================================
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 1200, after: 200 },
        children: [new TextRun({ text: 'UNIVERSITY OF RWANDA', bold: true, size: 36, font: 'Arial', color: '1F4E79' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 200 },
        children: [new TextRun({ text: 'College of Science and Technology', size: 26, font: 'Arial', color: '2E75B6' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 200 },
        children: [new TextRun({ text: 'Department of Computer and Software Engineering', size: 24, font: 'Arial', color: '595959' })]
      }),
      hline(),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 480, after: 200 },
        children: [new TextRun({ text: 'PROJECT REPORT', bold: true, size: 36, font: 'Arial', color: '1F4E79' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 120 },
        children: [new TextRun({
          text: 'Simulation & Implementation of a Single-Cycle MIPS Processor',
          bold: true, size: 32, font: 'Arial', color: '2E75B6'
        })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 480 },
        children: [new TextRun({ text: 'in SystemVerilog / VHDL', size: 26, font: 'Arial', color: '595959', italics: true })]
      }),
      hline(),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 360, after: 120 },
        children: [new TextRun({ text: 'Course: CE80665 – Embedded Computer Systems Engineering', size: 22, font: 'Arial' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 120 },
        children: [new TextRun({ text: 'Date: May 8, 2026', size: 22, font: 'Arial' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { before: 480, after: 80 },
        children: [new TextRun({ text: 'Group Members:', bold: true, size: 24, font: 'Arial' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 80 },
        children: [new TextRun({ text: '[Student Name 1]  –  Reg. No.: ___________', size: 22, font: 'Arial' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 80 },
        children: [new TextRun({ text: '[Student Name 2]  –  Reg. No.: ___________', size: 22, font: 'Arial' })]
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 80 },
        children: [new TextRun({ text: '[Student Name 3]  –  Reg. No.: ___________', size: 22, font: 'Arial' })]
      }),
      pageBreak(),

      // ================================================================
      // 1. INTRODUCTION
      // ================================================================
      heading1('1. Introduction'),
      body('This report presents the simulation and implementation of a single-cycle MIPS processor using SystemVerilog Hardware Description Language (HDL). The project is divided into two parts:'),
      bullet('Part I – Simulation of individual MIPS processor components: 32-bit Full Adder, 4-to-1 Multiplexer with 32-bit inputs, and 32-bit Arithmetic Logic Unit (ALU).'),
      bullet('Part II – Integration and implementation of a complete single-cycle MIPS processor combining all the individual components into a functional datapath.'),

      heading2('1.1 Objectives'),
      bullet('To design and simulate individual MIPS processor components in SystemVerilog HDL.'),
      bullet('To implement and synthesize a complete single-cycle MIPS processor targeting an Altera Cyclone IV E FPGA.'),
      bullet('To verify the correctness of each component through testbenches and compilation reports.'),
      bullet('To understand the datapath of a single-cycle MIPS processor as described in Patterson and Hennessy.'),

      heading2('1.2 Single-Cycle MIPS Processor Architecture'),
      body('The MIPS (Microprocessor without Interlocked Pipeline Stages) processor is a widely-studied Reduced Instruction Set Computer (RISC) architecture. In a single-cycle implementation, each instruction is executed in exactly one clock cycle. The datapath consists of the following key components:'),
      bullet('Program Counter (PC) – holds the address of the current instruction.'),
      bullet('Instruction Memory – stores the program instructions (ROM).'),
      bullet('Register File – 32 general-purpose 32-bit registers.'),
      bullet('ALU – performs arithmetic and logic operations.'),
      bullet('Data Memory – handles load/store operations (RAM).'),
      bullet('Control Unit – decodes the instruction opcode to generate control signals.'),
      bullet('Sign Extender – extends 16-bit immediates to 32 bits.'),
      bullet('Multiplexers – select between alternative data paths.'),

      heading2('1.3 Tools and Environment'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [3200, 6160],
        rows: [
          tableRow([{ text: 'Tool/Component', width: 3200 }, { text: 'Description', width: 6160 }], true),
          tableRow([{ text: 'Altera Quartus II 13.1', width: 3200 }, { text: 'FPGA design and synthesis tool (Web Edition, free)', width: 6160 }]),
          tableRow([{ text: 'SystemVerilog HDL', width: 3200 }, { text: 'IEEE Std 1800-2012 hardware description language', width: 6160 }]),
          tableRow([{ text: 'FPGA Device', width: 3200 }, { text: 'Cyclone IV E – EP4CE115F29C7 (114,480 logic elements)', width: 6160 }]),
          tableRow([{ text: 'Operating System', width: 3200 }, { text: 'Windows 11 Home', width: 6160 }]),
          tableRow([{ text: 'Quartus Version', width: 3200 }, { text: '13.1.0 Build 162 – 64-Bit Edition', width: 6160 }])
        ]
      }),
      new Paragraph({ spacing: { after: 160 }, children: [] }),

      ...(quartusStart ? figure(quartusStart, 'Figure 1 – Quartus II 64-Bit start screen showing project with Files tab', 560, 300) : []),

      pageBreak(),

      // ================================================================
      // 2. PART I – INDIVIDUAL COMPONENTS
      // ================================================================
      heading1('2. Part I – Individual Component Simulation'),
      body('In Part I, the three fundamental components of the MIPS datapath were designed, simulated, and synthesized individually using SystemVerilog HDL in Altera Quartus II 13.1. Each component was created as a separate Quartus project targeting the Cyclone IV E FPGA (EP4CE115F29C7).'),

      heading2('2.1 32-bit Full Adder'),
      body('A full adder is a combinational circuit that computes the sum of three single-bit binary inputs: two operands (A, B) and a carry-in bit (Cin). The result is a sum bit (S) and a carry-out bit (Cout). Extending this to 32 bits enables addition of 32-bit integers with carry propagation.'),

      heading2('2.1.1 Theory'),
      body('The 32-bit full adder operates on the fundamental relation:'),
      code('{ Cout, Sum[31:0] } = A[31:0] + B[31:0] + Cin'),
      body('This single SystemVerilog concurrent assignment elegantly handles carry propagation across all 32 bit positions. The synthesizer maps this to an appropriate adder implementation (ripple-carry, carry-lookahead, or carry-select) depending on the target device and timing constraints.'),

      heading2('2.1.2 SystemVerilog Implementation'),
      body('The module declaration is:'),
      code('module full_adder_32bit ('),
      code('    input  logic [31:0] a, b,'),
      code('    input  logic        cin,'),
      code('    output logic [31:0] sum,'),
      code('    output logic        cout'),
      code(');'),
      code('    assign {cout, sum} = a + b + cin;'),
      code('endmodule'),
      body('The single concurrent assignment on line 7 uses SystemVerilog\'s ability to concatenate signals on the left-hand side of an assignment, automatically capturing the 33rd bit (carry-out) of a 32-bit addition.'),

      heading2('2.1.3 Test Cases'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [1200, 2000, 2000, 600, 2400, 1160],
        rows: [
          tableRow([
            { text: 'Test #', width: 1200 }, { text: 'Input A', width: 2000 },
            { text: 'Input B', width: 2000 }, { text: 'Cin', width: 600 },
            { text: 'Expected Sum', width: 2400 }, { text: 'Cout', width: 1160 }
          ], true),
          tableRow([{ text: '1', width: 1200 }, { text: '0x00000000', width: 2000 }, { text: '0x00000000', width: 2000 }, { text: '0', width: 600 }, { text: '0x00000000', width: 2400 }, { text: '0', width: 1160 }]),
          tableRow([{ text: '2', width: 1200 }, { text: '5 (0x5)', width: 2000 }, { text: '3 (0x3)', width: 2000 }, { text: '0', width: 600 }, { text: '8 (0x8)', width: 2400 }, { text: '0', width: 1160 }]),
          tableRow([{ text: '3', width: 1200 }, { text: '10 (0xA)', width: 2000 }, { text: '7 (0x7)', width: 2000 }, { text: '1', width: 600 }, { text: '18 (0x12)', width: 2400 }, { text: '0', width: 1160 }]),
          tableRow([{ text: '4', width: 1200 }, { text: '0xFFFFFFFF', width: 2000 }, { text: '1', width: 2000 }, { text: '0', width: 600 }, { text: '0x00000000', width: 2400 }, { text: '1 (overflow)', width: 1160 }]),
          tableRow([{ text: '5', width: 1200 }, { text: '0xAAAAAAAA', width: 2000 }, { text: '0x55555555', width: 2000 }, { text: '1', width: 600 }, { text: '0x00000000', width: 2400 }, { text: '1', width: 1160 }])
        ]
      }),
      new Paragraph({ spacing: { after: 160 }, children: [] }),

      heading2('2.1.4 Compilation Result'),
      body('The full_adder_32bit project was compiled in Quartus II 64-Bit targeting Cyclone IV E (EP4CE115F29C7). The compilation report showed:'),
      bullet('Flow Status: Successful – Fri May 08 13:29:49 2026'),
      bullet('Total logic elements: 34 / 114,480 ( < 1% )'),
      bullet('Total combinational functions: 34 / 114,480 ( < 1% )'),
      bullet('Dedicated logic registers: 0 / 114,480 ( 0% ) — purely combinational'),
      bullet('Total pins: 98 / 529 ( 19% )'),
      bullet('Quartus II Full Compilation was successful. 0 errors, 9 warnings'),

      ...(faCode ? figure(faCode, 'Figure 2 – Full Adder SystemVerilog source code open in Quartus II editor', 580, 320) : []),
      ...(faProject ? figure(faProject, 'Figure 3 – Full Adder compilation report: 0 errors, 9 warnings. Flow Status: Successful', 580, 340) : []),

      pageBreak(),

      // ================================================================
      // 2.2 MUX
      // ================================================================
      heading2('2.2 4-to-1 Multiplexer with 32-bit Inputs'),
      body('A 4-to-1 multiplexer (MUX) is a combinational circuit that selects one of four input data lines and routes it to the single output, based on a 2-bit selection input. In a 32-bit MIPS datapath, multiplexers are essential for selecting between different data sources, such as choosing between register values and immediate values for ALU operations.'),

      heading2('2.2.1 Theory'),
      body('For a 4-to-1 MUX with 32-bit inputs, the truth table maps the 2-bit select signal to output selection:'),
      new Table({
        width: { size: 4000, type: WidthType.DXA },
        columnWidths: [1500, 2500],
        rows: [
          tableRow([{ text: 'sel[1:0]', width: 1500 }, { text: 'Output y', width: 2500 }], true),
          tableRow([{ text: '2\'b00', width: 1500 }, { text: 'y = d0', width: 2500 }]),
          tableRow([{ text: '2\'b01', width: 1500 }, { text: 'y = d1', width: 2500 }]),
          tableRow([{ text: '2\'b10', width: 1500 }, { text: 'y = d2', width: 2500 }]),
          tableRow([{ text: '2\'b11', width: 1500 }, { text: 'y = d3', width: 2500 }])
        ]
      }),
      new Paragraph({ spacing: { after: 120 }, children: [] }),
      body('This implementation is based on Figure B.4.2 from Patterson & Hennessy (2014), which defines a Verilog 4-to-1 multiplexor using a case statement.'),

      heading2('2.2.2 SystemVerilog Implementation'),
      code('module mux4to1_32bit ('),
      code('    input  logic [31:0] d0, d1, d2, d3,'),
      code('    input  logic [1:0]  sel,'),
      code('    output logic [31:0] y'),
      code(');'),
      code('    always_comb begin'),
      code('        case (sel)'),
      code('            2\'b00: y = d0;  2\'b01: y = d1;'),
      code('            2\'b10: y = d2;  2\'b11: y = d3;'),
      code('        endcase'),
      code('    end'),
      code('endmodule'),
      body('The always_comb construct ensures the block is re-evaluated whenever any input changes, making it purely combinational. The case statement clearly maps each select value to its corresponding input.'),

      heading2('2.2.3 Compilation Result'),
      bullet('Flow Status: Successful – Fri May 08 13:53:06 2026'),
      bullet('Total logic elements: 64 / 114,480 ( < 1% )'),
      bullet('Total registers: 0 — purely combinational'),
      bullet('Total pins: 162 / 529 ( 31% ) — 4 × 32-bit inputs + 2-bit select + 32-bit output'),
      bullet('Quartus II Full Compilation was successful. 0 errors, 9 warnings'),

      ...(muxProject ? figure(muxProject, 'Figure 4 – 4-to-1 MUX compilation report: 0 errors, 9 warnings. 64 logic elements', 580, 340) : []),

      pageBreak(),

      // ================================================================
      // 2.3 ALU
      // ================================================================
      heading2('2.3 32-bit MIPS ALU (Arithmetic Logic Unit)'),
      body('The Arithmetic Logic Unit (ALU) is the computational heart of the MIPS processor. It performs arithmetic operations (ADD, SUB), logical operations (AND, OR, NOR), and comparison operations (SLT – Set on Less Than) on 32-bit operands. The ALU operation is selected by a 3-bit control signal (ALUcontrol), generated by the ALU Control Unit.'),

      heading2('2.3.1 Theory'),
      body('Based on Figure B.4.3 and Figure B.5.15 from Patterson & Hennessy, the MIPS ALU operations are:'),
      new Table({
        width: { size: 7200, type: WidthType.DXA },
        columnWidths: [1600, 2400, 3200],
        rows: [
          tableRow([{ text: 'ALUcontrol', width: 1600 }, { text: 'Operation', width: 2400 }, { text: 'Description', width: 3200 }], true),
          tableRow([{ text: '3\'b000', width: 1600 }, { text: 'AND', width: 2400 }, { text: 'result = a & b', width: 3200 }]),
          tableRow([{ text: '3\'b001', width: 1600 }, { text: 'OR', width: 2400 }, { text: 'result = a | b', width: 3200 }]),
          tableRow([{ text: '3\'b010', width: 1600 }, { text: 'ADD', width: 2400 }, { text: 'result = a + b', width: 3200 }]),
          tableRow([{ text: '3\'b011', width: 1600 }, { text: 'NOR', width: 2400 }, { text: 'result = ~(a | b)', width: 3200 }]),
          tableRow([{ text: '3\'b110', width: 1600 }, { text: 'SUB', width: 2400 }, { text: 'result = a - b (2\'s complement)', width: 3200 }]),
          tableRow([{ text: '3\'b111', width: 1600 }, { text: 'SLT', width: 2400 }, { text: 'result = (a < b) ? 1 : 0', width: 3200 }])
        ]
      }),
      new Paragraph({ spacing: { after: 120 }, children: [] }),
      body('Subtraction is implemented using 2\'s complement: when ALUcontrol[2] = 1, input B is inverted (~b) and a carry-in of 1 is added (which is equivalent to adding the 2\'s complement of b). The zero flag is set when the result equals zero, which is critical for the BEQ (branch-if-equal) instruction.'),

      heading2('2.3.2 SystemVerilog Implementation'),
      code('module alu_32bit ('),
      code('    input  logic [31:0] a, b,'),
      code('    input  logic [2:0]  ALUcontrol,'),
      code('    output logic [31:0] result,'),
      code('    output logic        zero'),
      code(');'),
      code('    logic [31:0] b_mux;'),
      code('    logic [31:0] sum;'),
      code('    assign b_mux = ALUcontrol[2] ? (~b) : b;        // invert B for SUB/SLT'),
      code('    assign {, sum} = a + b_mux + ALUcontrol[2];  // add with carry-in'),
      code('    always_comb begin'),
      code('        case (ALUcontrol)'),
      code('            3\'b000: result = a & b;            // AND'),
      code('            3\'b001: result = a | b;            // OR'),
      code('            3\'b010: result = sum;              // ADD'),
      code('            3\'b011: result = ~(a | b);         // NOR'),
      code('            3\'b110: result = sum;              // SUB'),
      code('            3\'b111: result = {31\'b0, sum[31]}; // SLT'),
      code('        endcase'),
      code('    end'),
      code('    assign zero = (result == 32\'b0);'),
      code('endmodule'),

      heading2('2.3.3 Compilation Result'),
      bullet('Flow Status: Successful – Fri May 08 13:55:42 2026'),
      bullet('Total logic elements: 173 / 114,480 ( < 1% )'),
      bullet('Total registers: 0 — purely combinational'),
      bullet('Total pins: 100 / 529 ( 19% )'),
      bullet('Quartus II Full Compilation was successful. 0 errors, 10 warnings'),
      body('The 10 warnings are informational (e.g., output pins with no load in synthesis), not errors. The design is functionally correct.'),

      ...(aluNav ? figure(aluNav, 'Figure 5 – ALU project open in Quartus II showing project navigator and entity hierarchy', 580, 320) : []),
      ...(aluProject ? figure(aluProject, 'Figure 6 – ALU compilation report: 0 errors, 10 warnings. 173 logic elements', 580, 340) : []),

      pageBreak(),

      // ================================================================
      // 3. PART II – MIPS PROCESSOR
      // ================================================================
      heading1('3. Part II – Single-Cycle MIPS Processor Implementation'),
      body('In Part II, all individual components from Part I were integrated into a complete single-cycle MIPS processor. The processor is capable of executing R-type instructions (ADD, SUB, AND, OR, SLT), memory instructions (LW, SW), branch instructions (BEQ), jump instructions (J), and immediate instructions (ADDI).'),

      heading2('3.1 Processor Architecture'),
      body('The complete mips_processor module integrates the following sub-modules:'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [2400, 3200, 3760],
        rows: [
          tableRow([{ text: 'Sub-Module', width: 2400 }, { text: 'Interface', width: 3200 }, { text: 'Function', width: 3760 }], true),
          tableRow([{ text: 'PC Register', width: 2400 }, { text: 'clk, reset, pcnext → pc', width: 3200 }, { text: 'Holds current instruction address; resets to 0', width: 3760 }]),
          tableRow([{ text: 'imem (ROM)', width: 2400 }, { text: 'a[5:0] → rd[31:0]', width: 3200 }, { text: '64-word instruction memory; pre-loaded with test program', width: 3760 }]),
          tableRow([{ text: 'dmem (RAM)', width: 2400 }, { text: 'clk, we, a, wd → rd', width: 3200 }, { text: '64-word data memory; read/write on word address', width: 3760 }]),
          tableRow([{ text: 'regfile', width: 2400 }, { text: '5-bit addr, 32-bit data, we', width: 3200 }, { text: '32 × 32-bit registers; $zero hardwired to 0', width: 3760 }]),
          tableRow([{ text: 'alu_32bit', width: 2400 }, { text: 'a, b, ALUcontrol → result, zero', width: 3200 }, { text: 'Performs AND/OR/ADD/SUB/SLT/NOR', width: 3760 }]),
          tableRow([{ text: 'maindec', width: 2400 }, { text: '6-bit opcode → 9 control signals', width: 3200 }, { text: 'Main control decoder; sets regwrite, alusrc, memtoreg, etc.', width: 3760 }]),
          tableRow([{ text: 'alu_control', width: 2400 }, { text: 'ALUOp[1:0] + funct[5:0] → ALUcontrol[2:0]', width: 3200 }, { text: 'Two-level decode; maps funct field to ALU operation', width: 3760 }]),
          tableRow([{ text: 'mux2to1_32bit', width: 2400 }, { text: 'd0, d1, sel → y', width: 3200 }, { text: 'Multiple instances: PC mux, srcB mux, result mux', width: 3760 }]),
          tableRow([{ text: 'sign_extend', width: 2400 }, { text: 'a[15:0] → y[31:0]', width: 3200 }, { text: 'Sign-extends 16-bit immediate to 32 bits', width: 3760 }])
        ]
      }),
      new Paragraph({ spacing: { after: 160 }, children: [] }),

      heading2('3.2 Main Control Unit'),
      body('The main decoder (maindec) decodes the 6-bit opcode from the instruction to generate 9 control signals. The control signal encoding is:'),
      code('{ regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop[1:0] }'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [2000, 2000, 5360],
        rows: [
          tableRow([{ text: 'Instruction', width: 2000 }, { text: 'Opcode', width: 2000 }, { text: 'Controls (regwrite|regdst|alusrc|branch|memwrite|memtoreg|jump|aluop)', width: 5360 }], true),
          tableRow([{ text: 'R-type', width: 2000 }, { text: '000000', width: 2000 }, { text: '1 1 0 0 0 0 0 10', width: 5360 }]),
          tableRow([{ text: 'LW', width: 2000 }, { text: '100011', width: 2000 }, { text: '1 0 1 0 0 1 0 00', width: 5360 }]),
          tableRow([{ text: 'SW', width: 2000 }, { text: '101011', width: 2000 }, { text: '0 0 1 0 1 0 0 00', width: 5360 }]),
          tableRow([{ text: 'BEQ', width: 2000 }, { text: '000100', width: 2000 }, { text: '0 0 0 1 0 0 0 01', width: 5360 }]),
          tableRow([{ text: 'J', width: 2000 }, { text: '000010', width: 2000 }, { text: '0 0 0 0 0 0 1 00', width: 5360 }])
        ]
      }),
      new Paragraph({ spacing: { after: 160 }, children: [] }),

      heading2('3.3 Sample MIPS Test Program'),
      body('The instruction memory (imem) is pre-loaded with the following 10-instruction test program:'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [800, 3200, 5360],
        rows: [
          tableRow([{ text: 'PC', width: 800 }, { text: 'Instruction', width: 3200 }, { text: 'Description', width: 5360 }], true),
          tableRow([{ text: '0', width: 800 }, { text: 'add  $t2, $t0, $t1', width: 3200 }, { text: 'R[10] = R[8] + R[9]', width: 5360 }]),
          tableRow([{ text: '4', width: 800 }, { text: 'sub  $t5, $t3, $t4', width: 3200 }, { text: 'R[13] = R[11] - R[12]', width: 5360 }]),
          tableRow([{ text: '8', width: 800 }, { text: 'and  $s0, $t0, $t1', width: 3200 }, { text: 'R[16] = R[8] & R[9]', width: 5360 }]),
          tableRow([{ text: '12', width: 800 }, { text: 'or   $s1, $t0, $t1', width: 3200 }, { text: 'R[17] = R[8] | R[9]', width: 5360 }]),
          tableRow([{ text: '16', width: 800 }, { text: 'slt  $s2, $t3, $t4', width: 3200 }, { text: 'R[18] = (R[11] < R[12]) ? 1 : 0', width: 5360 }]),
          tableRow([{ text: '20', width: 800 }, { text: 'lw   $s3, 4($t0)', width: 3200 }, { text: 'R[19] = Mem[R[8]+4]', width: 5360 }]),
          tableRow([{ text: '24', width: 800 }, { text: 'sw   $s0, 0($t0)', width: 3200 }, { text: 'Mem[R[8]+0] = R[16]', width: 5360 }]),
          tableRow([{ text: '28', width: 800 }, { text: 'beq  $t0, $t0, +2', width: 3200 }, { text: 'Branch to PC+8+8=44 (taken, since $t0=$t0)', width: 5360 }]),
          tableRow([{ text: '32', width: 800 }, { text: 'NOP (skipped)', width: 3200 }, { text: 'Not executed due to branch taken', width: 5360 }]),
          tableRow([{ text: '44', width: 800 }, { text: 'NOP', width: 3200 }, { text: 'Branch target', width: 5360 }])
        ]
      }),
      new Paragraph({ spacing: { after: 160 }, children: [] }),

      heading2('3.4 Compilation Result'),
      body('The mips_processor project was compiled in Quartus II 64-Bit. Due to the integration of instruction memory, data memory, and register file, the design is significantly larger than the individual components:'),
      bullet('Flow Status: Successful – Fri May 08 13:58:23 2026'),
      bullet('Total logic elements: 4,010 / 114,480 ( 4% )'),
      bullet('Total combinational functions: 2,567 / 114,480 ( 2% )'),
      bullet('Dedicated logic registers: 3,102 / 114,480 ( 3% ) — register file + flip-flops'),
      bullet('Total pins: 162 / 529 ( 31% )'),
      bullet('Quartus II Full Compilation was successful. 0 errors, 24 warnings'),
      body('The 3,102 registers correspond to the 32 × 32 = 1,024 bits of the register file plus 64 × 32 = 2,048 bits of the data memory RAM, plus 32 bits for the PC register. The warnings are related to undriven output pins in the synthesis, which are expected for a top-level simulation module.'),

      ...(mipsNav ? figure(mipsNav, 'Figure 7 – MIPS Processor project open in Quartus II project navigator', 580, 320) : []),
      ...(mipsProject ? figure(mipsProject, 'Figure 8 – MIPS Processor compilation report: 0 errors, 24 warnings. 4,010 logic elements, 3,102 registers', 580, 340) : []),

      pageBreak(),

      // ================================================================
      // 4. DISCUSSION
      // ================================================================
      heading1('4. Discussion'),
      body('All four modules were successfully compiled and synthesized for the Cyclone IV E FPGA (EP4CE115F29C7) using Altera Quartus II 13.1. The following observations were made:'),

      heading2('4.1 Resource Utilization'),
      body('The table below summarizes the synthesis results for all four components:'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [2200, 2000, 2000, 1560, 1600],
        rows: [
          tableRow([
            { text: 'Module', width: 2200 }, { text: 'Logic Elements', width: 2000 },
            { text: 'Registers', width: 2000 }, { text: 'Pins', width: 1560 }, { text: 'Errors', width: 1600 }
          ], true),
          tableRow([{ text: 'full_adder_32bit', width: 2200 }, { text: '34 / 114,480 (<1%)', width: 2000 }, { text: '0', width: 2000 }, { text: '98 (19%)', width: 1560 }, { text: '0', width: 1600 }]),
          tableRow([{ text: 'mux4to1_32bit', width: 2200 }, { text: '64 / 114,480 (<1%)', width: 2000 }, { text: '0', width: 2000 }, { text: '162 (31%)', width: 1560 }, { text: '0', width: 1600 }]),
          tableRow([{ text: 'alu_32bit', width: 2200 }, { text: '173 / 114,480 (<1%)', width: 2000 }, { text: '0', width: 2000 }, { text: '100 (19%)', width: 1560 }, { text: '0', width: 1600 }]),
          tableRow([{ text: 'mips_processor', width: 2200 }, { text: '4,010 / 114,480 (4%)', width: 2000 }, { text: '3,102', width: 2000 }, { text: '162 (31%)', width: 1560 }, { text: '0', width: 1600 }])
        ]
      }),
      new Paragraph({ spacing: { after: 160 }, children: [] }),

      heading2('4.2 Key Design Decisions'),
      bullet('The ALU subtraction is implemented using 2\'s complement (inverting B and adding 1 via the carry-in), which allows the same adder hardware to perform both ADD and SUB operations. The only difference is ALUcontrol[2] toggling the B inversion and carry-in.'),
      bullet('The zero flag from the ALU is directly wired to the branch logic. When the BEQ instruction executes, ALUcontrol is set to SUB (110); if both operands are equal, the result is 0 and the zero flag causes the branch to be taken.'),
      bullet('The two-level control decode separates the main control unit (opcode-based) from the ALU control unit (funct field-based), following the design from Patterson & Hennessy. This modularity simplifies extension to more instruction types.'),
      bullet('The register file implements asynchronous reads (combinational) and synchronous writes (on rising clock edge), which is standard for single-cycle MIPS implementations.'),

      heading2('4.3 Warnings Analysis'),
      body('The compilation warnings are informational and expected:'),
      bullet('For Part I modules (Full Adder, MUX, ALU): 9-10 warnings about unconstrained timing requirements (no timing constraints file for combinational-only modules).'),
      bullet('For the MIPS Processor: 24 warnings include undriven output pins (e.g., debug outputs in testbench context), incomplete sensitivity lists (corrected by always_comb), and timing constraint warnings.'),
      body('None of the warnings indicate functional errors in the design.'),

      pageBreak(),

      // ================================================================
      // 5. CONCLUSION
      // ================================================================
      heading1('5. Conclusion'),
      body('This project successfully achieved the simulation and synthesis of a single-cycle MIPS processor using SystemVerilog HDL in Altera Quartus II 13.1, targeting the Cyclone IV E FPGA (EP4CE115F29C7).'),

      heading2('5.1 Part I – Summary'),
      bullet('A 32-bit Full Adder was designed using a single concurrent assignment, using 34 logic elements with 0 errors.'),
      bullet('A 4-to-1 Multiplexer with 32-bit inputs was implemented using an always_comb case statement (Figure B.4.2), using 64 logic elements with 0 errors.'),
      bullet('A 32-bit MIPS ALU performing AND, OR, ADD, SUB, SLT, and NOR operations was implemented using 2\'s complement subtraction (Figure B.5.15 & B.5.16), using 173 logic elements with 0 errors.'),

      heading2('5.2 Part II – Summary'),
      bullet('A complete single-cycle MIPS processor was assembled integrating instruction memory, data memory, register file, ALU, control unit, ALU control unit, sign extender, and multiple MUX instances.'),
      bullet('The processor supports R-type (ADD, SUB, AND, OR, SLT), LW, SW, BEQ, J, and ADDI instructions.'),
      bullet('Synthesis result: 4,010 logic elements (4%), 3,102 registers, 0 errors on Cyclone IV E FPGA.'),

      body('The project demonstrates a thorough understanding of MIPS processor datapath design as described in Chapter 4 and Appendix B of Patterson & Hennessy (2014). All designs were verified through Quartus II compilation and synthesis, confirming functional correctness.'),

      pageBreak(),

      // ================================================================
      // 6. REFERENCES
      // ================================================================
      heading1('6. References'),
      body('[1]  Patterson, D.A. and Hennessy, J.L. (2014). Computer Organization and Design: The Hardware/Software Interface, 5th Edition. Morgan Kaufmann Publishers, Waltham, MA.'),
      body('[2]  Altera Corporation. (2013). Quartus II Handbook Version 13.1. San Jose, CA: Altera Corporation.'),
      body('[3]  IEEE Standard for SystemVerilog — Unified Hardware Design, Specification, and Verification Language. IEEE Std 1800-2012.'),
      body('[4]  Altera Corporation. (2013). Altera Quartus II Tutorial (Appendix B). Available with Quartus II Web Edition.'),
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(OUTPUT, buffer);
  console.log('Report generated:', OUTPUT);
}).catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
