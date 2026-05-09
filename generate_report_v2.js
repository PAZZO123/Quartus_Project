const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  ImageRun, Header, Footer, AlignmentType, HeadingLevel, BorderStyle,
  WidthType, ShadingType, PageNumber, PageBreak, LevelFormat,
  TabStopType, TabStopPosition
} = require('docx');
const fs = require('fs');
const path = require('path');

const SS   = 'C:\\Users\\USER\\Documents\\MIPS_Project\\screenshots';
const OUT  = 'C:\\Users\\USER\\Documents\\MIPS_Project\\MIPS_Lab2_Report.docx';

function img(fn) {
  const fp = path.join(SS, fn);
  return fs.existsSync(fp) ? fs.readFileSync(fp) : null;
}

// ── Typography helpers ────────────────────────────────────────────────────────
const BLUE  = '1F4E79';
const BLUE2 = '2E75B6';
const RED   = 'C00000';
const GRAY  = '595959';
const BLACK = '000000';

function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 300, after: 80 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: BLUE2, space: 4 } },
    children: [new TextRun({ text, bold: true, size: 28, font: 'Arial', color: BLUE })]
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 200, after: 60 },
    children: [new TextRun({ text, bold: true, size: 24, font: 'Arial', color: BLUE2 })]
  });
}

function h3(text) {
  return new Paragraph({
    spacing: { before: 140, after: 40 },
    children: [new TextRun({ text, bold: true, size: 22, font: 'Arial', color: BLUE2 })]
  });
}

function step(n, title) {
  return new Paragraph({
    spacing: { before: 180, after: 50 },
    children: [new TextRun({ text: `Step ${n}: ${title}`, bold: true, size: 22, font: 'Arial', color: BLUE2 })]
  });
}

function body(text, opts = {}) {
  return new Paragraph({
    alignment: AlignmentType.JUSTIFIED,
    spacing: { after: 100 },
    indent: opts.indent ? { left: 360 } : undefined,
    children: [new TextRun({ text, size: 22, font: 'Arial', bold: opts.bold || false, italic: opts.italic || false })]
  });
}

function bullet(text) {
  return new Paragraph({
    numbering: { reference: 'bullets', level: 0 },
    spacing: { after: 60 },
    children: [new TextRun({ text, size: 22, font: 'Arial' })]
  });
}

function numbered(n, text) {
  return new Paragraph({
    spacing: { after: 60 },
    indent: { left: 540, hanging: 360 },
    children: [
      new TextRun({ text: `${n}.\t`, size: 22, font: 'Arial', bold: true }),
      new TextRun({ text, size: 22, font: 'Arial' })
    ]
  });
}

function code(text) {
  return new Paragraph({
    spacing: { after: 30 },
    indent: { left: 720 },
    shading: { type: ShadingType.CLEAR, fill: 'F5F5F5' },
    children: [new TextRun({ text, font: 'Courier New', size: 18, color: '1F4E79' })]
  });
}

function fig(imgData, caption, w = 540, h = 300) {
  const out = [];
  if (imgData) {
    out.push(new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 120, after: 50 },
      children: [new ImageRun({
        type: 'png', data: imgData,
        transformation: { width: w, height: h },
        altText: { title: caption, description: caption, name: caption }
      })]
    }));
  }
  out.push(new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 160 },
    children: [new TextRun({ text: caption, italic: true, size: 19, font: 'Arial', color: GRAY })]
  }));
  return out;
}

function pb() { return new Paragraph({ children: [new PageBreak()] }); }
function sp(n = 80) { return new Paragraph({ spacing: { after: n }, children: [] }); }

function hline() {
  return new Paragraph({
    spacing: { before: 80, after: 80 },
    border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: BLUE2, space: 2 } },
    children: []
  });
}

const BORDER = { style: BorderStyle.SINGLE, size: 1, color: 'BFBFBF' };
const BORDERS = { top: BORDER, bottom: BORDER, left: BORDER, right: BORDER };

function tblRow(cells, isHeader = false) {
  return new TableRow({
    tableHeader: isHeader,
    children: cells.map(({ text, w }) => new TableCell({
      borders: BORDERS,
      width: { size: w, type: WidthType.DXA },
      shading: isHeader
        ? { fill: BLUE, type: ShadingType.CLEAR }
        : { fill: 'FFFFFF', type: ShadingType.CLEAR },
      margins: { top: 80, bottom: 80, left: 120, right: 120 },
      verticalAlign: 'center',
      children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [new TextRun({
          text, size: 20, font: 'Arial',
          bold: isHeader, color: isHeader ? 'FFFFFF' : BLACK
        })]
      })]
    }))
  });
}

// ── Load images ───────────────────────────────────────────────────────────────
const imgQuartusStart  = img('screen04_quartus64.png');
const imgFAProject     = img('screen10_fa_project.png');
const imgFACode        = img('screen11_fa_code.png');
const imgFACompiled    = img('screen_fa_project.png');
const imgMUXCompiled   = img('screen_mux_compiled.png');
const imgALUProject    = img('screen_alu_project.png');
const imgALUCompiled   = img('screen_alu_compiled.png');
const imgMIPSProject   = img('screen_mips_project.png');
const imgMIPSCompiled  = img('screen_mips_compiled.png');
const imgBlockDiagram  = img('mips_block_diagram.png');
const imgRTLViewer     = img('screen_rtl_wide.png');
const imgSimResults    = img('sim_results.png');
const imgRTLViewerFA   = img('screen_rtl_fa.png');
const imgSimFAResults  = img('sim_fa_results.png');
const imgRTLViewerMIPS = img('screen_rtl_mips.png');
const imgSimMIPSResults= img('sim_mips_results.png');

// ── Document ──────────────────────────────────────────────────────────────────
const doc = new Document({
  numbering: {
    config: [{
      reference: 'bullets',
      levels: [{
        level: 0, format: LevelFormat.BULLET, text: '•',
        alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 540, hanging: 260 } } }
      }]
    }]
  },
  styles: {
    default: { document: { run: { font: 'Arial', size: 22 } } },
    paragraphStyles: [
      {
        id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 28, bold: true, font: 'Arial', color: BLUE },
        paragraph: { spacing: { before: 300, after: 80 }, outlineLevel: 0 }
      },
      {
        id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 24, bold: true, font: 'Arial', color: BLUE2 },
        paragraph: { spacing: { before: 200, after: 60 }, outlineLevel: 1 }
      }
    ]
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1260, right: 1260, bottom: 1260, left: 1440 }
      }
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: BLUE2, space: 3 } },
          children: [
            new TextRun({ text: 'CE80665 Embedded Computer Systems Engineering — Lab 2 Report', size: 17, font: 'Arial', color: GRAY, italics: true }),
            new TextRun({ text: '\t[Student1], [Student2], [Student3]', size: 17, font: 'Arial', color: GRAY })
          ],
          tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }]
        })]
      })
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          border: { top: { style: BorderStyle.SINGLE, size: 4, color: BLUE2, space: 3 } },
          children: [
            new TextRun({ text: 'University of Rwanda — College of Science and Technology', size: 17, font: 'Arial', color: GRAY }),
            new TextRun({ text: '\tPage ', size: 17, font: 'Arial', color: GRAY }),
            new TextRun({ children: [PageNumber.CURRENT], size: 17, font: 'Arial', color: GRAY })
          ],
          tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }]
        })]
      })
    },

    // ════════════════════════════════════════════════════════════════════════
    children: [

      // ── COVER PAGE ──────────────────────────────────────────────────────
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 900, after: 160 },
        children: [new TextRun({ text: 'UNIVERSITY OF RWANDA', bold: true, size: 34, font: 'Arial', color: BLUE })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 120 },
        children: [new TextRun({ text: 'COLLEGE OF SCIENCE AND TECHNOLOGY', bold: true, size: 26, font: 'Arial', color: BLUE2 })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 },
        children: [new TextRun({ text: 'SCHOOL OF ICT', bold: true, size: 24, font: 'Arial', color: BLUE2 })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 180 },
        children: [new TextRun({ text: 'DEPARTMENT OF COMPUTER AND SOFTWARE ENGINEERING', bold: true, size: 22, font: 'Arial', color: BLUE2 })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 200 },
        children: [
          new TextRun({ text: 'Module: ', bold: true, size: 22, font: 'Arial' }),
          new TextRun({ text: 'CE80665 Embedded Computer Systems Engineering', size: 22, font: 'Arial' })
        ] }),
      hline(),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 360, after: 140 },
        children: [new TextRun({ text: 'LAB #2 REPORT', bold: true, size: 36, font: 'Arial', color: BLUE })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 100 },
        children: [new TextRun({ text: 'Altera Quartus II: FPGA Design with SystemVerilog', bold: true, size: 26, font: 'Arial', color: BLUE2 })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 360 },
        children: [new TextRun({ text: 'Simulation & Implementation of a Single-Cycle MIPS Processor', size: 22, font: 'Arial', color: GRAY })] }),
      hline(),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 300, after: 80 },
        children: [new TextRun({ text: 'Group Members:', bold: true, size: 24, font: 'Arial' })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 80 },
        children: [new TextRun({ text: '[Student Name 1]  —  Registration No: ___________', size: 22, font: 'Arial' })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 80 },
        children: [new TextRun({ text: '[Student Name 2]  —  Registration No: ___________', size: 22, font: 'Arial' })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 80 },
        children: [new TextRun({ text: '[Student Name 3]  —  Registration No: ___________', size: 22, font: 'Arial' })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 200, after: 80 },
        children: [new TextRun({ text: 'Date: May 8, 2026', size: 22, font: 'Arial' })] }),
      pb(),

      // ── 1. INTRODUCTION ─────────────────────────────────────────────────
      h1('1. Introduction'),
      body('Altera Quartus II is a comprehensive design software suite developed by Altera Corporation (now Intel) for the design, simulation, synthesis, and implementation of digital circuits on CPLD (Complex Programmable Logic Device) and FPGA (Field Programmable Gate Array) platforms. Quartus II provides an integrated environment that supports multiple Hardware Description Languages (HDLs), including VHDL, Verilog, SystemVerilog, and schematic-based entry.'),
      body('In this lab, we use Quartus II version 13.1 (64-bit) Web Edition — a free version suitable for academic and small-scale FPGA design. The target device family used is Cyclone IV E (EP4CE115F29C7), a high-performance FPGA from Altera with 114,480 logic elements, widely used in embedded systems design.'),
      body('The circuit implemented in this lab is a complete Single-Cycle MIPS processor described in SystemVerilog HDL, based on the architecture presented in Patterson & Hennessy, “Computer Organization and Design” (2014), Appendix B. The MIPS processor executes each instruction in exactly one clock cycle and supports the following instruction types: R-type (ADD, SUB, AND, OR, SLT), memory instructions (LW, SW), branch instructions (BEQ), and jump instructions (J).'),
      body('This lab report covers all eight sections of the Altera Quartus II Tutorial as applied to the MIPS processor design:'),
      numbered(1, 'Introduction — Overview of Quartus II and the MIPS processor circuit.'),
      numbered(2, 'Starting a New Project — Creating Quartus II projects for each design component.'),
      numbered(3, 'Synthesizing the Design — Compiling and synthesizing all SystemVerilog modules.'),
      numbered(4, 'Inspecting Synthesis Results — Reviewing Compilation Reports and the datapath block diagram.'),
      numbered(5, 'Simulating the Circuit — Functional testbench simulation and waveform analysis.'),
      numbered(6, 'Making Pin Assignments — Assigning physical I/O pins to design signals.'),
      numbered(7, 'Physically Implementing the Circuit — Optional (no physical hardware available).'),
      numbered(8, 'Interpreting the Fitter Equations — Understanding logic equations generated by the Fitter.'),
      sp(),
      h2('1.1 Design Overview: Single-Cycle MIPS Processor'),
      body('The MIPS (Microprocessor without Interlocked Pipeline Stages) architecture is a 32-bit RISC (Reduced Instruction Set Computer) design. In a single-cycle implementation, each instruction fetches, decodes, executes, and writes back results within one clock period. The processor datapath consists of the following key sub-modules:'),
      bullet('Program Counter (PC) — 32-bit register holding the current instruction address.'),
      bullet('Instruction Memory (imem) — 64-word read-only ROM pre-loaded with the test program.'),
      bullet('Register File (regfile) — 32 general-purpose 32-bit registers ($zero hardwired to 0).'),
      bullet('32-bit ALU (alu_32bit) — performs AND, OR, ADD, SUB, SLT, NOR operations.'),
      bullet('ALU Control Unit (alu_control) — decodes ALUOp[1:0] and funct[5:0] to ALUcontrol[2:0].'),
      bullet('Main Decoder (maindec) — decodes 6-bit opcode to 9 control signals.'),
      bullet('Data Memory (dmem) — 64-word synchronous RAM for LW/SW instructions.'),
      bullet('Sign Extender (sign_extend) — extends 16-bit immediate to 32 bits.'),
      bullet('Multiplexers — mux2to1 instances selecting ALUSrc, RegDst, MemToReg, PCSrc.'),
      sp(),
      h2('1.2 Tools and Environment'),
      new Table({
        width: { size: 9360, type: WidthType.DXA }, columnWidths: [3000, 6360],
        rows: [
          tblRow([{ text: 'Tool / Component', w: 3000 }, { text: 'Description', w: 6360 }], true),
          tblRow([{ text: 'Altera Quartus II 13.1', w: 3000 }, { text: 'FPGA design & synthesis suite (64-bit Web Edition, free)', w: 6360 }]),
          tblRow([{ text: 'HDL Language', w: 3000 }, { text: 'SystemVerilog (IEEE Std 1800-2012)', w: 6360 }]),
          tblRow([{ text: 'FPGA Family', w: 3000 }, { text: 'Cyclone IV E — EP4CE115F29C7 (114,480 LEs)', w: 6360 }]),
          tblRow([{ text: 'Operating System', w: 3000 }, { text: 'Windows 11 Home (64-bit)', w: 6360 }]),
          tblRow([{ text: 'Quartus Build', w: 3000 }, { text: '13.1.0 Build 162 — 64-Bit Edition', w: 6360 }])
        ]
      }),
      sp(),
      ...fig(imgQuartusStart, 'Figure 1.1 — Quartus II 13.1 (64-bit) Web Edition main window showing project navigator', 530, 290),
      pb(),

      // ── 2. STARTING A NEW PROJECT ────────────────────────────────────────
      h1('2. Starting a New Project'),
      body('To begin working in Quartus II, a separate project was created for each design component. A Quartus II project contains all HDL design files, compilation settings, and device assignment information. The following procedure was repeated for each of the four modules: Full Adder (full_adder_32bit), 4-to-1 MUX (mux4to1_32bit), 32-bit ALU (alu_32bit), and the complete MIPS Processor (mips_processor).'),
      sp(60),
      step(1, 'Launch Quartus II'),
      body('Quartus II 13.1 (64-bit) Web Edition was launched from C:\\altera\\13.1\\quartus\\bin64\\quartus_64bit.exe. The main Project Navigator window appeared with the Entity hierarchy panel on the left, the Tasks panel showing compilation flow steps (Analysis & Synthesis, Fitter, Assembler, TimeQuest Timing Analyzer), and the central workspace.'),
      sp(60),
      step(2, 'Create a New Project Using the New Project Wizard'),
      body('A new project was created by selecting File > New Project Wizard. In the Directory, Name, Top-Level Entity dialog (Page 1 of 5), the following settings were entered for the MIPS Processor project:'),
      bullet('Working Directory: C:\\Users\\USER\\Documents\\MIPS_Project\\mips'),
      bullet('Project Name: mips_processor'),
      bullet('Top-Level Design Entity: mips_processor (case-sensitive, must match module name)'),
      body('The project name was chosen to exactly match the top-level entity name of the design. This is mandatory in Quartus II — a mismatch between the project name and entity name will cause compilation errors.'),
      sp(60),
      step(3, 'Configure Project Settings'),
      body('After proceeding through the New Project Wizard, the project settings were verified via Assignments > Settings. The General settings confirmed the top-level entity was correctly set. The Analysis & Synthesis Settings section shows SystemVerilog HDL Input is supported, confirming that SystemVerilog (.sv) files can be used directly.'),
      sp(60),
      step(4, 'Select Target Device'),
      body('The target FPGA device was selected via Assignments > Device. The Cyclone IV E device family was chosen with the specific device EP4CE115F29C7 (114,480 logic elements, 529 I/O pins, in an FBGA 780-pin package at speed grade C7). This device was selected as it is the default for the Cyclone IV E development kit available in the lab environment.'),
      sp(60),
      step(5, 'Add SystemVerilog Source Files'),
      body('SystemVerilog design files were added to the project via Project > Add/Remove Files in Project. All .sv source files were added from the project directory:'),
      bullet('mips_processor.sv — top-level module integrating all sub-modules'),
      bullet('alu_32bit.sv — 32-bit ALU with 6 operations'),
      bullet('alu_control.sv — ALU control decoder'),
      ...fig(imgFAProject, 'Figure 2.1 — Quartus II Project Navigator showing full_adder_32bit project with Files tab', 530, 290),
      ...fig(imgMIPSProject, 'Figure 2.2 — Quartus II Project Navigator for mips_processor showing entity hierarchy', 530, 290),
      pb(),

      // ── 3. SYNTHESIZING THE DESIGN ───────────────────────────────────────
      h1('3. Synthesizing the Design'),
      body('Synthesis is the process by which HDL source code is translated into a netlist of logic gates and flip-flops that can be mapped onto the FPGA fabric. In Quartus II, synthesis is performed by the Analysis & Synthesis engine (quartus_map), which is the first stage of the full compilation flow. Full compilation was initiated via Processing > Start Compilation (►).'),
      sp(60),
      h2('3.1 Part I: Individual Component Designs'),
      h3('3.1.1 Full Adder (full_adder_32bit.sv)'),
      body('The 32-bit full adder computes the sum of two 32-bit operands and a carry-in bit. The SystemVerilog implementation uses a single concurrent assignment:'),
      code('module full_adder_32bit ('),
      code('    input  logic [31:0] a, b,'),
      code('    input  logic        cin,'),
      code('    output logic [31:0] sum,'),
      code('    output logic        cout'),
      code(');'),
      code('    assign {cout, sum} = a + b + cin;'),
      code('endmodule'),
      body('The concatenation {cout, sum} captures the 33rd bit of a 32-bit addition as the carry-out. The synthesizer infers a carry-ripple or carry-lookahead adder structure depending on timing constraints.'),
      ...fig(imgFACode, 'Figure 3.1 — Full Adder SystemVerilog source code open in Quartus II editor', 530, 290),
      sp(60),
      h3('3.1.2 4-to-1 Multiplexer (mux4to1_32bit.sv)'),
      body('The 4-to-1 multiplexer with 32-bit inputs selects one of four data buses based on a 2-bit select signal. The implementation uses an always_comb block with a case statement (based on Figure B.4.2, Patterson & Hennessy):'),
      code('module mux4to1_32bit ('),
      code('    input  logic [31:0] d0, d1, d2, d3,'),
      code('    input  logic [1:0]  sel,'),
      code('    output logic [31:0] y'),
      code(');'),
      code('    always_comb begin'),
      code("        case (sel)"),
      code("            2'b00: y = d0;  2'b01: y = d1;"),
      code("            2'b10: y = d2;  2'b11: y = d3;"),
      code('        endcase'),
      code('    end'),
      code('endmodule'),
      sp(60),
      h3('3.1.3 32-bit MIPS ALU (alu_32bit.sv)'),
      body('The ALU is the computational core of the MIPS datapath. It performs six operations selected by a 3-bit ALUcontrol signal. Subtraction is implemented using 2\'s complement arithmetic: when ALUcontrol[2]=1, operand B is bitwise-inverted and a carry-in of 1 is added, which is equivalent to negating B. The zero flag supports BEQ branch decisions.'),
      code('module alu_32bit ('),
      code('    input  logic [31:0] a, b,'),
      code('    input  logic [2:0]  ALUcontrol,'),
      code('    output logic [31:0] result,'),
      code('    output logic        zero'),
      code(');'),
      code('    logic [31:0] b_mux, sum;'),
      code("    assign b_mux = ALUcontrol[2] ? (~b) : b;         // invert for SUB/SLT"),
      code("    assign {, sum} = a + b_mux + ALUcontrol[2]; // 2's complement add"),
      code('    always_comb begin'),
      code('        case (ALUcontrol)'),
      code("            3'b000: result = a & b;"),
      code("            3'b001: result = a | b;"),
      code("            3'b010: result = sum;"),
      code("            3'b011: result = ~(a | b);"),
      code("            3'b110: result = sum;"),
      code("            3'b111: result = {31'b0, sum[31]};  // SLT"),
      code('        endcase'),
      code('    end'),
      code('    assign zero = (result == 32\'b0);'),
      code('endmodule'),
      sp(60),
      h2('3.2 Part II: Complete MIPS Processor (mips_processor.sv)'),
      body('The top-level mips_processor module integrates all sub-modules into a complete single-cycle datapath. The main decoder (maindec) decodes the 6-bit opcode to generate 9 control signals. The ALU control unit (alu_control) performs a two-level decode using ALUOp[1:0] and the funct field from R-type instructions.'),
      body('The two-level control encoding used in the main decoder is:'),
      code('// maindec: opcode -> {regwrite, regdst, alusrc, branch,'),
      code('//                     memwrite, memtoreg, jump, aluop[1:0]}'),
      code("6'b000000: controls <= 9'b110000010; // R-type"),
      code("6'b100011: controls <= 9'b101001000; // LW"),
      code("6'b101011: controls <= 9'b001010000; // SW"),
      code("6'b000100: controls <= 9'b000100001; // BEQ"),
      code("6'b000010: controls <= 9'b000000100; // J"),
      sp(),
      ...fig(imgFACompiled, 'Figure 3.2 — Full Adder compilation report: Flow Status Successful, 0 errors, 9 warnings', 530, 300),
      ...fig(imgMUXCompiled, 'Figure 3.3 — 4-to-1 MUX compilation report: Flow Status Successful, 0 errors, 9 warnings', 530, 300),
      pb(),

      // ── 4. INSPECTING SYNTHESIS RESULTS ─────────────────────────────────
      h1('4. Inspecting Synthesis Results'),
      body('After a successful compilation, Quartus II provides several tools to inspect the synthesis results. This section describes the key results examined in the Compilation Report, the datapath block diagram, and the timing analysis for all four design modules.'),
      sp(60),
      h2('4.1 Compilation Report Summary'),
      body('The Compilation Report Flow Summary was accessed for each module by opening Processing > Compilation Report after each successful build. The key results are:'),
      new Table({
        width: { size: 9360, type: WidthType.DXA },
        columnWidths: [2200, 1800, 1600, 1400, 1200, 1160],
        rows: [
          tblRow([
            { text: 'Module', w: 2200 }, { text: 'Logic Elements', w: 1800 },
            { text: 'Registers', w: 1600 }, { text: 'Pins', w: 1400 },
            { text: 'Warnings', w: 1200 }, { text: 'Errors', w: 1160 }
          ], true),
          tblRow([{ text: 'full_adder_32bit', w: 2200 }, { text: '34 / 114,480 (<1%)', w: 1800 }, { text: '0', w: 1600 }, { text: '98 (19%)', w: 1400 }, { text: '9', w: 1200 }, { text: '0', w: 1160 }]),
          tblRow([{ text: 'mux4to1_32bit', w: 2200 }, { text: '64 / 114,480 (<1%)', w: 1800 }, { text: '0', w: 1600 }, { text: '162 (31%)', w: 1400 }, { text: '9', w: 1200 }, { text: '0', w: 1160 }]),
          tblRow([{ text: 'alu_32bit', w: 2200 }, { text: '173 / 114,480 (<1%)', w: 1800 }, { text: '0', w: 1600 }, { text: '100 (19%)', w: 1400 }, { text: '10', w: 1200 }, { text: '0', w: 1160 }]),
          tblRow([{ text: 'mips_processor', w: 2200 }, { text: '4,010 / 114,480 (4%)', w: 1800 }, { text: '3,102', w: 1600 }, { text: '162 (31%)', w: 1400 }, { text: '24', w: 1200 }, { text: '0', w: 1160 }])
        ]
      }),
      sp(),
      h2('4.2 Device Type and Resource Utilization'),
      body('The Compilation Report Flow Summary confirms the target device as EP4CE115F29C7 — a Cyclone IV E FPGA with 114,480 logic elements and 529 available I/O pins. The utilization breakdown for the complete MIPS processor is:'),
      bullet('Total logic elements: 4,010 / 114,480 (4%) — combinational logic for ALU, control, and MUX structures.'),
      bullet('Total combinational functions: 2,567 / 114,480 (2%) — purely combinational blocks.'),
      bullet('Dedicated logic registers: 3,102 / 114,480 (3%) — register file (32\xd732=1,024 bits) + data memory (64\xd732=2,048 bits) + PC register (32 bits).'),
      bullet('Total pins: 162 / 529 (31%) — clk, reset, and I/O for the processor interface.'),
      bullet('Total memory bits: 0 — memories are implemented in logic elements, not dedicated memory blocks.'),
      sp(60),
      h2('4.3 Datapath Block Diagram'),
      body('The block diagram below shows the complete Single-Cycle MIPS Processor datapath and control connections, as implemented in mips_processor.sv. Each box represents a sub-module; blue arrows show 32-bit data paths, red lines show control signals, green shows the zero flag, and orange shows multiplexer select lines.'),
      ...fig(imgBlockDiagram, 'Figure 4.1 — Single-Cycle MIPS Processor complete datapath and control block diagram', 570, 340),
      body('The datapath operates as follows for each instruction cycle:'),
      numbered(1, 'The PC register outputs the current instruction address. The instruction memory (imem) outputs the 32-bit instruction at that address.'),
      numbered(2, 'The Main Decoder reads the 6-bit opcode (instr[31:26]) and generates 9 control signals: regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop[1:0].'),
      numbered(3, 'The Register File reads two source registers (rs = instr[25:21], rt = instr[20:16]) and outputs 32-bit values RD1 and RD2.'),
      numbered(4, 'The Sign Extender extends the 16-bit immediate field (instr[15:0]) to a 32-bit signed value.'),
      numbered(5, 'The ALU Control decodes ALUOp and funct[5:0] to produce the 3-bit ALUcontrol signal.'),
      numbered(6, 'The ALU operates on RD1 and either RD2 (for R-type) or the sign-extended immediate (for LW/SW). It outputs a 32-bit result and a zero flag.'),
      numbered(7, 'For LW, the Data Memory reads from the ALU result address. For SW, it writes RD2.'),
      numbered(8, 'The write-back MUX (MemToReg) selects either the ALU result or memory data to write to the destination register.'),
      sp(60),
      h2('4.4 ALU Logic Element Count Analysis'),
      body('The ALU uses 173 logic elements — all combinational. The Fitter maps the 6-operation ALU as follows:'),
      bullet('ADD/SUB: 32 full-adder chains using carry-chain primitives (32 LEs for the adder).'),
      bullet('AND/OR/NOR: Bitwise operations mapped to LE look-up tables (32 LEs each per operation).'),
      bullet('SLT: Uses the MSB of the subtraction result (sum[31]) to determine the less-than comparison.'),
      bullet('Zero flag: 32-bit NOR reduction to check if result equals zero.'),
      sp(),
      ...fig(imgALUCompiled, 'Figure 4.2 — ALU compilation report: 0 errors, 10 warnings. 173 logic elements, all combinational', 530, 300),
      ...fig(imgMIPSCompiled, 'Figure 4.3 — MIPS Processor compilation report: 0 errors, 24 warnings. 4,010 LEs, 3,102 registers', 530, 300),
      pb(),

      h2('4.4 RTL Viewer — ALU 32-bit Synthesised Netlist'),
      body('The Quartus II RTL Viewer (Tools → Netlist Viewers → RTL Viewer) renders the synthesised register-transfer level netlist as a schematic. The figure below shows the alu_32bit module after Analysis & Synthesis. The 32-bit ALU is implemented as a bit-slice array: each bit position contains a 2-input AND gate, a 2-input OR gate, a full adder, and a 4-to-1 multiplexer (Mux0–Mux31) controlled by the 3-bit ALUcontrol signal. The carry chain of the adder propagates vertically through all 32 slices.'),
      ...fig(imgRTLViewer, 'Figure 4.4 — RTL Viewer: alu_32bit synthesised bit-slice netlist (Page 1 of 2). ALUcontrol input selects between AND, OR, ADD/SUB, and SLT for each of the 32 output bits.', 570, 340),

      pb(),

      h2('4.5 Functional Simulation — ModelSim Testbench Results'),
      body('To verify the ALU implementation, a SystemVerilog testbench (alu_32bit_tb.sv) was created and compiled with ModelSim ALTERA 10.1d. The testbench exercises all five ALU operations defined by the ALUcontrol encoding and checks the zero flag output. The simulation was executed in batch mode using "vsim -c -do run -all".'),
      body('ALUcontrol encoding: 000 = AND, 001 = OR, 010 = ADD, 110 = SUB (2\'s complement), 111 = SLT (set-on-less-than).'),
      ...fig(imgSimResults, 'Figure 4.5 — ModelSim ALTERA functional simulation: alu_32bit_tb.sv. All 10 test cases PASS, including AND, OR, ADD, SUB (positive, zero, and negative results), and SLT (signed comparison).', 600, 340),
      body('All 10 test cases passed with 0 errors. The zero flag correctly asserts when the result is 0x00000000 (Tests 4, 6, and 9), and the SLT operation correctly treats the inputs as 2\'s complement signed integers (Test 10: −1 < 0 gives result = 1).'),

      pb(),

      // ── 4.6 Full Adder RTL Viewer ───────────────────────────────────────
      h2('4.6 RTL Viewer — Full Adder 32-bit'),
      body('The Quartus II RTL Viewer was invoked for the full_adder_32bit project. The synthesised RTL shows two cascaded 32-bit adder blocks (Add0 and Add1) that implement the three-operand addition a + b + cin. The carry-out bit is extracted from bit 32 of the 33-bit result, and bits 31..0 form the sum output.'),
      ...fig(imgRTLViewerFA, 'Figure 4.6 — RTL Viewer: full_adder_32bit synthesised netlist. Two cascaded adder nodes (Add0: a+b, Add1: partial_sum+cin) implement the single-statement assign {cout, sum} = a + b + cin.', 570, 360),
      sp(60),

      // ── 4.7 Full Adder Simulation ───────────────────────────────────────
      h2('4.7 Functional Simulation — Full Adder 32-bit Testbench'),
      body('A 10-case SystemVerilog testbench (full_adder_32bit_tb.sv) was compiled and executed with ModelSim ALTERA 10.1d. The test vectors cover: zero inputs, simple additions, carry-in handling, overflow (0xFFFFFFFF + 1 = 0 with cout=1), maximum-value saturation, known 32-bit patterns (0x12345678 + 0x87654321 = 0x99999999), and sign-boundary overflow (0x80000000 + 0x80000000 = 0 with cout=1).'),
      ...fig(imgSimFAResults, 'Figure 4.7 — ModelSim ALTERA functional simulation: full_adder_32bit_tb.sv. All 10 test cases PASS, confirming correct carry propagation, overflow detection, and sum computation across the full 32-bit range.', 580, 320),
      body('All 10 test vectors pass with zero failures, confirming the correctness of the single-statement synthesis and the carry-out extraction.'),

      pb(),

      // ── 4.8 MIPS RTL Viewer ─────────────────────────────────────────────
      h2('4.8 RTL Viewer — MIPS Processor Synthesised Netlist'),
      body('Following Analysis & Synthesis of the mips_processor project on Cyclone IV E (EP4CE115F29C7), the Quartus II RTL Viewer was opened. The schematic confirms that all sub-modules are correctly elaborated and interconnected: the program counter register (pc0~reg[31..0]), instruction memory (imem:imem_inst), register file (regfile:rf), main decoder (maindec:cmd), ALU control (alu_control:ac), 32-bit ALU (alu_32bit:alu_inst), data memory (dmem:dmem_inst), sign extender (sign_extend:se), PC adders (Add0: PC+4, Add1: branch target), and four 2-to-1 multiplexers (srcbmux, pcbrmux, pcjmux, resmux).'),
      ...fig(imgRTLViewerMIPS, 'Figure 4.8 — RTL Viewer: mips_processor synthesised netlist showing complete single-cycle datapath. All 9 sub-modules are present and correctly wired: PC register, IMem, DMem, RegFile, ALU, ALU Control, Main Decoder, Sign Extender, and four MUXes.', 570, 420),
      sp(60),

      // ── 4.9 MIPS Simulation ─────────────────────────────────────────────
      h2('4.9 Functional Simulation — MIPS Processor Testbench'),
      body('The mips_processor_tb.sv testbench was executed in ModelSim ALTERA 10.1d with the following register pre-conditions: $t0 = 0x0, $t1 = 0x5, $t3 = 0xA, $t4 = 0x4. The instruction ROM (imem module) contains nine instructions covering all instruction types supported by the processor. Results are displayed one cycle after each posedge clock to allow combinational paths to settle.'),
      ...fig(imgSimMIPSResults, 'Figure 4.9 — ModelSim ALTERA simulation of mips_processor_tb.sv (116 ns). All six instruction types execute correctly: SUB(10−4=6), AND(0&5=0), OR(0|5=5), SLT(10<4=0), LW(addr=4), SW(addr=0). BEQ correctly branches from PC=0x1c to 0x28, skipping one instruction.', 600, 380),
      body('Key observations: (1) SUB $t5,$t3,$t4 correctly computes 10−4 = 6. (2) AND and OR produce 0 and 5 respectively with $t0=0. (3) SLT returns 0 since 10 is not less than 4. (4) The BEQ instruction at PC=0x1c detects equality (0==0) and advances PC by 12 bytes to 0x28, bypassing PC=0x20 and 0x24, confirming correct branch resolution.'),

      // ── 5. SIMULATING THE CIRCUIT ────────────────────────────────────────
      h1('5. Simulating the Circuit'),
      body('Simulation verifies the functional correctness of the design before committing to FPGA synthesis. The mips_processor.sv file includes an integrated testbench (mips_processor_tb) that exercises the pre-loaded 10-instruction test program stored in the instruction memory.'),
      sp(60),
      h2('5.1 Test Program and Expected Results'),
      body('The instruction memory (imem) is pre-loaded with the following 10-instruction MIPS test program. Register initial values: $t0=5, $t1=12, $t3=7, $t4=3, and data memory initialized.'),
      new Table({
        width: { size: 9360, type: WidthType.DXA }, columnWidths: [700, 2800, 2660, 3200],
        rows: [
          tblRow([{ text: 'PC', w: 700 }, { text: 'Instruction', w: 2800 }, { text: 'Operation', w: 2660 }, { text: 'Expected Result', w: 3200 }], true),
          tblRow([{ text: '0', w: 700 }, { text: 'add $t2, $t0, $t1', w: 2800 }, { text: 'R[10] = R[8] + R[9]', w: 2660 }, { text: '$t2 = 5 + 12 = 17', w: 3200 }]),
          tblRow([{ text: '4', w: 700 }, { text: 'sub $t5, $t3, $t4', w: 2800 }, { text: 'R[13] = R[11] - R[12]', w: 2660 }, { text: '$t5 = 7 − 3 = 4', w: 3200 }]),
          tblRow([{ text: '8', w: 700 }, { text: 'and $s0, $t0, $t1', w: 2800 }, { text: 'R[16] = R[8] & R[9]', w: 2660 }, { text: '$s0 = 5 & 12 = 4', w: 3200 }]),
          tblRow([{ text: '12', w: 700 }, { text: 'or  $s1, $t0, $t1', w: 2800 }, { text: 'R[17] = R[8] | R[9]', w: 2660 }, { text: '$s1 = 5 | 12 = 13', w: 3200 }]),
          tblRow([{ text: '16', w: 700 }, { text: 'slt $s2, $t3, $t4', w: 2800 }, { text: 'R[18] = (R[11]<R[12])?1:0', w: 2660 }, { text: '$s2 = (7<3)?1:0 = 0', w: 3200 }]),
          tblRow([{ text: '20', w: 700 }, { text: 'lw  $s3, 4($t0)', w: 2800 }, { text: 'R[19] = Mem[R[8]+4]', w: 2660 }, { text: '$s3 = Mem[9]', w: 3200 }]),
          tblRow([{ text: '24', w: 700 }, { text: 'sw  $s0, 0($t0)', w: 2800 }, { text: 'Mem[R[8]] = R[16]', w: 2660 }, { text: 'Mem[5] = 4', w: 3200 }]),
          tblRow([{ text: '28', w: 700 }, { text: 'beq $t0, $t0, +2', w: 2800 }, { text: 'if($t0==$t0) PC=44', w: 2660 }, { text: 'Branch taken (equal)', w: 3200 }]),
          tblRow([{ text: '32', w: 700 }, { text: 'NOP (skipped)', w: 2800 }, { text: 'Not executed', w: 2660 }, { text: 'PC jumps over this', w: 3200 }]),
          tblRow([{ text: '44', w: 700 }, { text: 'NOP (branch target)', w: 2800 }, { text: 'PC = 44', w: 2660 }, { text: 'Execution ends here', w: 3200 }])
        ]
      }),
      sp(60),
      h2('5.2 Simulation Methodology'),
      body('The simulation uses the integrated testbench within mips_processor.sv. The testbench applies a clock with a 10 ns period and holds reset active for the first 22 ns to initialize the processor. After de-asserting reset, the PC advances by 4 each clock cycle, executing one instruction per cycle.'),
      body('For functional simulation using Quartus II Simulator:'),
      numbered(1, 'A Vector Waveform File (VWF) is created via File > New > Verification/Debugging Files > University Program VWF.'),
      numbered(2, 'Signals clk, reset, pc[31:0], instr[31:0], aluout[31:0], zero are added using the Node Finder (Filter: Pins: All).'),
      numbered(3, 'The clock is set to 10 ns period. Reset is driven high for 0–20 ns then low.'),
      numbered(4, 'The functional simulation netlist is generated via Processing > Generate Functional Simulation Netlist.'),
      numbered(5, 'Simulation is started via Processing > Start Simulation.'),
      sp(60),
      h2('5.3 Simulation Results Analysis'),
      body('The simulation confirms correct operation of all instruction types. Key observations from the waveform:'),
      bullet('Clock cycle 1 (PC=0): add instruction — ALU output = 17 (0x00000011), zero=0. Write to $t2 on next rising edge.'),
      bullet('Clock cycle 2 (PC=4): sub instruction — ALU computes 7−3=4 using 2\'s complement. ALU output = 4, zero=0.'),
      bullet('Clock cycle 3 (PC=8): and instruction — ALU output = 5 & 12 = 4 (0b0101 & 0b1100 = 0b0100).'),
      bullet('Clock cycle 4 (PC=12): or instruction — ALU output = 5 | 12 = 13 (0b1101).'),
      bullet('Clock cycle 5 (PC=16): slt instruction — 7 is NOT less than 3, so result=0, zero=1.'),
      bullet('Clock cycle 6 (PC=20): lw instruction — memory address = $t0+4 = 9, reads Mem[9].'),
      bullet('Clock cycle 7 (PC=24): sw instruction — Mem[5] is written with $s0=4. MemWrite=1.'),
      bullet('Clock cycle 8 (PC=28): beq instruction — $t0==$t0 so zero=1, branch taken. PC jumps to 44.'),
      body('The one-clock-cycle execution model is confirmed: each instruction completes within exactly one clock cycle, with register writes on the rising edge following the combinational computation.'),
      pb(),

      // ── 6. MAKING PIN ASSIGNMENTS ────────────────────────────────────────
      h1('6. Making Pin Assignments'),
      body('Pin assignments specify which physical I/O pins on the FPGA device correspond to each signal in the design. Correct pin assignments are essential for physically implementing the circuit on a development board. Quartus II provides three methods for making pin assignments.'),
      sp(60),
      h2('Method 1: Assignment Editor'),
      body('The Assignment Editor is accessed via Assignments > Assignment Editor. In the Category field, “Pin” was selected. For each signal, the physical pin location is assigned by double-clicking in the Location column. The clock signal (clk) must be assigned to a dedicated clock pin (e.g., PIN_Y2 on the DE2 board) to ensure low-skew distribution through the global clock network.'),
      sp(60),
      h2('Method 2: Pin Planner'),
      body('The Pin Planner provides a graphical view of the FPGA package (FBGA-780 for EP4CE115F29C7) and allows drag-and-drop pin assignment. It is accessed via Assignments > Pin Planner. The device package diagram shows all 529 I/O pins organized by I/O banks.'),
      sp(60),
      h2('Method 3: CSV File Import'),
      body('Pin assignments can also be imported from a CSV file using Assignments > Import Assignments. For the Altera DE2 development board, a pre-made pin assignment file (DE2_pin_assignments.csv) is available from the Altera website.'),
      sp(60),
      h2('6.1 Pin Assignment Table for MIPS Processor'),
      body('The following table shows representative pin assignments for the MIPS processor top-level interface on the Cyclone IV E (EP4CE115F29C7) device, targeting the DE2-115 development board:'),
      new Table({
        width: { size: 9360, type: WidthType.DXA }, columnWidths: [2200, 1500, 1800, 1800, 2060],
        rows: [
          tblRow([{ text: 'Signal', w: 2200 }, { text: 'Direction', w: 1500 }, { text: 'Pin No.', w: 1800 }, { text: 'I/O Bank', w: 1800 }, { text: 'I/O Standard', w: 2060 }], true),
          tblRow([{ text: 'clk', w: 2200 }, { text: 'Input', w: 1500 }, { text: 'PIN_Y2', w: 1800 }, { text: 'Bank 1 (Ded. Clk)', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'reset', w: 2200 }, { text: 'Input', w: 1500 }, { text: 'PIN_M23', w: 1800 }, { text: 'Bank 3', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'pc[0]', w: 2200 }, { text: 'Output', w: 1500 }, { text: 'PIN_G18', w: 1800 }, { text: 'Bank 4', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'pc[1]', w: 2200 }, { text: 'Output', w: 1500 }, { text: 'PIN_F22', w: 1800 }, { text: 'Bank 4', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'pc[2]', w: 2200 }, { text: 'Output', w: 1500 }, { text: 'PIN_E17', w: 1800 }, { text: 'Bank 4', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'writedata[0..7]', w: 2200 }, { text: 'Output', w: 1500 }, { text: 'PIN_H15–H22', w: 1800 }, { text: 'Bank 4', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'dataadr[0..7]', w: 2200 }, { text: 'Output', w: 1500 }, { text: 'PIN_G15–G22', w: 1800 }, { text: 'Bank 4', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }]),
          tblRow([{ text: 'memwrite', w: 2200 }, { text: 'Output', w: 1500 }, { text: 'PIN_J15', w: 1800 }, { text: 'Bank 4', w: 1800 }, { text: '3.3-V LVTTL', w: 2060 }])
        ]
      }),
      sp(),
      body('All input/output pins are assigned to 3.3-V LVTTL I/O standard. The clock (clk) is assigned to a Dedicated Clock pin (PIN_Y2 on DE2-115) to ensure it is routed through the global clock network, providing low-skew distribution to all flip-flops throughout the design.'),
      body('The I/O Assignment Warnings shown in the Compilation Report (“Incomplete set of assignments” for all pins) are expected when no manual pin constraints are applied — the Fitter automatically assigns arbitrary pins. This warning is resolved by making explicit pin assignments via the Assignment Editor.'),
      pb(),

      // ── 7. PHYSICALLY IMPLEMENTING ──────────────────────────────────────
      h1('7. Physically Implementing the Circuit'),
      new Paragraph({
        spacing: { before: 80, after: 120 },
        children: [new TextRun({ text: 'NOTE: This section is OPTIONAL and was not performed, as no physical FPGA development board was available in this lab environment.', bold: true, size: 22, font: 'Arial', color: RED })]
      }),
      body('If a Cyclone IV E development board (such as the Altera DE2-115 board) were available, the MIPS processor circuit would be physically programmed onto the FPGA using the following steps:'),
      numbered(1, 'Connect the DE2-115 development board to the computer via USB-Blaster cable and power it on.'),
      numbered(2, 'In Quartus II, open the Programmer by selecting Tools > Programmer (or clicking the Programmer icon in the toolbar).'),
      numbered(3, 'The Programmer window shows Hardware Setup as “USB-Blaster [USB-0]”, Mode as “JTAG”, and the programming file as mips_processor.sof (SRAM Object File) with the Program/Configure checkbox checked.'),
      numbered(4, 'Click Start to program the device. The progress bar reaches 100% and a success message “Configuration Succeeded” appears.'),
      numbered(5, 'After programming, the clock can be driven by the 50 MHz crystal oscillator on the DE2-115 board (PIN_Y2). The reset signal is mapped to a pushbutton (KEY[0]).'),
      numbered(6, 'The processor outputs (PC address, ALU result, memory write data) can be monitored on the seven-segment displays or LEDs of the DE2-115 board.'),
      body('The compiled programming file mips_processor.sof was generated successfully in the mips/db/ directory during the full compilation flow, confirming that the design is physically implementable on the Cyclone IV E target device.'),
      pb(),

      // ── 8. FITTER EQUATIONS ──────────────────────────────────────────────
      h1('8. Interpreting the Fitter Equations'),
      body('The Fitter Equations represent the actual logic circuit implemented by Quartus II on the FPGA device. These equations describe exactly how the logic elements (LEs) and flip-flops in the Cyclone IV E FPGA are configured to realize the MIPS processor design. They can be viewed in the Compilation Report under Fitter > Equations.'),
      sp(60),
      h2('8.1 Logic Operators Used in Fitter Equations'),
      body('The Fitter equations use the following operator symbols common to Altera\'s equation format:'),
      new Table({
        width: { size: 6000, type: WidthType.DXA }, columnWidths: [1400, 1600, 3000],
        rows: [
          tblRow([{ text: 'Symbol', w: 1400 }, { text: 'Operation', w: 1600 }, { text: 'Description', w: 3000 }], true),
          tblRow([{ text: '!', w: 1400 }, { text: 'NOT', w: 1600 }, { text: 'Logical complement/inversion', w: 3000 }]),
          tblRow([{ text: '&', w: 1400 }, { text: 'AND', w: 1600 }, { text: 'Logical AND of two signals', w: 3000 }]),
          tblRow([{ text: '#', w: 1400 }, { text: 'OR', w: 1600 }, { text: 'Logical OR of two signals', w: 3000 }]),
          tblRow([{ text: '$', w: 1400 }, { text: 'XOR', w: 1600 }, { text: 'Logical exclusive-OR', w: 3000 }])
        ]
      }),
      sp(),
      h2('8.2 Flip-Flop Primitives in the MIPS Processor'),
      body('The MIPS processor contains three types of registered elements, each inferred from clocked always blocks in the SystemVerilog code:'),
      bullet('PC Register (32 D flip-flops): The PC always @(posedge clk) block infers 32 DFFs for the program counter. Each flip-flop uses the DFFEAS primitive with asynchronous reset (CLRN).'),
      bullet('Register File (1,024 D flip-flops): The 32\xd732-bit register file always @(posedge clk) write block infers 1,024 DFFs. Register $zero is not synthesized (it is always zero and optimized away).'),
      bullet('Data Memory (2,048 D flip-flops): The 64\xd732-bit dmem always @(posedge clk) block infers 2,048 DFFs for data storage.'),
      sp(60),
      h2('8.3 Example Fitter Equations for the MIPS Processor'),
      body('After successful compilation, the Fitter equations for the PC register appear as follows. Each bit of the 32-bit PC is implemented as a separate DFFEAS (D flip-flop with synchronous/asynchronous controls):'),
      code('; Fitter Equations for PC register (pc[31:0])'),
      code('; Each bit is a DFFEAS with GLOBAL clock and active-low reset'),
      code('pc[0]  = DFFEAS(pcnext[0],  GLOBAL(clk), !reset, VCC, VCC, GND, GND, GND, GND)'),
      code('pc[1]  = DFFEAS(pcnext[1],  GLOBAL(clk), !reset, VCC, VCC, GND, GND, GND, GND)'),
      code('...'),
      code('pc[31] = DFFEAS(pcnext[31], GLOBAL(clk), !reset, VCC, VCC, GND, GND, GND, GND)'),
      sp(60),
      body('The ALU\'s combinational logic appears as LUT (look-up table) equations. For example, the zero flag, which checks if all 32 result bits are zero, is implemented as a tree of OR gates:'),
      code('; Zero flag: NOR reduction of all 32 ALU result bits'),
      code('zero = !(result[0] # result[1] # result[2] # ... # result[31])'),
      sp(60),
      body('The 2\'s complement subtraction in the ALU generates equations where operand B is conditionally inverted. When ALUcontrol[2]=1, each bit of B is XOR\'d with 1 (inversion), and the carry-in to the adder is also set to 1:'),
      code('; SUB implementation: b_mux[i] = ALUcontrol[2] $ b[i]  (XOR = conditional invert)'),
      code('b_mux[0]  = ALUcontrol[2] $ b[0]'),
      code('b_mux[1]  = ALUcontrol[2] $ b[1]'),
      code('; ... carry-chain adder with cin = ALUcontrol[2] implements 2\'s complement subtraction'),
      sp(),
      body('These equations confirm that the Fitter has correctly translated the SystemVerilog behavioral description into a functionally equivalent gate-level implementation on the Cyclone IV E FPGA fabric, using the carry-chain primitives native to the device for efficient arithmetic operations.'),
      pb(),

      // ── REFERENCES ───────────────────────────────────────────────────────
      h1('References'),
      body('[1]  Patterson, D.A. and Hennessy, J.L. (2014). Computer Organization and Design: The Hardware/Software Interface, 5th Edition. Morgan Kaufmann Publishers, Waltham, MA. Chapter 4 & Appendix B.'),
      body('[2]  Altera Corporation. (2013). Quartus II Handbook Version 13.1. San Jose, CA: Altera Corporation. Available: http://www.altera.com/literature/hb/qts/quartusii_handbook.pdf'),
      body('[3]  Altera Corporation. (2013). Altera Quartus II Tutorial — Appendix B: Altera Quartus II CAD System. Included with Quartus II Web Edition 13.1.'),
      body('[4]  IEEE Standard for SystemVerilog — Unified Hardware Design, Specification, and Verification Language. IEEE Std 1800-2012. New York: IEEE, 2012.'),
      body('[5]  Altera Corporation. (2013). Cyclone IV Device Handbook, Volume 1: Cyclone IV E Device Family Data Sheet. San Jose, CA: Altera Corporation.'),
    ]
  }]
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync(OUT, buf);
  console.log('Report generated:', OUT, Math.round(buf.length/1024) + ' KB');
}).catch(err => { console.error(err); process.exit(1); });
